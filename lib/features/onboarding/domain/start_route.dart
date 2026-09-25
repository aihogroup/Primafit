import '../../../app/router/app_routes.dart';
import '../../auth/domain/entities/app_session.dart';
import '../../auth/domain/entities/user_role.dart';
import '../../profile/domain/entities/user_profile.dart';

/// Decides where the app goes after the splash screen.
///
/// [requiresAccount] is true when a backend (Supabase) is configured: then a
/// signed-in account is mandatory. Without it the app runs in offline MVP
/// mode with a single on-device profile.
String resolveStartRoute({
  required bool requiresAccount,
  required AppSession? session,
  required UserProfile? profile,
  required bool introSeen,
  UserRole activeRole = UserRole.user,
}) {
  if (requiresAccount && session == null) {
    return introSeen ? AppRoutes.signIn : AppRoutes.intro;
  }
  if (profile?.isComplete ?? false) return AppRoutes.homeFor(activeRole);
  if (!requiresAccount && !introSeen) return AppRoutes.intro;
  return AppRoutes.profileSetup;
}

/// Where the intro carousel leads once finished or skipped.
String routeAfterIntro({required bool requiresAccount}) =>
    requiresAccount ? AppRoutes.signIn : AppRoutes.profileSetup;
