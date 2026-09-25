import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:primafit/core/database/local_db.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  late Directory root;
  late String legacyDir;

  setUpAll(sqfliteFfiInit);

  setUp(() async {
    root = await Directory.systemTemp.createTemp('primafit_localdb_');
    legacyDir = p.join(root.path, 'legacy');
    await Directory(legacyDir).create();
    LocalDb.baseDirectory = () async => root.path;
    LocalDb.factoryOverride = databaseFactoryFfi;
    await LocalDb.switchOwner(null);
  });

  tearDown(() async {
    await LocalDb.switchOwner(null);
    await root.delete(recursive: true);
  });

  Future<void> createLegacyDb(String name, int rows) async {
    final db = await databaseFactoryFfi.openDatabase(p.join(legacyDir, name));
    await db.execute('CREATE TABLE t (v TEXT)');
    for (var i = 0; i < rows; i++) {
      await db.insert('t', {'v': 'row$i'});
    }
    await db.close();
  }

  test('opening without an active account fails loudly', () async {
    expect(() => LocalDb.open(p.join(legacyDir, 'x.db')), throwsStateError);
  });

  test('each account gets its own database file', () async {
    await LocalDb.switchOwner('user-a');
    final a = await LocalDb.open(
      p.join(legacyDir, 'notes.db'),
      version: 1,
      onCreate: (db, _) async {
        await db.execute('CREATE TABLE t (v TEXT)');
      },
    );
    await a.insert('t', {'v': 'milik A'});

    await LocalDb.switchOwner('user-b');
    expect(a.isOpen, isFalse, reason: 'switching account closes the previous databases');
    final b = await LocalDb.open(
      p.join(legacyDir, 'notes.db'),
      version: 1,
      onCreate: (db, _) async {
        await db.execute('CREATE TABLE t (v TEXT)');
      },
    );

    expect(await b.query('t'), isEmpty);
    expect(b.path, contains(p.join('accounts', 'user-b')));
  });

  test('legacy MVP data moves to the first account only', () async {
    await createLegacyDb('kolesterol.db', 3);
    await createLegacyDb('bpjs_data.db', 1);

    await LocalDb.switchOwner('first-user');
    final first = await LocalDb.open(p.join(legacyDir, 'kolesterol.db'));
    expect(await first.query('t'), hasLength(3));
    expect(File(p.join(legacyDir, 'kolesterol.db')).existsSync(), isFalse);

    await LocalDb.switchOwner('second-user');
    await LocalDb.open(
      p.join(legacyDir, 'bpjs_data.db'),
      version: 1,
      onCreate: (db, _) async {
        await db.execute('CREATE TABLE t (v TEXT)');
      },
    );
    expect(
      File(p.join(legacyDir, 'bpjs_data.db')).existsSync(),
      isTrue,
      reason: 'data claimed by the first account is never handed to another',
    );

    await LocalDb.switchOwner('first-user');
    final later = await LocalDb.open(p.join(legacyDir, 'bpjs_data.db'));
    expect(
      await later.query('t'),
      hasLength(1),
      reason: 'the claiming account still gets it later',
    );
  });

  test('open hooks run for their file', () async {
    var calls = 0;
    LocalDb.registerOpenHook('hooked.db', (db) async => calls++);
    await LocalDb.switchOwner('user-a');
    await LocalDb.open(p.join(legacyDir, 'hooked.db'));
    await LocalDb.open(p.join(legacyDir, 'other.db'));
    expect(calls, 1);
  });
}
