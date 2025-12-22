import 'package:flutter/material.dart';

/// Card theme configuration for the Centabit app.
///
/// Provides clean, elevated cards with rounded corners.
class AppCardTheme {
  // Private constructor to prevent instantiation
  AppCardTheme._();

  /// Light mode card theme
  static CardThemeData light(ColorScheme colorScheme) {
    return CardThemeData(
      color: colorScheme.surface,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.8),
      surfaceTintColor: colorScheme.surfaceTint,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        // side: BorderSide(color: colorScheme.outline, width: 1),
      ),
      margin: const EdgeInsets.all(0),
      clipBehavior: Clip.antiAlias,
    );
  }

  /// Dark mode card theme
  static CardThemeData dark(ColorScheme colorScheme) {
    return CardThemeData(
      color: colorScheme.surface,
      shadowColor: colorScheme.shadow.withValues(alpha: 0.2),
      surfaceTintColor: colorScheme.surfaceTint,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.all(8),
      clipBehavior: Clip.antiAlias,
    );
  }
}
