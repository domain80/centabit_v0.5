import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography configuration for the Centabit app.
///
/// Uses Inter font family with Material 3 typography scale.
/// Base body size: 16px (industry standard for readability)
/// All sizes scaled proportionally (+14% from original scale)
class AppTextTheme {
  // Private constructor to prevent instantiation
  AppTextTheme._();

  /// Light mode text theme with Inter font
  static TextTheme lightTextTheme(Color onSurface, Color onBackground) {
    return GoogleFonts.rubikTextTheme(_baseTextTheme).apply(bodyColor: onBackground, displayColor: onSurface);
  }

  /// Dark mode text theme with Inter font
  static TextTheme darkTextTheme(Color onSurface, Color onBackground) {
    return GoogleFonts.rubikTextTheme(_baseTextTheme).apply(bodyColor: onBackground, displayColor: onSurface);
  }

  /// Base text theme with updated Material 3 typography scale
  /// Scaled proportionally with 16px base body text
  static const TextTheme _baseTextTheme = TextTheme(
    // Display styles - largest text (headlines, hero sections)
    // Scaled +14% from original
    displayLarge: TextStyle(fontSize: 65, fontWeight: FontWeight.w400, letterSpacing: -0.25, height: 1.12),
    displayMedium: TextStyle(fontSize: 51, fontWeight: FontWeight.w400, letterSpacing: 0, height: 1.16),
    displaySmall: TextStyle(fontSize: 41, fontWeight: FontWeight.w400, letterSpacing: 0, height: 1.22),

    // Headline styles - section headers
    // Scaled +14% from original
    headlineLarge: TextStyle(fontSize: 36, fontWeight: FontWeight.w600, letterSpacing: 0, height: 1.25),
    headlineMedium: TextStyle(fontSize: 32, fontWeight: FontWeight.w600, letterSpacing: 0, height: 1.29),
    headlineSmall: TextStyle(fontSize: 28, fontWeight: FontWeight.w600, letterSpacing: 0, height: 1.33),

    // Title styles - emphasized text, taglines
    // Scaled +14% from original
    titleLarge: TextStyle(fontSize: 25, fontWeight: FontWeight.w500, letterSpacing: 0, height: 1.27),
    titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, letterSpacing: 0.15, height: 1.50),
    titleSmall: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.1, height: 1.43),

    // Body styles - main content text
    // Base size increased to 16px (industry standard)
    bodyLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w400, letterSpacing: 0.5, height: 1.50),
    bodyMedium: TextStyle(
      fontSize: 16, // PRIMARY BODY TEXT - increased from 14px
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      height: 1.43,
    ),
    bodySmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: 0.4, height: 1.33),

    // Label styles - buttons, chips, tabs
    // Scaled +14% from original
    labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, letterSpacing: 0.1, height: 1.43),
    labelMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.5, height: 1.33),
    labelSmall: TextStyle(
      fontSize: 12, // Now meets WCAG AA minimum - increased from 11px
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      height: 1.45,
    ),
  );
}
