import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../../../core/logging/app_logger.dart';
import '../domain/entities/user_profile.dart';
import '../domain/repositories/profile_repository.dart';
import 'database_profile.dart';

/// On-device profile storage (SQLite `health_data.db`).
class LocalProfileRepository implements ProfileRepository {
  LocalProfileRepository(this._db);

  final ProfileDatabaseHelper _db;

  @override
  Future<Result<UserProfile?>> getProfile() => guard(() async {
    final rows = await _db.getProfiles();
    return rows.isEmpty ? null : UserProfile.fromMap(rows.first);
  }, onError: _storageFailure('Gagal memuat profil.'));

  @override
  Future<Result<UserProfile>> saveProfile(UserProfile profile) => guard(() async {
    final stored = profile.copyWith(photoPath: await _persistPhoto(profile.photoPath));
    if (stored.id != null) {
      await _db.updateProfile(stored.toMap(), stored.id!);
      return stored;
    }
    final id = await _db.insertProfile(stored.toMap());
    return stored.copyWith(id: id);
  }, onError: _storageFailure('Gagal menyimpan profil.'));

  /// image_picker returns a file in the OS cache, which Android may purge at
  /// any time. Copy it into the app documents folder so the avatar survives.
  Future<String?> _persistPhoto(String? path) async {
    if (path == null || path.isEmpty) return path;
    final docs = await getApplicationDocumentsDirectory();
    final avatarDir = Directory(p.join(docs.path, 'avatar'));
    if (p.isWithin(avatarDir.path, path)) return path;

    final source = File(path);
    if (!await source.exists()) return path;
    await avatarDir.create(recursive: true);
    final target = p.join(
      avatarDir.path,
      'profile_${DateTime.now().millisecondsSinceEpoch}${p.extension(path)}',
    );
    await source.copy(target);
    return target;
  }

  Failure Function(Object) _storageFailure(String message) => (error) {
    AppLogger.error(message, tag: 'profile', error: error);
    return StorageFailure(message, error);
  };
}
