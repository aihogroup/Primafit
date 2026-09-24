import 'package:flutter/widgets.dart';

/// Design tokens: 4-pt spacing scale, radii and minimum touch target.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;

  static const EdgeInsets page = EdgeInsets.all(md);

  /// Material / WCAG minimum touch target.
  static const double minTouchTarget = 48;
}

abstract final class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;

  static const BorderRadius card = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius input = BorderRadius.all(Radius.circular(md));
}
