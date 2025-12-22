import 'package:flutter/material.dart';

/// Button theme configuration for the Centabit app.
///
/// Provides the signature rounded pill-shaped button style
/// seen throughout the app design.
class AppButtonTheme {
  // Private constructor to prevent instantiation
  AppButtonTheme._();

  /// Elevated button theme - primary action buttons
  ///
  /// Features:
  /// - Fully rounded pill shape (BorderRadius 28px)
  /// - Minimum height of 56px
  /// - Horizontal padding of 24px
  /// - Dark background with white text in light mode
  /// - Light background with dark text in dark mode
  static ElevatedButtonThemeData elevatedButtonTheme(ColorScheme colorScheme) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        disabledBackgroundColor: colorScheme.onSurface.withValues(alpha: 0.12),
        disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
        minimumSize: const Size(double.infinity, 56),
        maximumSize: const Size(double.infinity, 56),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        elevation: 2,
        animationDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  /// Outlined button theme - secondary action buttons
  ///
  /// Features:
  /// - Same rounded pill shape
  /// - Transparent background with colored border
  /// - Colored text matching the border
  static OutlinedButtonThemeData outlinedButtonTheme(ColorScheme colorScheme) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.primary,
        disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
        minimumSize: const Size(double.infinity, 56),
        maximumSize: const Size(double.infinity, 56),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
        ),
        side: WidgetStateBorderSide.resolveWith(
          (states) {
            if (states.contains(WidgetState.disabled)) {
              return BorderSide(
                color: colorScheme.onSurface.withValues(alpha: 0.12),
                width: 1.5,
              );
            }
            return BorderSide(
              color: colorScheme.primary,
              width: 1.5,
            );
          },
        ),
        animationDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  /// Text button theme - tertiary actions, links
  ///
  /// Features:
  /// - Minimal styling with no background or border
  /// - Colored text
  /// - Same height and padding for consistency
  static TextButtonThemeData textButtonTheme(ColorScheme colorScheme) {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
        disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        animationDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  /// Icon button theme - for icon-only buttons
  ///
  /// Features:
  /// - Circular shape (48x48 touch target)
  /// - Colored icon
  static IconButtonThemeData iconButtonTheme(ColorScheme colorScheme) {
    return IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: colorScheme.onSurface,
        disabledForegroundColor: colorScheme.onSurface.withValues(alpha: 0.38),
        minimumSize: const Size(48, 48),
        padding: const EdgeInsets.all(12),
        shape: const CircleBorder(),
      ),
    );
  }

  /// Floating action button theme
  ///
  /// Features:
  /// - Circular or rounded square shape
  /// - Primary color background
  /// - Elevated with shadow
  static FloatingActionButtonThemeData floatingActionButtonTheme(
    ColorScheme colorScheme,
  ) {
    return FloatingActionButtonThemeData(
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      elevation: 6,
      highlightElevation: 12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
