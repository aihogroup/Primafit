import 'package:flutter_test/flutter_test.dart';
import 'package:primafit/app/router/app_routes.dart';
import 'package:primafit/features/auth/domain/entities/app_session.dart';
import 'package:primafit/features/auth/domain/entities/user_role.dart';
import 'package:primafit/features/onboarding/domain/start_route.dart';
import 'package:primafit/features/profile/domain/entities/user_profile.dart';

const _complete = UserProfile(name: 'Budi', gender: 'Laki-laki', birthDate: '01-01-1990');
const _nameOnly = UserProfile(name: 'Budi');

void main() {
  final signedIn = AppSession(userId: 'u1', roles: const {});

  group('with Supabase (account required)', () {
    String route({AppSession? session, UserProfile? profile, bool introSeen = true}) =>
        resolveStartRoute(
          requiresAccount: true,
          session: session,
          profile: profile,
          introSeen: introSeen,
        );

    test('first launch, signed out -> intro', () {
      expect(route(introSeen: false), AppRoutes.intro);
    });

    test('returning, signed out -> sign in', () {
      expect(route(), AppRoutes.signIn);
    });

    test('signed in, only the sign-up name known -> profile setup', () {
      expect(route(session: signedIn, profile: _nameOnly), AppRoutes.profileSetup);
    });

    test('signed in with complete profile -> home', () {
      expect(route(session: signedIn, profile: _complete), AppRoutes.home);
    });

    test('signed in but profile unavailable -> profile setup, never sign in', () {
      expect(route(session: signedIn, introSeen: false), AppRoutes.profileSetup);
    });

    test('complete profile lands on the active role dashboard', () {
      expect(
        resolveStartRoute(
          requiresAccount: true,
          session: AppSession(userId: 'd', roles: const {UserRole.doctor}),
          profile: _complete,
          introSeen: true,
          activeRole: UserRole.doctor,
        ),
        AppRoutes.doctorDashboard,
      );
    });

    test('every role has a landing route', () {
      expect({for (final r in UserRole.values) AppRoutes.homeFor(r)}, hasLength(5));
      expect(AppRoutes.homeFor(UserRole.superadmin), AppRoutes.adminDashboard);
    });

    test('intro leads to sign in', () {
      expect(routeAfterIntro(requiresAccount: true), AppRoutes.signIn);
    });
  });

  group('offline MVP mode', () {
    final local = AppSession.local();

    test('no profile, first launch -> intro', () {
      expect(
        resolveStartRoute(requiresAccount: false, session: local, profile: null, introSeen: false),
        AppRoutes.intro,
      );
    });

    test('complete device profile -> home', () {
      expect(
        resolveStartRoute(
          requiresAccount: false,
          session: local,
          profile: _complete,
          introSeen: false,
        ),
        AppRoutes.home,
      );
    });

    test('intro leads to the profile form', () {
      expect(routeAfterIntro(requiresAccount: false), AppRoutes.profileSetup);
    });
  });
}
