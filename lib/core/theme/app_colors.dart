import 'package:flutter/material.dart';

/// Design tokens: colour palette.
///
/// Values are extracted from the existing UI (e.g. `0xFF64D1DE` is used
/// ~1,300 times as the brand teal) so migrating a screen to tokens is a
/// visual no-op. New code must use these instead of raw `Color(0x...)`.
abstract final class AppColors {
  // Brand
  static const Color primary = Color(0xFF64D1DE);
  static const Color primaryDark = Color(0xFF59BECA);
  static const Color primarySurface = Color(0xFFE3F7F9);
  static const Color secondary = Color(0xFFE9458D); // women's health accent
  static const Color tertiary = Color(0xFF9C27B0);

  // Semantic
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color danger = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Neutrals
  static const Color background = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF8F9FA);
  static const Color textPrimary = Color(0xDD000000);
  static const Color textSecondary = Color(0x8A000000);
  static const Color border = Color(0xFFE0E0E0);

  /// Accent per role so each role's shell is recognisable at a glance.
  static const Color roleUser = primary;
  static const Color roleDoctor = Color(0xFF2196F3);
  static const Color roleInstitution = Color(0xFF00BFA5);
  static const Color rolePartner = Color(0xFFFF9800);
  static const Color roleSuperadmin = Color(0xFF6C63FF);
}
