import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/logging/app_logger.dart';
import '../../domain/entities/user_role.dart';
import 'auth_providers.dart';

/// The role whose shell/dashboard is shown. Users holding several roles
/// (e.g. a doctor is also a user) can switch; the choice is remembered per
/// account. A remembered role the account no longer holds (revoked or
/// suspended) is ignored and the session default is used.
final activeRoleProvider = AsyncNotifierProvider<ActiveRoleController, UserRole>(
  ActiveRoleController.new,
);

class ActiveRoleController extends AsyncNotifier<UserRole> {
  static String _key(String userId) => 'auth.active_role.$userId';

  @override
  Future<UserRole> build() async {
    final session = await ref.watch(sessionProvider.future);
    if (session == null) return UserRole.user;
    try {
      final saved = UserRole.tryParse(
        (await SharedPreferences.getInstance()).getString(_key(session.userId)),
      );
      if (saved != null && session.hasRole(saved)) return saved;
    } catch (e) {
      AppLogger.warning('Could not read active role', tag: 'auth', error: e);
    }
    return session.activeRole;
  }

  /// Switches to [role] if the session holds it; returns whether it did.
  Future<bool> select(UserRole role) async {
    final session = await ref.read(sessionProvider.future);
    if (session == null || !session.hasRole(role)) return false;
    state = AsyncData(role);
    try {
      await (await SharedPreferences.getInstance()).setString(_key(session.userId), role.dbValue);
    } catch (e) {
      AppLogger.warning('Could not save active role', tag: 'auth', error: e);
    }
    return true;
  }
}
