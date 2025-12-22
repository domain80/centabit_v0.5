import 'package:flutter/material.dart';

/// Input decoration theme configuration for the Centabit app.
///
/// Provides clean, rounded form fields with consistent styling.
class AppInputDecorationTheme {
  // Private constructor to prevent instantiation
  AppInputDecorationTheme._();

  /// Light mode input decoration theme
  static InputDecorationTheme light(ColorScheme colorScheme) {
    return _baseInputDecorationTheme(colorScheme);
  }

  /// Dark mode input decoration theme
  static InputDecorationTheme dark(ColorScheme colorScheme) {
    return _baseInputDecorationTheme(colorScheme);
  }

  /// Base input decoration theme
  static InputDecorationTheme _baseInputDecorationTheme(
    ColorScheme colorScheme,
  ) {
    return InputDecorationTheme(
      filled: true,
      fillColor: colorScheme.surface,

      // Content padding for consistent spacing
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),

      // Border styling - rounded corners matching design
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: colorScheme.outline,
          width: 1,
        ),
      ),

      // Enabled border (default state)
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: colorScheme.outline,
          width: 1,
        ),
      ),

      // Focused border (when user taps/clicks)
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: colorScheme.primary,
          width: 2,
        ),
      ),

      // Error border
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: colorScheme.error,
          width: 1,
        ),
      ),

      // Focused error border
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: colorScheme.error,
          width: 2,
        ),
      ),

      // Disabled border
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: colorScheme.onSurface.withValues(alpha: 0.12),
          width: 1,
        ),
      ),

      // Label styling
      labelStyle: TextStyle(
        color: colorScheme.onSurfaceVariant,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      floatingLabelStyle: TextStyle(
        color: colorScheme.primary,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),

      // Hint text styling
      hintStyle: TextStyle(
        color: colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),

      // Helper text styling
      helperStyle: TextStyle(
        color: colorScheme.onSurfaceVariant,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),

      // Error text styling
      errorStyle: TextStyle(
        color: colorScheme.error,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),

      // Prefix and suffix icon colors
      prefixIconColor: colorScheme.onSurfaceVariant,
      suffixIconColor: colorScheme.onSurfaceVariant,

      // Icon color
      iconColor: colorScheme.onSurfaceVariant,

      // Constraints
      constraints: const BoxConstraints(
        minHeight: 56,
      ),

      // Floating label behavior
      floatingLabelBehavior: FloatingLabelBehavior.auto,

      // Align label with hint
      alignLabelWithHint: true,
    );
  }
}
