import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/env.dart';
import '../../data/database_profile.dart';
import '../../data/local_profile_repository.dart';
import '../../data/supabase_profile_repository.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

/// Account-backed profile when Supabase is configured; otherwise the single
/// on-device profile of the offline MVP.
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final local = LocalProfileRepository(ProfileDatabaseHelper());
  if (Env.isSupabaseConfigured) {
    return SupabaseProfileRepository(client: Supabase.instance.client, cache: local);
  }
  return local;
});

/// Single source of truth for the current profile. Every screen that shows
/// the name/avatar (home header, profile page, splash routing) watches this,
/// so a save on one screen updates all others without manual reloads.
/// The app shell invalidates it whenever the signed-in account changes.
final profileControllerProvider = AsyncNotifierProvider<ProfileController, UserProfile?>(
  ProfileController.new,
);

class ProfileController extends AsyncNotifier<UserProfile?> {
  ProfileRepository get _repository => ref.read(profileRepositoryProvider);

  @override
  Future<UserProfile?> build() async {
    final result = await _repository.getProfile();
    return result.when(success: (profile) => profile, failure: (f) => throw f);
  }

  /// Saves and publishes the new profile. Returns the failure message, or
  /// `null` on success, so the calling screen can show feedback.
  Future<String?> save(UserProfile profile) async {
    final result = await _repository.saveProfile(profile);
    return result.when(
      success: (saved) {
        state = AsyncData(saved);
        return null;
      },
      failure: (f) => f.message,
    );
  }
}
