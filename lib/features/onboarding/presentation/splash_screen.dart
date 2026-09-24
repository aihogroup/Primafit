import 'package:primafit/app/router/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:primafit/core/logging/app_logger.dart';
import 'package:primafit/features/auth/presentation/providers/auth_providers.dart';
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
        if (status == AnimationStatus.completed) {
          final hasProfile = await _checkUserProfile();
          
          if (!hasProfile) {
            // Navigate to profile page with editing mode on
            if (!mounted) return;
            Navigator.pushReplacementNamed(context, AppRoutes.intro);
          } else {
            // Navigate to home page as usual
            if (!mounted) return;
            Navigator.pushReplacementNamed(context, AppRoutes.home);
          }
        }
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

  Future<bool> _checkUserProfile() async {
    try {
      // Resolve the session during the splash animation so the RoleGuard on
      // the next (guarded) route renders immediately instead of a spinner.
      final (_, profile) = (
        await ref.read(sessionProvider.future),
        await ref.read(profileControllerProvider.future),
      );
      return profile?.isComplete ?? false;
    } catch (e) {
      AppLogger.warning('Profile check failed; routing to onboarding', tag: 'splash', error: e);
      return false;
    }
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