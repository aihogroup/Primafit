import 'package:flutter_test/flutter_test.dart';
import 'package:primafit/features/auth/domain/entities/app_session.dart';
import 'package:primafit/features/auth/domain/entities/user_role.dart';

void main() {
  test('every session implicitly holds the user role', () {
    final session = AppSession(userId: 'u1', roles: const {UserRole.doctor});

    expect(session.roles, containsAll([UserRole.user, UserRole.doctor]));
  });

  test('professional role is the default active role', () {
    expect(AppSession(userId: 'u1', roles: const {UserRole.doctor}).activeRole, UserRole.doctor);
    expect(
      AppSession(userId: 'u1', roles: const {UserRole.partner, UserRole.superadmin}).activeRole,
      UserRole.superadmin,
    );
    expect(AppSession.local().activeRole, UserRole.user);
  });

  test('canAccess checks for any overlap with allowed roles', () {
    final doctor = AppSession(userId: 'u1', roles: const {UserRole.doctor});

    expect(doctor.canAccess({UserRole.user}), isTrue);
    expect(doctor.canAccess({UserRole.doctor, UserRole.superadmin}), isTrue);
    expect(doctor.canAccess({UserRole.superadmin}), isFalse);
  });

  test('switchRole only allows held roles', () {
    final doctor = AppSession(userId: 'u1', roles: const {UserRole.doctor});

    expect(doctor.switchRole(UserRole.user).activeRole, UserRole.user);
    expect(() => doctor.switchRole(UserRole.superadmin), throwsStateError);
  });

  test('roles cannot be mutated from outside', () {
    final session = AppSession.local();

    expect(() => session.roles.add(UserRole.superadmin), throwsUnsupportedError);
  });
}
