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

  /// Small spacing (8px)
  final double sm;

  /// Medium spacing (16px)
  final double md;

  /// Large spacing (24px)
  final double lg;

  /// Extra large spacing (32px)
  final double xl;

  /// Extra extra large spacing (48px)
  final double xxl;

  const AppSpacing({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.xxl,
  });

  /// Default spacing scale
  static const AppSpacing standard = AppSpacing(
    xs: 4.0,
    sm: 8.0,
    md: 16.0,
    lg: 24.0,
    xl: 32.0,
    xxl: 48.0,
  );

  @override
  ThemeExtension<AppSpacing> copyWith({
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? xxl,
  }) {
    return AppSpacing(
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
      xxl: xxl ?? this.xxl,
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
      xxl: lerpDouble(xxl, other.xxl, t)!,
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

  /// Pill radius (28px) - for buttons
  final double pill;

  /// Full circle radius (999px)
  final double circle;

  const AppRadius({
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
    required this.pill,
    required this.circle,
  });

  /// Default radius scale
  static const AppRadius standard = AppRadius(
    sm: 8.0,
    md: 12.0,
    lg: 16.0,
    xl: 24.0,
    pill: 28.0,
    circle: 999.0,
  );

  @override
  ThemeExtension<AppRadius> copyWith({
    double? sm,
    double? md,
    double? lg,
    double? xl,
    double? pill,
    double? circle,
  }) {
    return AppRadius(
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
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
      pill: lerpDouble(pill, other.pill, t)!,
      circle: lerpDouble(circle, other.circle, t)!,
    );
  }
}
