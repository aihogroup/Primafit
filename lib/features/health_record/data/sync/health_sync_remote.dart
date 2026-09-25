import 'package:supabase_flutter/supabase_flutter.dart';

/// Position in the server change feed: rows are pulled ordered by
/// (server_updated_at, id), strictly after this point.
typedef SyncCursor = ({DateTime serverUpdatedAt, String id});

/// Thrown for a batch the server rejected because of its content (constraint
/// violation). The engine then retries row by row to isolate the bad row.
class SyncDataException implements Exception {
  const SyncDataException(this.message);
  final String message;
  @override
  String toString() => 'SyncDataException: $message';
}

abstract interface class HealthSyncRemote {
  /// Upserts [rows] (max 500) and returns the ids the server acknowledged.
  Future<Set<String>> push(List<Map<String, Object?>> rows);

  /// Changes after [after] (all rows when `null`), oldest first.
  Future<List<Map<String, dynamic>>> pull({SyncCursor? after, required int limit});
}

class SupabaseHealthSyncRemote implements HealthSyncRemote {
  SupabaseHealthSyncRemote(this._client);

  static const _columns =
      'id, metric, measured_on, measured_time, value, value2, weight_kg, height_cm, unit, note, '
      'client_updated_at, deleted_at, server_updated_at';

  final SupabaseClient _client;

  @override
  Future<Set<String>> push(List<Map<String, Object?>> rows) async {
    try {
      final result = await _client.rpc<List<dynamic>>(
        'sync_health_measurements',
        params: {'p_rows': rows},
      );
      return {for (final r in result) (r as Map<String, dynamic>)['id'] as String};
    } on PostgrestException catch (e) {
      // Class 22 (data exception) / 23 (integrity constraint violation).
      if (e.code != null && (e.code!.startsWith('22') || e.code!.startsWith('23'))) {
        throw SyncDataException('${e.code}: ${e.message}');
      }
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> pull({SyncCursor? after, required int limit}) async {
    var query = _client.from('health_measurements').select(_columns);
    if (after != null) {
      final ts = after.serverUpdatedAt.toUtc().toIso8601String();
      query = query.or('server_updated_at.gt.$ts,and(server_updated_at.eq.$ts,id.gt.${after.id})');
    }
    final rows = await query.order('server_updated_at').order('id').limit(limit);
    return List<Map<String, dynamic>>.from(rows);
  }
}
