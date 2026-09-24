import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primafit/core/config/env.dart';
import 'package:primafit/core/logging/app_logger.dart';
import 'package:primafit/features/onboarding/data/onboarding_preferences.dart';
import 'package:primafit/features/onboarding/domain/start_route.dart';
import 'package:primafit/features/auth/domain/entities/app_session.dart';
import 'package:primafit/features/auth/presentation/providers/auth_providers.dart';
import 'package:primafit/features/profile/domain/entities/user_profile.dart';
import 'package:primafit/features/profile/presentation/providers/profile_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )

      ..addStatusListener((status) async {
        if (status != AnimationStatus.completed) return;
        final route = await _resolveStartRoute();
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, route);
      });
    _fadeIn = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _controller.forward();
  }

  /// Resolves session, profile and onboarding state while the animation runs,
  /// so the next (guarded) route renders immediately instead of a spinner.
  Future<String> _resolveStartRoute() async {
    final introSeen = await ref.read(onboardingPreferencesProvider).isIntroSeen();
    AppSession? session;
    UserProfile? profile;
    try {
      session = await ref.read(sessionProvider.future);
      if (session != null) profile = await ref.read(profileControllerProvider.future);
    } catch (e) {
      // Profile unavailable (e.g. offline on first launch): a signed-in user
      // lands on the profile form, which retries; never on the sign-in page.
      AppLogger.warning('Start route check failed', tag: 'splash', error: e);
    }
    return resolveStartRoute(
      requiresAccount: Env.isSupabaseConfigured,
      session: session,
      profile: profile,
      introSeen: introSeen,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/Splash/background.png',
              fit: BoxFit.cover,
            ),
          ),
          Align(
            alignment: Alignment(0, -0.4),
            child: Image.asset(
              'assets/Splash/logo.png',
              width: 150,
            ),
          ),
          Align(
            alignment: Alignment(0, 0.7),
            child: FadeTransition(
              opacity: _fadeIn,
              child: SlideTransition(
                position: _slideUp,
                child: Image.asset(
                  'assets/Splash/branding.png',
                  width: 250,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}