import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../../../core/logging/app_logger.dart';
import '../domain/entities/user_profile.dart';
import '../domain/repositories/profile_repository.dart';
import 'local_profile_repository.dart';
import 'profile_row_mapper.dart';

/// Account-backed profile: `public.profiles` is the source of truth, and the
/// on-device SQLite profile is a write-through cache that legacy screens
/// (health-record analyses) still read directly.
///
/// The cache records which account it belongs to:
/// - owner == current user  -> reused (offline fallback)
/// - owner == another user  -> discarded, never merged
/// - no owner (MVP data)    -> migrated into the account on first sign-in
class SupabaseProfileRepository implements ProfileRepository {
  SupabaseProfileRepository({required this._client, required this._cache});

  static const _ownerKey = 'profile.cache_owner';

  final SupabaseClient _client;
  final LocalProfileRepository _cache;

  String? get _userId => _client.auth.currentUser?.id;

  @override
  Future<Result<UserProfile?>> getProfile() async {
    final uid = _userId;
    if (uid == null) return const Result.success(null);

    return guard(() async {
      final (cached, isLegacy) = await _readCache(uid);

      final Map<String, dynamic>? row;
      try {
        row = await _client
            .from('profiles')
            .select(ProfileRowMapper.columns)
            .eq('id', uid)
            .maybeSingle();
      } catch (e) {
        if (cached != null && !isLegacy) {
          AppLogger.warning('Profile fetch failed; using device cache', tag: 'profile', error: e);
          return cached;
        }
        rethrow;
      }
      if (row == null) return cached;

      var profile = ProfileRowMapper.fromRow(row, cached: cached);
      if (isLegacy && cached != null) {
        profile = ProfileRowMapper.fillMissing(profile, cached);
        await _client.from('profiles').update(ProfileRowMapper.toRow(profile)).eq('id', uid);
        AppLogger.info('Migrated on-device profile into account', tag: 'profile');
      }
      return _writeCache(uid, profile);
    }, onError: _failure('Gagal memuat profil.'));
  }

  @override
  Future<Result<UserProfile>> saveProfile(UserProfile profile) async {
    final uid = _userId;
    if (uid == null) return const Result.failure(AuthFailure());

    return guard(() async {
      await _client.from('profiles').update(ProfileRowMapper.toRow(profile)).eq('id', uid);
      return _writeCache(uid, profile);
    }, onError: _failure('Gagal menyimpan profil. Periksa koneksi internet Anda.'));
  }

  @override
  Future<void> clearLocalCache() async {
    try {
      await _cache.deleteAll();
      await (await SharedPreferences.getInstance()).remove(_ownerKey);
    } catch (e) {
      AppLogger.error('Could not clear profile cache', tag: 'profile', error: e);
    }
  }

  /// Returns the usable cache and whether it is unowned MVP data.
  Future<(UserProfile?, bool)> _readCache(String uid) async {
    final owner = (await SharedPreferences.getInstance()).getString(_ownerKey);
    final cached = _unwrap(await _cache.getProfile());
    if (cached == null) return (null, false);
    if (owner == null) return (cached, true);
    if (owner == uid) return (cached, false);

    // Another account's leftovers: never show or merge them.
    await clearLocalCache();
    return (null, false);
  }

  Future<UserProfile> _writeCache(String uid, UserProfile profile) async {
    final existing = _unwrap(await _cache.getProfile());
    final stored = _unwrap(await _cache.saveProfile(profile.copyWith(id: existing?.id)));
    await (await SharedPreferences.getInstance()).setString(_ownerKey, uid);
    return stored!;
  }

  static T? _unwrap<T>(Result<T> result) =>
      result.when(success: (value) => value, failure: (failure) => throw failure);

  Failure Function(Object) _failure(String message) => (error) {
    if (error is Failure) return error;
    AppLogger.error(message, tag: 'profile', error: error);
    return error is PostgrestException || error is AuthException
        ? StorageFailure(message, error)
        : NetworkFailure(message, error);
  };
}
