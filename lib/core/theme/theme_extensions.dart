import 'dart:ui';

import 'package:flutter/material.dart';

/// Custom color extension for app-specific colors not covered by Material 3.
///
/// Includes gradient colors, semantic colors, and other branding elements.
/// Access via: `Theme.of(context).extension<AppCustomColors>()`
@immutable
class AppCustomColors extends ThemeExtension<AppCustomColors> {
  /// Gradient start color (mint green for light, darker teal for dark)
  final Color gradientStart;

  /// Gradient end color (light lavender for light, darker purple for dark)
  final Color gradientEnd;

  /// Success color for positive states
  final Color success;

  /// Warning color for caution states
  final Color warning;

  /// Info color for informational states
  final Color info;

  const AppCustomColors({
    required this.gradientStart,
    required this.gradientEnd,
    required this.success,
    required this.warning,
    required this.info,
  });

  /// Light mode custom colors
  static const AppCustomColors light = AppCustomColors(
    gradientStart: Color(0xFFE8F5F0), // Mint green
    gradientEnd: Color(0xFFF5E8F5), // Light lavender
    success: Color(0xFF00B894), // Emerald green
    warning: Color(0xFFFDCB6E), // Warm yellow
    info: Color(0xFF74B9FF), // Soft blue
  );

  /// Dark mode custom colors
  static const AppCustomColors dark = AppCustomColors(
    gradientStart: Color(0xFF1E3A32), // Dark teal
    gradientEnd: Color(0xFF3A1E3A), // Dark purple
    success: Color(0xFF00B894), // Emerald green (same for consistency)
    warning: Color(0xFFFDCB6E), // Warm yellow (same for consistency)
    info: Color(0xFF74B9FF), // Soft blue (same for consistency)
  );

  @override
  ThemeExtension<AppCustomColors> copyWith({
    Color? gradientStart,
    Color? gradientEnd,
    Color? success,
    Color? warning,
    Color? info,
  }) {
    return AppCustomColors(
      gradientStart: gradientStart ?? this.gradientStart,
      gradientEnd: gradientEnd ?? this.gradientEnd,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
    );
  }

  @override
  ThemeExtension<AppCustomColors> lerp(
    covariant ThemeExtension<AppCustomColors>? other,
    double t,
  ) {
    if (other is! AppCustomColors) {
      return this;
    }

    return AppCustomColors(
      gradientStart: Color.lerp(gradientStart, other.gradientStart, t)!,
      gradientEnd: Color.lerp(gradientEnd, other.gradientEnd, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
    );
  }
}

/// Spacing extension for consistent spacing values throughout the app.
///
/// Access via: `Theme.of(context).extension<AppSpacing>()`
@immutable
class AppSpacing extends ThemeExtension<AppSpacing> {
  /// Extra small spacing (4px)
  final double xs;

  /// Small radius (8px)
  final double sm;

  /// Medium radius (12px)
  final double md;

  /// Large radius (16px)
  final double lg;

  /// Extra large radius (24px)
  final double xl;

  /// Extra large radius 2 (32px)
  final double xl2;

  /// Extra large radius 3 (40px)
  final double xl3;

  /// Extra large radius 4 (48px)
  final double xl4;

  /// Extra large radius 5 (56px)
  final double xl5;

  /// Extra large radius 6 (64px)
  final double xl6;

  /// Pill radius (28px) - for buttons
  final double pill;

  /// Full circle radius (999px)
  final double circle;

  const AppSpacing({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xl2,
    required this.xl3,
    required this.xl4,
    required this.xl5,
    required this.xl6,
    required this.pill,
    required this.circle,
  });

  /// Default radius scale
  static const AppSpacing standard = AppSpacing(
    xs: 4.0,
    sm: 8.0,
    md: 12.0,
    lg: 16.0,
    xl: 24.0,
    xl2: 32.0,
    xl3: 40.0,
    xl4: 48.0,
    xl5: 56.0,
    xl6: 64.0,
    pill: 28.0,
    circle: 999.0,
  );

  @override
  ThemeExtension<AppSpacing> copyWith({
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xl2,
    double? xl3,
    double? xl4,
    double? xl5,
    double? xl6,
    double? pill,
    double? circle,
  }) {
    return AppSpacing(
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xl2: xl2 ?? this.xl2,
      xl3: xl3 ?? this.xl3,
      xl4: xl4 ?? this.xl4,
      xl5: xl5 ?? this.xl5,
      xl6: xl6 ?? this.xl6,
      pill: pill ?? this.pill,
      circle: circle ?? this.circle,
    );
  }

  @override
  ThemeExtension<AppSpacing> lerp(
    covariant ThemeExtension<AppSpacing>? other,
    double t,
  ) {
    if (other is! AppSpacing) {
      return this;
    }

    return AppSpacing(
      xs: lerpDouble(xs, other.xs, t)!,
      sm: lerpDouble(sm, other.sm, t)!,
      md: lerpDouble(md, other.md, t)!,
      lg: lerpDouble(lg, other.lg, t)!,
      xl: lerpDouble(xl, other.xl, t)!,
      xl2: lerpDouble(xl2, other.xl2, t)!,
      xl3: lerpDouble(xl3, other.xl3, t)!,
      xl4: lerpDouble(xl4, other.xl4, t)!,
      xl5: lerpDouble(xl5, other.xl5, t)!,
      xl6: lerpDouble(xl6, other.xl6, t)!,
      pill: lerpDouble(pill, other.pill, t)!,
      circle: lerpDouble(circle, other.circle, t)!,
    );
  }
}

/// Border radius extension for consistent rounded corners.
///
/// Access via: `Theme.of(context).extension<AppRadius>()`
@immutable
class AppRadius extends ThemeExtension<AppRadius> {
  /// Small radius (8px)
  final double sm;

  /// Medium radius (12px)
  final double md;

  /// Large radius (16px)
  final double lg;

  /// Extra large radius (24px)
  final double xl;

  /// Extra large radius 2 (32px)
  final double xl2;

  /// Extra large radius 3 (40px)
  final double xl3;

  /// Extra large radius 4 (48px)
  final double xl4;

  /// Extra large radius 5 (56px)
  final double xl5;

  /// Extra large radius 6 (64px)
  final double xl6;

  /// Pill radius (28px) - for buttons
  final double pill;

  /// Full circle radius (999px)
  final double circle;

  const AppRadius({
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xl2,
    required this.xl3,
    required this.xl4,
    required this.xl5,
    required this.xl6,
    required this.pill,
    required this.circle,
  });

  /// Default radius scale
  static const AppRadius standard = AppRadius(
    sm: 8.0,
    md: 12.0,
    lg: 16.0,
    xl: 24.0,
    xl2: 32.0,
    xl3: 40.0,
    xl4: 48.0,
    xl5: 56.0,
    xl6: 64.0,
    pill: 28.0,
    circle: 999.0,
  );

  @override
  ThemeExtension<AppRadius> copyWith({
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xl2,
    double? xl3,
    double? xl4,
    double? xl5,
    double? xl6,
    double? pill,
    double? circle,
  }) {
    return AppRadius(
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xl2: xl2 ?? this.xl2,
      xl3: xl3 ?? this.xl3,
      xl4: xl4 ?? this.xl4,
      xl5: xl5 ?? this.xl5,
      xl6: xl6 ?? this.xl6,
      pill: pill ?? this.pill,
      circle: circle ?? this.circle,
    );
  }

  @override
  ThemeExtension<AppRadius> lerp(
    covariant ThemeExtension<AppRadius>? other,
    double t,
  ) {
    if (other is! AppRadius) {
      return this;
    }

    return AppRadius(
      sm: lerpDouble(sm, other.sm, t)!,
      md: lerpDouble(md, other.md, t)!,
      lg: lerpDouble(lg, other.lg, t)!,
      xl: lerpDouble(xl, other.xl, t)!,
      xl2: lerpDouble(xl2, other.xl2, t)!,
      xl3: lerpDouble(xl3, other.xl3, t)!,
      xl4: lerpDouble(xl4, other.xl4, t)!,
      xl5: lerpDouble(xl5, other.xl5, t)!,
      xl6: lerpDouble(xl6, other.xl6, t)!,
      pill: lerpDouble(pill, other.pill, t)!,
      circle: lerpDouble(circle, other.circle, t)!,
    );
  }
}
