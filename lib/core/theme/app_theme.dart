import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

/// Central [ThemeData]. Screens should read colours/typography from
/// `Theme.of(context)` instead of re-declaring `GoogleFonts.poppins(...)`
/// and hex colours inline.
///
/// Component themes (AppBar, Card, Input) are intentionally not overridden
/// yet: legacy screens style those inline, and a global override would
/// silently restyle them. They are added as screens migrate to tokens.
abstract final class AppTheme {
  static ThemeData light() {
    // Brand teal is used as the seed only: pinning `primary` to #64D1DE would
    // put white text on a ~2:1 contrast background (fails WCAG AA). Material 3
    // derives accessible tones from the seed instead.
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      error: AppColors.danger,
      surface: AppColors.background,
    );
    final textTheme = GoogleFonts.poppinsTextTheme().apply(
      bodyColor: AppColors.textPrimary,
      displayColor: AppColors.textPrimary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.background,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(AppSpacing.minTouchTarget),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.input),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryDark,
          minimumSize: const Size.fromHeight(AppSpacing.minTouchTarget),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.input),
        ),
      ),
    );
  }
}
