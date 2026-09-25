import 'package:sqflite/sqflite.dart';

import 'health_metric_spec.dart';

/// Adds sync bookkeeping to a legacy health-record table without touching
/// the legacy helper code: SQLite triggers keep it up to date.
///
/// Columns added: `sync_id` (UUID, the server id), `updated_at` (ISO-8601
/// UTC, last local change) and `dirty` (1 = must be pushed).
/// * insert by a legacy helper (no sync_id) -> new UUID, dirty
/// * update of a data column that leaves `updated_at` untouched -> dirty
///   (sync writes set `updated_at` explicitly, so they do not re-dirty rows)
/// * delete -> row snapshot kept in `sync_tombstones` until pushed
///
/// Idempotent: safe to run on every open. Only uses SQLite features available
/// on old Android versions (no UPSERT/RETURNING/JSON1).
abstract final class SyncSchema {
  static const tombstones = 'sync_tombstones';

  static const _now = "strftime('%Y-%m-%dT%H:%M:%fZ', 'now')";

  /// Random RFC 4122 v4 UUID generated inside SQLite.
  static const _uuid =
      "lower(hex(randomblob(4))) || '-' || lower(hex(randomblob(2))) || '-4' || "
      "substr(lower(hex(randomblob(2))), 2) || '-' || "
      "substr('89ab', 1 + (abs(random()) % 4), 1) || substr(lower(hex(randomblob(2))), 2) || '-' || "
      'lower(hex(randomblob(6)))';

  static Future<void> ensure(Database db, HealthMetricSpec spec) async {
    final t = spec.table;
    final existing = {
      for (final c in await db.rawQuery('PRAGMA table_info($t)')) c['name'] as String,
    };

    await db.transaction((txn) async {
      if (!existing.contains('sync_id')) {
        await txn.execute('ALTER TABLE $t ADD COLUMN sync_id TEXT');
      }
      if (!existing.contains('updated_at')) {
        await txn.execute('ALTER TABLE $t ADD COLUMN updated_at TEXT');
      }
      if (!existing.contains('dirty')) {
        await txn.execute('ALTER TABLE $t ADD COLUMN dirty INTEGER NOT NULL DEFAULT 1');
      }
      await txn.execute('CREATE UNIQUE INDEX IF NOT EXISTS ${t}_sync_id ON $t(sync_id)');
      await txn.execute('CREATE INDEX IF NOT EXISTS ${t}_dirty ON $t(dirty)');

      final snapshotColumns = spec.dataColumns.map((c) => '$c TEXT').join(', ');
      await txn.execute(
        'CREATE TABLE IF NOT EXISTS $tombstones '
        '(sync_id TEXT PRIMARY KEY, deleted_at TEXT NOT NULL, $snapshotColumns)',
      );

      await txn.execute('''
        CREATE TRIGGER IF NOT EXISTS ${t}_sync_insert AFTER INSERT ON $t
        WHEN NEW.sync_id IS NULL
        BEGIN
          UPDATE $t SET sync_id = $_uuid, updated_at = $_now, dirty = 1 WHERE rowid = NEW.rowid;
        END''');
      await txn.execute('''
        CREATE TRIGGER IF NOT EXISTS ${t}_sync_update AFTER UPDATE OF ${spec.dataColumns.join(', ')} ON $t
        WHEN NEW.updated_at IS OLD.updated_at
        BEGIN
          UPDATE $t SET updated_at = $_now, dirty = 1 WHERE rowid = NEW.rowid;
        END''');
      final oldValues = spec.dataColumns.map((c) => 'OLD.$c').join(', ');
      await txn.execute('''
        CREATE TRIGGER IF NOT EXISTS ${t}_sync_delete AFTER DELETE ON $t
        WHEN OLD.sync_id IS NOT NULL
        BEGIN
          INSERT OR REPLACE INTO $tombstones (sync_id, deleted_at, ${spec.dataColumns.join(', ')})
          VALUES (OLD.sync_id, $_now, $oldValues);
        END''');

      // Rows written before sync existed (MVP data): give them ids and push them.
      await txn.execute(
        'UPDATE $t SET sync_id = $_uuid, updated_at = $_now, dirty = 1 WHERE sync_id IS NULL',
      );
    });
  }
}
