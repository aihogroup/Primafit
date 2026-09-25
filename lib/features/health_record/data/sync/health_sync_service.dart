import 'package:sqflite/sqflite.dart';

import '../../../../core/logging/app_logger.dart';
import 'health_metric_spec.dart';
import 'health_sync_remote.dart';
import 'sync_schema.dart';
import 'sync_state_store.dart';

/// Outcome of one sync run.
typedef SyncReport = ({int pushed, int pulled, int skipped, int quarantined});

/// Two-way sync of the on-device health records with Supabase.
///
/// Push: dirty rows + tombstones -> `sync_health_measurements` in batches;
/// acknowledged rows are marked clean only if unchanged meanwhile.
/// Pull: server changes after the stored cursor, applied with last-write-wins
/// on `updated_at` (client time of the last edit). Deletions win over older
/// edits and never resurrect locally deleted rows.
///
/// Row states: `dirty` 0 = clean, 1 = pending, 2 = rejected by the server
/// (quarantined until the user edits it again).
class HealthSyncService {
  HealthSyncService({
    required this.remote,
    required this.state,
    List<HealthMetricSpec>? specs,
    Future<Database> Function(HealthMetricSpec spec)? openDatabase,
  }) : specs = specs ?? healthMetricSpecs,
       _openRaw = openDatabase ?? ((spec) => spec.open());

  static const batchSize = 500;

  /// Re-read a small window before the cursor: rows committed late with an
  /// earlier server timestamp are still picked up (apply is idempotent).
  static const pullOverlap = Duration(seconds: 30);

  static const _zeroUuid = '00000000-0000-0000-0000-000000000000';

  final HealthSyncRemote remote;
  final SyncStateStore state;
  final List<HealthMetricSpec> specs;
  final Future<Database> Function(HealthMetricSpec spec) _openRaw;
  final _ensured = Expando<bool>();

  /// Opens a table and makes sure its sync schema exists (once per handle).
  Future<Database> _open(HealthMetricSpec spec) async {
    final db = await _openRaw(spec);
    if (_ensured[db] != true) {
      await SyncSchema.ensure(db, spec);
      _ensured[db] = true;
    }
    return db;
  }

  Future<SyncReport> sync() async {
    final push = await _push();
    final pulled = await _pull();
    await state.writeLastSync(DateTime.now());
    return (
      pushed: push.pushed,
      pulled: pulled,
      skipped: push.skipped,
      quarantined: push.quarantined,
    );
  }

  // ---------------------------------------------------------------- push

  Future<({int pushed, int skipped, int quarantined})> _push() async {
    var pushed = 0;
    var skipped = 0;
    var quarantined = 0;

    for (final spec in specs) {
      final db = await _open(spec);

      final pending = <_Outgoing>[];
      for (final row in await db.query(spec.table, where: 'dirty = 1')) {
        final payload = spec.toRemote(row);
        if (payload == null) {
          skipped++;
          continue;
        }
        pending.add((
          payload: payload,
          updatedAt: row['updated_at'] as String?,
          isTombstone: false,
        ));
      }
      for (final t in await db.query(SyncSchema.tombstones)) {
        final payload = spec.toRemote(t, deletedAt: t['deleted_at'] as String);
        if (payload == null) {
          // Nothing the server could store (never valid): just forget it.
          await db.delete(SyncSchema.tombstones, where: 'sync_id = ?', whereArgs: [t['sync_id']]);
          continue;
        }
        pending.add((payload: payload, updatedAt: null, isTombstone: true));
      }

      for (var i = 0; i < pending.length; i += batchSize) {
        final batch = pending.sublist(i, (i + batchSize).clamp(0, pending.length));
        final result = await _pushBatch(db, spec, batch);
        pushed += result.pushed;
        quarantined += result.quarantined;
      }
    }
    return (pushed: pushed, skipped: skipped, quarantined: quarantined);
  }

  Future<({int pushed, int quarantined})> _pushBatch(
    Database db,
    HealthMetricSpec spec,
    List<_Outgoing> batch,
  ) async {
    try {
      final acked = await remote.push([for (final o in batch) o.payload]);
      await _markPushed(db, spec, batch.where((o) => acked.contains(o.payload['id'])));
      return (pushed: acked.length, quarantined: 0);
    } on SyncDataException catch (e) {
      if (batch.length == 1) {
        final id = batch.single.payload['id'];
        AppLogger.warning('Server rejected ${spec.metric.dbValue} row $id: $e', tag: 'sync');
        if (batch.single.isTombstone) {
          await db.delete(SyncSchema.tombstones, where: 'sync_id = ?', whereArgs: [id]);
        } else {
          await db.update(spec.table, {'dirty': 2}, where: 'sync_id = ?', whereArgs: [id]);
        }
        return (pushed: 0, quarantined: 1);
      }
      // Isolate the offending row(s).
      var pushed = 0;
      var quarantined = 0;
      for (final single in batch) {
        final r = await _pushBatch(db, spec, [single]);
        pushed += r.pushed;
        quarantined += r.quarantined;
      }
      return (pushed: pushed, quarantined: quarantined);
    }
  }

  Future<void> _markPushed(Database db, HealthMetricSpec spec, Iterable<_Outgoing> acked) async {
    final batch = db.batch();
    for (final o in acked) {
      final id = o.payload['id'];
      if (o.isTombstone) {
        batch.delete(SyncSchema.tombstones, where: 'sync_id = ?', whereArgs: [id]);
      } else {
        // Only if not edited again while the request was in flight.
        batch.update(
          spec.table,
          {'dirty': 0},
          where: 'sync_id = ? AND updated_at IS ? AND dirty = 1',
          whereArgs: [id, o.updatedAt],
        );
      }
    }
    await batch.commit(noResult: true);
  }

  // ---------------------------------------------------------------- pull

  Future<int> _pull() async {
    final bySpec = {for (final s in specs) s.metric.dbValue: s};
    final stored = await state.readCursor();
    SyncCursor? cursor = stored == null
        ? null
        : (serverUpdatedAt: stored.serverUpdatedAt.subtract(pullOverlap), id: _zeroUuid);
    var applied = 0;

    while (true) {
      final rows = await remote.pull(after: cursor, limit: batchSize);
      for (final row in rows) {
        final spec = bySpec[row['metric']];
        if (spec == null) continue; // metric unknown to this app version
        final db = await _open(spec);
        if (await _apply(db, spec, row)) applied++;
      }
      if (rows.isEmpty) break;
      final last = rows.last;
      cursor = (
        serverUpdatedAt: DateTime.parse(last['server_updated_at'] as String),
        id: last['id'] as String,
      );
      await state.writeCursor(cursor);
      if (rows.length < batchSize) break;
    }
    return applied;
  }

  /// Applies one server row; returns whether local data changed.
  Future<bool> _apply(Database db, HealthMetricSpec spec, Map<String, dynamic> row) async {
    final id = row['id'] as String;
    final remoteAt = DateTime.parse(row['client_updated_at'] as String);
    final deletedAt = row['deleted_at'] as String?;

    final local = (await db.query(spec.table, where: 'sync_id = ?', whereArgs: [id])).firstOrNull;
    final localAt = DateTime.tryParse(local?['updated_at'] as String? ?? '');
    final localIsNewer = local != null && localAt != null && !localAt.isBefore(remoteAt);

    if (deletedAt != null) {
      if (local == null || (localIsNewer && local['dirty'] != 0)) return false;
      await db.transaction((txn) async {
        await txn.delete(spec.table, where: 'sync_id = ?', whereArgs: [id]);
        // Deletion came from the server: no tombstone to push back.
        await txn.delete(SyncSchema.tombstones, where: 'sync_id = ?', whereArgs: [id]);
      });
      return true;
    }

    if (local == null) {
      final tombstone = (await db.query(
        SyncSchema.tombstones,
        where: 'sync_id = ?',
        whereArgs: [id],
      )).firstOrNull;
      final deletedLocally = DateTime.tryParse(tombstone?['deleted_at'] as String? ?? '');
      if (deletedLocally != null && !deletedLocally.isBefore(remoteAt)) return false;
      await db.insert(spec.table, {
        ...spec.toLocal(row),
        'sync_id': id,
        'updated_at': row['client_updated_at'],
        'dirty': 0,
      });
      return true;
    }

    if (localIsNewer) return false; // local edit wins; it is (or will be) pushed
    await db.update(
      spec.table,
      {...spec.toLocal(row), 'updated_at': row['client_updated_at'], 'dirty': 0},
      where: 'sync_id = ?',
      whereArgs: [id],
    );
    return true;
  }
}

typedef _Outgoing = ({Map<String, Object?> payload, String? updatedAt, bool isTombstone});
