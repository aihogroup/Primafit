import 'package:shared_preferences/shared_preferences.dart';

import 'health_sync_remote.dart';

/// Per-account sync bookkeeping (pull cursor + last successful sync).
class SyncStateStore {
  SyncStateStore(this.ownerId);

  final String ownerId;

  String get _cursorKey => 'sync.health.cursor.$ownerId';
  String get _lastSyncKey => 'sync.health.last.$ownerId';

  Future<SyncCursor?> readCursor() async {
    final raw = (await SharedPreferences.getInstance()).getString(_cursorKey);
    final sep = raw?.indexOf('|') ?? -1;
    if (raw == null || sep < 0) return null;
    final ts = DateTime.tryParse(raw.substring(0, sep));
    return ts == null ? null : (serverUpdatedAt: ts, id: raw.substring(sep + 1));
  }

  Future<void> writeCursor(SyncCursor cursor) async => (await SharedPreferences.getInstance())
      .setString(_cursorKey, '${cursor.serverUpdatedAt.toUtc().toIso8601String()}|${cursor.id}');

  Future<DateTime?> readLastSync() async {
    final raw = (await SharedPreferences.getInstance()).getString(_lastSyncKey);
    return raw == null ? null : DateTime.tryParse(raw);
  }

  Future<void> writeLastSync(DateTime at) async =>
      (await SharedPreferences.getInstance()).setString(_lastSyncKey, at.toUtc().toIso8601String());
}
