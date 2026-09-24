import 'user_role.dart';

/// The authenticated (or local/offline) actor using the app.
///
/// A single account can hold several roles (a doctor is also a user), so the
/// UI picks an [activeRole] to decide which shell/dashboard to show.
class AppSession {
  AppSession({
    required this.userId,
    required Set<UserRole> roles,
    this.email,
    this.isLocalOnly = false,
    UserRole? activeRole,
  }) : roles = Set.unmodifiable({UserRole.user, ...roles}),
       activeRole = activeRole ?? _defaultActiveRole({UserRole.user, ...roles});

  /// Offline MVP mode: no backend account, data lives only on the device.
  factory AppSession.local() =>
      AppSession(userId: 'local', roles: const {UserRole.user}, isLocalOnly: true);

  final String userId;
  final String? email;
  final Set<UserRole> roles;
  final UserRole activeRole;
  final bool isLocalOnly;

  bool hasRole(UserRole role) => roles.contains(role);

  bool canAccess(Set<UserRole> allowed) => allowed.any(roles.contains);

  AppSession switchRole(UserRole role) {
    if (!hasRole(role)) {
      throw StateError('Session does not hold role ${role.dbValue}');
    }
    return AppSession(
      userId: userId,
      email: email,
      roles: roles,
      isLocalOnly: isLocalOnly,
      activeRole: role,
    );
  }

  /// Professional roles take precedence so a verified doctor lands on the
  /// doctor dashboard by default.
  static UserRole _defaultActiveRole(Set<UserRole> roles) {
    const priority = [
      UserRole.superadmin,
      UserRole.doctor,
      UserRole.institution,
      UserRole.partner,
      UserRole.user,
    ];
    return priority.firstWhere(roles.contains);
  }
}
