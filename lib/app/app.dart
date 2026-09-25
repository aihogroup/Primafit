import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/database/local_db.dart';
import '../core/theme/app_theme.dart';
import '../features/auth/domain/entities/app_session.dart';
import '../features/auth/presentation/providers/auth_providers.dart';
import '../features/health_record/presentation/providers/health_sync_providers.dart';
import '../features/profile/presentation/providers/profile_providers.dart';
import 'router/app_router.dart';
import 'router/app_routes.dart';

/// App shell. Besides MaterialApp it orchestrates cross-feature reactions to
/// authentication, so features never depend on each other for it:
/// - active account -> on-device databases scoped to it (LocalDb) + health sync
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

  static const _periodicSync = Duration(minutes: 5);

  late final AppLifecycleListener _lifecycle;
  Timer? _syncTimer;

  @override
  void initState() {
    super.initState();
    // Push fresh records when the app is backgrounded; catch up on resume.
    _lifecycle = AppLifecycleListener(
      onResume: () {
        _syncInBackground();
        _syncTimer ??= Timer.periodic(_periodicSync, (_) => _syncInBackground());
      },
      onPause: () {
        _syncInBackground();
        _syncTimer?.cancel();
        _syncTimer = null;
      },
    );
    _syncTimer = Timer.periodic(_periodicSync, (_) => _syncInBackground());
    _recoverySubscription = ref.read(authRepositoryProvider).watchPasswordRecovery().listen((_) {
      _recoveryAt = DateTime.now();
      _navigatorKey.currentState?.pushNamed(AppRoutes.updatePassword);
    });
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _syncTimer?.cancel();
    _recoverySubscription?.cancel();
    super.dispose();
  }

  void _onSessionChanged(AsyncValue<AppSession?>? previous, AsyncValue<AppSession?> next) {
    if (!next.hasValue) return;
    final after = next.value?.userId;
    final before = previous?.value?.userId;
    final isFirstResolution = previous == null || !previous.hasValue;

    // On-device databases follow the account (set synchronously, before the
    // splash or any screen opens a database).
    if (after != null) {
      unawaited(LocalDb.switchOwner(after));
      unawaited(ref.read(healthSyncControllerProvider.notifier).sync());
    }
    // The first resolution is routed by the splash screen itself.
    if (isFirstResolution || before == after) return;

    ref.invalidate(profileControllerProvider);
    if (after == null) unawaited(_endSession());

    final recoveryAt = _recoveryAt;
    if (recoveryAt != null && DateTime.now().difference(recoveryAt) < _recoveryGrace) return;
    _navigatorKey.currentState?.pushNamedAndRemoveUntil(AppRoutes.splash, (_) => false);
  }

  /// Wipes the cached profile of the account that just left, then releases
  /// its databases (order matters: the cache lives in the account folder).
  Future<void> _endSession() async {
    await ref.read(profileRepositoryProvider).clearLocalCache();
    await LocalDb.switchOwner(null);
  }

  void _syncInBackground() => unawaited(ref.read(healthSyncControllerProvider.notifier).sync());

  @override
  Widget build(BuildContext context) {
    // Also keeps the session stream alive for the whole app: Riverpod 3 pauses
    // providers without listeners, and a paused stream never emits, so one-off
    // reads such as `ref.read(sessionProvider.future)` in the splash rely on it.
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
