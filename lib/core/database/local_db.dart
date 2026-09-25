import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../logging/app_logger.dart';

/// Hook run every time a database file is opened (e.g. to add sync columns).
typedef DatabaseOpenHook = Future<void> Function(Database db);

/// Account-scoped gateway for every on-device SQLite database.
///
/// Each account gets its own folder: `<databases>/accounts/<ownerId>/<file>`,
/// so two accounts on one phone never see each other's records. Legacy
/// helpers keep computing their old path; [open] only uses its file name.
///
/// Files created by the pre-account MVP (at their old location) belong to
/// whoever uses the device first: the first owner to open them moves them
/// into its folder and "claims" the legacy data. Later owners start empty.
abstract final class LocalDb {
  static String? _ownerId;
  static final Map<String, Database> _open = {};
  static final Map<String, DatabaseOpenHook> _hooks = {};

  static const _legacyClaimFile = '.legacy_owner';

  /// Base directory for account folders; overridable in tests.
  @visibleForTesting
  static Future<String> Function() baseDirectory = getDatabasesPath;

  /// SQLite factory; tests inject the FFI factory.
  @visibleForTesting
  static DatabaseFactory? factoryOverride;

  static String? get ownerId => _ownerId;

  /// Sets the active account (`null` = signed out) and closes every database
  /// of the previous one. Legacy helpers reopen lazily for the new owner
  /// because their getters check `isOpen`.
  static Future<void> switchOwner(String? ownerId) async {
    if (ownerId == _ownerId) return;
    _ownerId = ownerId;
    final previous = _open.values.toList();
    _open.clear();
    for (final db in previous) {
      if (db.isOpen) await db.close();
    }
  }

  /// Registers [hook] for the database file named [fileName].
  static void registerOpenHook(String fileName, DatabaseOpenHook hook) => _hooks[fileName] = hook;

  /// Folder of the active account.
  static Future<String> accountDirectory() async {
    final owner = _ownerId;
    if (owner == null) {
      throw StateError('No active account: on-device data is scoped per account.');
    }
    return p.join(
      await baseDirectory(),
      'accounts',
      owner.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_'),
    );
  }

  /// Drop-in replacement for sqflite's `openDatabase`: same parameters, but
  /// the file lives in the active account's folder.
  static Future<Database> open(
    String legacyPath, {
    int? version,
    OnDatabaseConfigureFn? onConfigure,
    OnDatabaseCreateFn? onCreate,
    OnDatabaseVersionChangeFn? onUpgrade,
    OnDatabaseVersionChangeFn? onDowngrade,
    OnDatabaseOpenFn? onOpen,
    bool readOnly = false,
    bool singleInstance = true,
  }) async {
    final owner = _ownerId;
    final directory = await accountDirectory();
    final fileName = p.basename(legacyPath);
    final target = p.join(directory, fileName);
    await Directory(directory).create(recursive: true);
    await _claimLegacyFile(from: legacyPath, to: target, owner: owner!);

    final options = OpenDatabaseOptions(
      version: version,
      onConfigure: onConfigure,
      onCreate: onCreate,
      onUpgrade: onUpgrade,
      onDowngrade: onDowngrade,
      onOpen: onOpen,
      readOnly: readOnly,
      singleInstance: singleInstance,
    );
    final db = await (factoryOverride ?? databaseFactory).openDatabase(target, options: options);
    await _hooks[fileName]?.call(db);

    // The owner may have changed while this open was in flight.
    if (_ownerId != owner) {
      await db.close();
      throw StateError('Account changed while opening $fileName.');
    }
    _open[target] = db;
    return db;
  }

  static Future<void> _claimLegacyFile({
    required String from,
    required String to,
    required String owner,
  }) async {
    if (p.equals(from, to) || !File(from).existsSync() || File(to).existsSync()) return;

    final claimFile = File(p.join(await baseDirectory(), 'accounts', _legacyClaimFile));
    if (claimFile.existsSync()) {
      if (claimFile.readAsStringSync().trim() != owner) return;
    } else {
      await claimFile.parent.create(recursive: true);
      await claimFile.writeAsString(owner, flush: true);
      AppLogger.info('Legacy on-device data claimed by the current account', tag: 'localdb');
    }

    for (final suffix in const ['', '-journal', '-wal', '-shm']) {
      final source = File('$from$suffix');
      if (!source.existsSync()) continue;
      try {
        await source.rename('$to$suffix');
      } on FileSystemException {
        // Different volume: copy, then delete.
        await source.copy('$to$suffix');
        await source.delete();
      }
    }
  }
}
