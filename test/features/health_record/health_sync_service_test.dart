import 'package:flutter_test/flutter_test.dart';
import 'package:primafit/features/health_record/data/sync/health_metric_spec.dart';
import 'package:primafit/features/health_record/data/sync/health_sync_remote.dart';
import 'package:primafit/features/health_record/data/sync/health_sync_service.dart';
import 'package:primafit/features/health_record/data/sync/sync_schema.dart';
import 'package:primafit/features/health_record/data/sync/sync_state_store.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// In-memory stand-in for `public.sync_health_measurements` + the pull query,
/// with the same rules: last-write-wins on client_updated_at, ack for stored
/// or already-newer rows, keyset feed on (server_updated_at, id).
class FakeServer {
  final rows = <String, Map<String, dynamic>>{};
  final rejectIds = <String>{};
  var _clock = DateTime.utc(2026, 9, 25);

  Set<String> upsert(List<Map<String, Object?>> incoming) {
    if (incoming.any((r) => rejectIds.contains(r['id']))) {
      throw const SyncDataException('23514: check violation');
    }
    final acked = <String>{};
    for (final r in incoming) {
      final id = r['id']! as String;
      final existing = rows[id];
      final inAt = DateTime.parse(r['client_updated_at']! as String);
      if (existing == null ||
          inAt.isAfter(DateTime.parse(existing['client_updated_at'] as String))) {
        _clock = _clock.add(const Duration(milliseconds: 1));
        rows[id] = {...r, 'server_updated_at': _clock.toIso8601String()};
        acked.add(id);
      } else {
        acked.add(id); // same or newer already stored
      }
    }
    return acked;
  }

  List<Map<String, dynamic>> feed(SyncCursor? after, int limit) {
    final sorted = rows.values.toList()
      ..sort((a, b) {
        final c = (a['server_updated_at'] as String).compareTo(b['server_updated_at'] as String);
        return c != 0 ? c : (a['id'] as String).compareTo(b['id'] as String);
      });
    return sorted
        .where((r) {
          if (after == null) return true;
          final ts = DateTime.parse(r['server_updated_at'] as String);
          return ts.isAfter(after.serverUpdatedAt) ||
              (ts.isAtSameMomentAs(after.serverUpdatedAt) &&
                  (r['id'] as String).compareTo(after.id) > 0);
        })
        .take(limit)
        .toList();
  }
}

class FakeRemote implements HealthSyncRemote {
  FakeRemote(this.server);

  final FakeServer server;

  /// Runs mid-request (e.g. the user edits a row while it is being pushed).
  Future<void> Function()? duringPush;

  /// Simulates pushes that never reach the server.
  bool ignorePushes = false;

  @override
  Future<Set<String>> push(List<Map<String, Object?>> rows) async {
    if (ignorePushes) return {};
    final acked = server.upsert(rows);
    await duringPush?.call();
    return acked;
  }

  @override
  Future<List<Map<String, dynamic>>> pull({SyncCursor? after, required int limit}) async =>
      server.feed(after, limit);
}

/// One phone: in-memory copies of the six legacy tables + its own sync engine.
class Device {
  Device._(this.remote, this.service, this.dbs);

  final FakeRemote remote;
  final HealthSyncService service;
  final Map<HealthMetric, Database> dbs;

  static Future<Device> create(String name, FakeServer server) async {
    final dbs = <HealthMetric, Database>{};
    for (final spec in healthMetricSpecs) {
      final db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(singleInstance: false),
      );
      // Same shape the legacy helpers create.
      await db.execute(
        'CREATE TABLE ${spec.table} (id INTEGER PRIMARY KEY AUTOINCREMENT, '
        '${spec.dataColumns.map((c) => '$c TEXT').join(', ')})',
      );
      await SyncSchema.ensure(db, spec);
      dbs[spec.metric] = db;
    }
    final remote = FakeRemote(server);
    final service = HealthSyncService(
      remote: remote,
      state: SyncStateStore('account@$name'),
      openDatabase: (spec) async => dbs[spec.metric]!,
    );
    return Device._(remote, service, dbs);
  }

  Database get cholesterol => dbs[HealthMetric.cholesterol]!;

  /// What a legacy input screen does: a plain insert without sync fields.
  Future<int> addCholesterol(String value, {String date = '2026-09-24'}) => cholesterol.insert(
    'kolesterol',
    {'tanggal': date, 'waktu': '7:30', 'hasil': value, 'satuan': 'mg/dL', 'catatan': null},
  );

  Future<List<Map<String, Object?>>> cholesterolRows() => cholesterol.query('kolesterol');
}

void main() {
  late FakeServer server;

  setUpAll(sqfliteFfiInit);
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    server = FakeServer();
  });

  test('legacy insert gets a UUID and is pushed, then marked clean', () async {
    final phone = await Device.create('a', server);
    await phone.addCholesterol('190');

    final before = (await phone.cholesterolRows()).single;
    expect(
      before['sync_id'],
      matches(RegExp(r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$')),
    );
    expect(before['dirty'], 1);

    final report = await phone.service.sync();
    expect(report.pushed, 1);
    expect(server.rows.values.single, containsPair('value', 190));
    expect((await phone.cholesterolRows()).single['dirty'], 0);
  });

  test('a second phone receives the records in the legacy format', () async {
    final a = await Device.create('a', server);
    final b = await Device.create('b', server);
    await a.addCholesterol('190');
    await a.service.sync();

    final report = await b.service.sync();
    final row = (await b.cholesterolRows()).single;
    expect(report.pulled, 1);
    expect(row['hasil'], '190');
    expect(row['waktu'], '7:30');
    expect(row['dirty'], 0, reason: 'pulled rows are not pushed back');
  });

  test('concurrent edits converge on the latest one (last-write-wins)', () async {
    final a = await Device.create('a', server);
    final b = await Device.create('b', server);
    await a.addCholesterol('190');
    await a.service.sync();
    await b.service.sync();

    // B edits first, A edits later (both offline).
    await b.cholesterol.update('kolesterol', {'hasil': '200'});
    await Future<void>.delayed(const Duration(milliseconds: 20));
    await a.cholesterol.update('kolesterol', {'hasil': '210'});

    await a.service.sync();
    await b.service.sync(); // B's older edit loses
    await a.service.sync();

    expect((await a.cholesterolRows()).single['hasil'], '210');
    expect((await b.cholesterolRows()).single['hasil'], '210');
    expect(server.rows.values.single['value'], 210);
  });

  test('deletions propagate and leave no tombstone behind', () async {
    final a = await Device.create('a', server);
    final b = await Device.create('b', server);
    await a.addCholesterol('190');
    await a.service.sync();
    await b.service.sync();

    await a.cholesterol.delete('kolesterol');
    expect(await a.cholesterol.query(SyncSchema.tombstones), hasLength(1));
    await a.service.sync();
    expect(await a.cholesterol.query(SyncSchema.tombstones), isEmpty);

    await b.service.sync();
    expect(await b.cholesterolRows(), isEmpty);
    expect(await b.cholesterol.query(SyncSchema.tombstones), isEmpty);
  });

  test('a locally deleted row is not resurrected by an older server copy', () async {
    final a = await Device.create('a', server);
    await a.addCholesterol('190');
    await a.service.sync();

    // The delete cannot reach the server this time...
    a.remote.ignorePushes = true;
    await a.cholesterol.delete('kolesterol');
    SharedPreferences.setMockInitialValues({}); // ...and a full re-pull happens
    await a.service.sync();

    expect(await a.cholesterolRows(), isEmpty, reason: 'older server copy must not come back');
    expect(await a.cholesterol.query(SyncSchema.tombstones), hasLength(1));

    // Next time the delete gets through and the server copy becomes a tombstone.
    a.remote.ignorePushes = false;
    await a.service.sync();
    expect(server.rows.values.single['deleted_at'], isNotNull);
    expect(await a.cholesterol.query(SyncSchema.tombstones), isEmpty);
  });

  test('an edit made while the push is in flight stays dirty', () async {
    final a = await Device.create('a', server);
    await a.addCholesterol('190');
    a.remote.duringPush = () async {
      a.remote.duringPush = null;
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await a.cholesterol.update('kolesterol', {'hasil': '195'});
    };

    await a.service.sync();
    expect((await a.cholesterolRows()).single['dirty'], 1);

    await a.service.sync();
    expect(server.rows.values.single['value'], 195);
    expect((await a.cholesterolRows()).single['dirty'], 0);
  });

  test('a row the server rejects is quarantined without blocking others', () async {
    final a = await Device.create('a', server);
    await a.addCholesterol('190');
    await a.addCholesterol('180', date: '2026-09-23');
    final rows = await a.cholesterolRows();
    server.rejectIds.add(rows.first['sync_id']! as String);

    final report = await a.service.sync();
    expect(report.pushed, 1);
    expect(report.quarantined, 1);
    expect(
      {for (final r in await a.cholesterolRows()) r['hasil']: r['dirty']},
      {'190': 2, '180': 0},
    );

    // Editing the rejected row puts it back in the queue.
    server.rejectIds.clear();
    await a.cholesterol.update(
      'kolesterol',
      {'hasil': '191'},
      where: 'hasil = ?',
      whereArgs: ['190'],
    );
    await a.service.sync();
    expect(server.rows, hasLength(2));
  });

  test('unmappable rows are skipped and kept locally', () async {
    final a = await Device.create('a', server);
    await a.addCholesterol('tidak terbaca');

    final report = await a.service.sync();
    expect(report.skipped, 1);
    expect(server.rows, isEmpty);
    expect((await a.cholesterolRows()).single['dirty'], 1);
  });

  test('MVP rows that predate sync are backfilled and uploaded', () async {
    final db = await databaseFactoryFfi.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(singleInstance: false),
    );
    await db.execute(
      'CREATE TABLE kolesterol (id INTEGER PRIMARY KEY AUTOINCREMENT, tanggal TEXT, waktu TEXT, '
      'hasil TEXT, catatan TEXT, satuan TEXT)',
    );
    await db.insert('kolesterol', {'tanggal': '2025-01-01', 'hasil': '170'});

    final spec = healthMetricSpecs.firstWhere((s) => s.metric == HealthMetric.cholesterol);
    final service = HealthSyncService(
      remote: FakeRemote(server),
      state: SyncStateStore('mvp'),
      specs: [spec],
      openDatabase: (_) async => db,
    );

    expect((await service.sync()).pushed, 1);
    expect(server.rows.values.single['measured_on'], '2025-01-01');
  });
}
