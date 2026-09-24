import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/logging/app_logger.dart';

/// Small device-level onboarding flags (not personal data).
class OnboardingPreferences {
  static const _introSeenKey = 'onboarding.intro_seen';

  Future<bool> isIntroSeen() async {
    try {
      return (await SharedPreferences.getInstance()).getBool(_introSeenKey) ?? false;
    } catch (e) {
      AppLogger.warning('Could not read onboarding flag', tag: 'onboarding', error: e);
      return false;
    }
  }

  Future<void> markIntroSeen() async {
    try {
      await (await SharedPreferences.getInstance()).setBool(_introSeenKey, true);
    } catch (e) {
      AppLogger.warning('Could not save onboarding flag', tag: 'onboarding', error: e);
    }
  }
}

final onboardingPreferencesProvider = Provider<OnboardingPreferences>(
  (ref) => OnboardingPreferences(),
);
