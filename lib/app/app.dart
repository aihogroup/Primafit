import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../features/auth/domain/entities/app_session.dart';
import '../features/auth/presentation/providers/auth_providers.dart';
import '../features/profile/presentation/providers/profile_providers.dart';
import 'router/app_router.dart';
import 'router/app_routes.dart';

/// App shell. Besides MaterialApp it orchestrates cross-feature reactions to
/// authentication, so features never depend on each other for it:
/// - account changed (sign-in, sign-out, expiry) -> refresh profile, clear the
///   device profile cache on sign-out, and re-run the start gate (splash)
/// - password-reset deep link -> open the "new password" screen
class PrimafitApp extends ConsumerStatefulWidget {
  const PrimafitApp({super.key});

  @override
  ConsumerState<PrimafitApp> createState() => _PrimafitAppState();
}

class _PrimafitAppState extends ConsumerState<PrimafitApp> {
  /// A recovery link signs the user in and emits a session change right
  /// after; that change must not bounce them away from the reset screen.
  static const _recoveryGrace = Duration(seconds: 10);

  final _navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription<void>? _recoverySubscription;
  DateTime? _recoveryAt;

  @override
  void initState() {
    super.initState();
    _recoverySubscription = ref.read(authRepositoryProvider).watchPasswordRecovery().listen((_) {
      _recoveryAt = DateTime.now();
      _navigatorKey.currentState?.pushNamed(AppRoutes.updatePassword);
    });
  }

  @override
  void dispose() {
    _recoverySubscription?.cancel();
    super.dispose();
  }

  void _onSessionChanged(AsyncValue<AppSession?>? previous, AsyncValue<AppSession?> next) {
    // The first resolution is handled by the splash screen itself.
    if (previous == null || !previous.hasValue || !next.hasValue) return;
    final before = previous.value?.userId;
    final after = next.value?.userId;
    if (before == after) return;

    ref.invalidate(profileControllerProvider);
    if (after == null) unawaited(ref.read(profileRepositoryProvider).clearLocalCache());

    final recoveryAt = _recoveryAt;
    if (recoveryAt != null && DateTime.now().difference(recoveryAt) < _recoveryGrace) return;
    _navigatorKey.currentState?.pushNamedAndRemoveUntil(AppRoutes.splash, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(sessionProvider, _onSessionChanged);

    return MaterialApp(
      title: 'Primafit',
      navigatorKey: _navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
      onUnknownRoute: AppRouter.onUnknownRoute,
    );
  }
}
