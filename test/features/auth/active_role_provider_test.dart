import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:primafit/features/auth/domain/entities/app_session.dart';
import 'package:primafit/features/auth/domain/entities/user_role.dart';
import 'package:primafit/features/auth/presentation/providers/active_role_provider.dart';
import 'package:primafit/features/auth/presentation/providers/auth_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Riverpod 3 pauses providers nobody listens to, so a stream provider read
/// once never emits. In the app the shell (`PrimafitApp`) listens to the
/// session for its whole lifetime; the tests do the same.
ProviderContainer _container(AppSession session) {
  final container = ProviderContainer.test(
    overrides: [sessionProvider.overrideWith((ref) => Stream.value(session))],
  );
  container.listen(sessionProvider, (_, _) {});
  return container;
}

void main() {
  final doctor = AppSession(userId: 'd1', roles: const {UserRole.doctor});

  test('defaults to the session priority role', () async {
    SharedPreferences.setMockInitialValues({});
    final container = _container(doctor);

    expect(await container.read(activeRoleProvider.future), UserRole.doctor);
  });

  test('switching is remembered per account', () async {
    SharedPreferences.setMockInitialValues({});
    final container = _container(doctor);
    await container.read(activeRoleProvider.future);

    expect(await container.read(activeRoleProvider.notifier).select(UserRole.user), isTrue);
    expect(container.read(activeRoleProvider).value, UserRole.user);

    final reopened = _container(doctor);
    expect(await reopened.read(activeRoleProvider.future), UserRole.user);
  });

  test('cannot switch to a role the account does not hold', () async {
    SharedPreferences.setMockInitialValues({});
    final container = _container(doctor);
    await container.read(activeRoleProvider.future);

    expect(await container.read(activeRoleProvider.notifier).select(UserRole.superadmin), isFalse);
    expect(container.read(activeRoleProvider).value, UserRole.doctor);
  });

  test('a remembered role that was revoked is ignored', () async {
    SharedPreferences.setMockInitialValues({'auth.active_role.d1': 'doctor'});
    final revoked = AppSession(userId: 'd1', roles: const {UserRole.user});

    expect(await _container(revoked).read(activeRoleProvider.future), UserRole.user);
  });
}
