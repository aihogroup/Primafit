import '../../../../core/error/result.dart';
import '../entities/user_profile.dart';

abstract interface class ProfileRepository {
  /// Returns `null` when the person has not completed onboarding yet.
  Future<Result<UserProfile?>> getProfile();

  /// Inserts or updates the profile and returns the stored version.
  Future<Result<UserProfile>> saveProfile(UserProfile profile);

  /// Removes personal data cached on this device (called when a session ends).
  Future<void> clearLocalCache();
}
