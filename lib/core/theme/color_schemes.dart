import 'package:flutter/material.dart';

/// Color schemes for the Centabit app using Material 3.
///
/// Provides both light and dark color schemes based on the app's design system.
class AppColorSchemes {
  // Private constructor to prevent instantiation
  AppColorSchemes._();

  /// Light color scheme
  ///
  /// Features:
  /// - White background with clean aesthetic
  /// - Dark charcoal primary color for buttons and emphasis
  /// - Ensures WCAG AA contrast compliance
  static final ColorScheme light = ColorScheme.fromSeed(
    seedColor: const Color(0xFF2D9D8F), // Teal seed for Material 3 generation
    brightness: Brightness.light,
    // Primary colors - dark charcoal for buttons and emphasis
    primary: const Color(0xFF2D3436),
    onPrimary: const Color(0xFFFFFFFF),
    primaryContainer: const Color(0xFFDFE6E9),
    onPrimaryContainer: const Color(0xFF0B0E0F),
    // Secondary colors - medium gray for less emphasis
    secondary: const Color(0xFF95A5A6),
    onSecondary: const Color(0xFFFFFFFF),
    secondaryContainer: const Color(0xFFECF0F1),
    onSecondaryContainer: const Color(0xFF2C3539),
    // Tertiary colors - soft blue for accents
    tertiary: const Color(0xFF74B9FF),
    onTertiary: const Color(0xFFFFFFFF),
    tertiaryContainer: const Color(0xFFDBEDFF),
    onTertiaryContainer: const Color(0xFF1A2E3F),
    // Error colors
    error: const Color(0xFFE74C3C),
    onError: const Color(0xFFFFFFFF),
    errorContainer: const Color(0xFFFDEDED),
    onErrorContainer: const Color(0xFF3D1311),
    // Background and surface colors
    surface: const Color(0xFFF8F9FA),
    onSurface: const Color(0xFF2D3436),
    onSurfaceVariant: const Color(0xFF636E72),
    // Outline colors
    outline: const Color(0xFFB2BEC3),
    outlineVariant: const Color(0xFFDFE6E9),
    // Shadow and scrim
    shadow: const Color(0xFF000000),
    scrim: const Color(0xFF000000),
    // Inverse colors for snackbars and tooltips
    inverseSurface: const Color(0xFF2D3436),
    onInverseSurface: const Color(0xFFF8F9FA),
    inversePrimary: const Color(0xFF74B9FF),
  );

  /// Dark color scheme
  ///
  /// Features:
  /// - Dark charcoal background
  /// - Lighter colors for visibility
  /// - Maintains visual hierarchy and accessibility
  static final ColorScheme dark = ColorScheme.fromSeed(
    seedColor: const Color(0xFF2D9D8F), // Same teal seed for consistency
    brightness: Brightness.dark,
    // Primary colors - lighter blue for visibility on dark background
    primary: const Color(0xFFECEDF9),
    onPrimary: const Color(0xFF1A2E3F),
    primaryContainer: const Color(0xFF34495E),
    onPrimaryContainer: const Color(0xFFDBEDFF),
    // Secondary colors
    secondary: const Color(0xFF95A5A6),
    onSecondary: const Color(0xFF2D3436),
    secondaryContainer: const Color(0xFF4A5559),
    onSecondaryContainer: const Color(0xFFECF0F1),
    // Tertiary colors - bright teal for accents
    tertiary: const Color(0xFF55E6C1),
    onTertiary: const Color(0xFF003D32),
    tertiaryContainer: const Color(0xFF005F4B),
    onTertiaryContainer: const Color(0xFFB3FFE9),
    // Error colors
    error: const Color(0xFFE74C3C),
    onError: const Color(0xFF2D0A07),
    errorContainer: const Color(0xFF5D1F1A),
    onErrorContainer: const Color(0xFFFDEDED),
    // Background and surface colors
    surface: const Color(0xFF2F3640),
    onSurface: const Color(0xFFF5F6FA),
    onSurfaceVariant: const Color(0xFFDFE4EA),
    // Outline colors
    outline: const Color(0xFF57606F),
    outlineVariant: const Color(0xFF3C444F),
    // Shadow and scrim
    shadow: const Color(0xFF000000),
    scrim: const Color(0xFF000000),
    // Inverse colors
    inverseSurface: const Color(0xFFF5F6FA),
    onInverseSurface: const Color(0xFF2F3640),
    inversePrimary: const Color(0xFF2D3436),
  );
}
