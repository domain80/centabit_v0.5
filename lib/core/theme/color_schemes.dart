import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Color schemes for the Centabit app using Material 3.
///
/// Provides both light and dark color schemes based on the app's design system.
class AppColorSchemes {
  // Private constructor to prevent instantiation
  AppColorSchemes._();

  /// Light color scheme using v0.4 color palette
  ///
  /// Features:
  /// - Gray-dominant aesthetic with coral accents
  /// - Professional, minimal look from v0.4
  /// - Ensures WCAG AA contrast compliance
  static final ColorScheme light = ColorScheme.fromSeed(
    seedColor: AppColors.grayGray7, // v0.4 primary - generates harmonious variants
    brightness: Brightness.light,
    // Primary colors - gray dominant (v0.4 style)
    primary: AppColors.grayGray7, // #495057 - v0.4's main primary
    onPrimary: AppColors.white, // #ffffff
    primaryContainer: AppColors.grayGray2, // #e9ecef - lighter gray
    onPrimaryContainer: AppColors.grayGray9, // #212529 - darkest gray
    // Secondary colors - coral accent (v0.4 style)
    secondary: AppColors.secondarySecondary700, // #e17a60 - coral
    onSecondary: AppColors.white, // #ffffff
    secondaryContainer: AppColors.secondarySecondary200, // #fbece9 - light coral
    onSecondaryContainer: AppColors.secondarySecondary800, // #90331b - dark coral
    // Tertiary colors - blue for accents
    tertiary: AppColors.blueBlue6, // #228be6
    onTertiary: AppColors.white, // #ffffff
    tertiaryContainer: AppColors.blueBlue1, // #d0ebff
    onTertiaryContainer: AppColors.blueBlue9, // #1864ab
    // Error colors
    error: AppColors.redRed8, // #e03131
    onError: AppColors.white, // #ffffff
    errorContainer: AppColors.redRed1, // #ffe3e3
    onErrorContainer: AppColors.redRed9, // #c92a2a
    // Background and surface colors
    surface: AppColors.grayGray0, // #f8f9fa - lightest gray
    onSurface: AppColors.grayGray7, // #495057
    onSurfaceVariant: AppColors.grayGray6, // #868e96
    surfaceContainerHighest: AppColors.grayGray2, // #e9ecef
    // Outline colors
    outline: AppColors.grayGray5, // #adb5bd
    outlineVariant: AppColors.grayGray3, // #dee2e6
    // Shadow and scrim
    shadow: AppColors.black,
    scrim: AppColors.black,
    // Inverse colors for snackbars/tooltips
    inverseSurface: AppColors.grayGray8, // #343a40
    onInverseSurface: AppColors.grayGray0, // #f8f9fa
    inversePrimary: AppColors.blueBlue3, // #74c0fc
  );

  /// Dark color scheme using v0.4 color palette
  ///
  /// Features:
  /// - Dark charcoal background
  /// - Lighter grays for visibility
  /// - Maintains visual hierarchy and accessibility
  static final ColorScheme dark = ColorScheme.fromSeed(
    seedColor: AppColors.grayGray8, // v0.4 dark primary
    brightness: Brightness.dark,
    // Primary colors - lighter gray for visibility on dark bg
    primary: AppColors.grayGray6, // #868e96 - lighter for visibility
    onPrimary: AppColors.grayGray9, // #212529
    primaryContainer: AppColors.grayGray7, // #495057
    onPrimaryContainer: AppColors.grayGray2, // #e9ecef
    // Secondary colors - coral accent (same as light)
    secondary: AppColors.secondarySecondary700, // #e17a60
    onSecondary: AppColors.grayGray9, // #212529
    secondaryContainer: AppColors.secondarySecondary800, // #90331b
    onSecondaryContainer: AppColors.secondarySecondary200, // #fbece9
    // Tertiary colors - brighter blue for dark theme
    tertiary: AppColors.blueBlue3, // #74c0fc - brighter
    onTertiary: AppColors.blueBlue9, // #1864ab
    tertiaryContainer: AppColors.blueBlue8, // #1971c2
    onTertiaryContainer: AppColors.blueBlue1, // #d0ebff
    // Error colors
    error: AppColors.redRed8, // #e03131
    onError: const Color(0xFF2d0a07), // Dark red
    errorContainer: AppColors.redRed9, // #c92a2a
    onErrorContainer: AppColors.redRed1, // #ffe3e3
    // Background and surface colors
    surface: AppColors.grayGray9, // #212529 - darkest gray
    onSurface: AppColors.grayGray1, // #f1f3f5 - light gray
    onSurfaceVariant: AppColors.grayGray4, // #ced4da
    surfaceContainerHighest: AppColors.grayGray8, // #343a40
    // Outline colors
    outline: AppColors.grayGray6, // #868e96
    outlineVariant: AppColors.grayGray7, // #495057
    // Shadow and scrim
    shadow: AppColors.black,
    scrim: AppColors.black,
    // Inverse colors
    inverseSurface: AppColors.grayGray1, // #f1f3f5
    onInverseSurface: AppColors.grayGray9, // #212529
    inversePrimary: AppColors.grayGray7, // #495057
  );
}
