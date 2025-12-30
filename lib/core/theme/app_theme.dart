import 'package:flutter/material.dart';

import 'color_schemes.dart';
import 'component_themes/app_bar_theme.dart';
import 'component_themes/button_theme.dart';
import 'component_themes/card_theme.dart';
import 'component_themes/input_decoration_theme.dart';
import 'text_theme.dart';
import 'theme_extensions.dart';

/// Main theme orchestrator for the Centabit app.
///
/// Combines all theme components into cohesive ThemeData objects
/// for both light and dark modes.
///
/// Usage:
/// ```dart
/// MaterialApp(
///   theme: AppTheme.light,
///   darkTheme: AppTheme.dark,
///   themeMode: ThemeMode.system,
/// )
/// ```
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  /// Light theme configuration
  ///
  /// Features:
  /// - White background with subtle gradients
  /// - Dark text for optimal readability
  /// - Material 3 design system
  /// - Rounded, modern component styling
  static ThemeData get light {
    final colorScheme = AppColorSchemes.light;
    final textTheme = AppTextTheme.lightTextTheme(
      colorScheme.onSurface,
      colorScheme.onSurface,
    );

    return ThemeData(
      // Enable Material 3
      useMaterial3: true,

      // Color scheme
      colorScheme: colorScheme,

      // Typography
      textTheme: textTheme,

      // Primary text theme (for text on primary color)
      primaryTextTheme: AppTextTheme.lightTextTheme(
        colorScheme.onPrimary,
        colorScheme.onPrimary,
      ),

      // Component themes
      elevatedButtonTheme: AppButtonTheme.elevatedButtonTheme(colorScheme),
      outlinedButtonTheme: AppButtonTheme.outlinedButtonTheme(colorScheme),
      textButtonTheme: AppButtonTheme.textButtonTheme(colorScheme),
      iconButtonTheme: AppButtonTheme.iconButtonTheme(colorScheme),
      floatingActionButtonTheme:
          AppButtonTheme.floatingActionButtonTheme(colorScheme),

      inputDecorationTheme: AppInputDecorationTheme.light(colorScheme),
      cardTheme: AppCardTheme.light(colorScheme),
      appBarTheme: AppAppBarTheme.light(colorScheme, textTheme),

      // Dialog theme - uses textTheme references
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
        elevation: 3,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: textTheme.headlineMedium?.copyWith(
          color: colorScheme.onSurface,
        ),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),

      // Bottom sheet theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent, // Disable Material 3 tint overlay
        elevation: 3,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.15),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        modalBackgroundColor: colorScheme.surface,
        modalElevation: 3,
      ),

      // Snackbar theme - uses textTheme reference
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onInverseSurface,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 6,
      ),

      // Divider theme
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surface,
        deleteIconColor: colorScheme.onSurfaceVariant,
        disabledColor: colorScheme.onSurface.withValues(alpha: 0.12),
        selectedColor: colorScheme.secondaryContainer,
        secondarySelectedColor: colorScheme.primaryContainer,
        shadowColor: colorScheme.shadow,
        labelStyle: textTheme.labelLarge?.copyWith(
          color: colorScheme.onSurface,
        ),
        secondaryLabelStyle: textTheme.labelLarge?.copyWith(
          color: colorScheme.onSecondaryContainer,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.onPrimary;
            }
            return colorScheme.outline;
          },
        ),
        trackColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.primary;
            }
            return colorScheme.surfaceContainerHighest;
          },
        ),
      ),

      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.primary;
            }
            return null;
          },
        ),
        checkColor: WidgetStateProperty.all(colorScheme.onPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // Radio theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.primary;
            }
            return colorScheme.onSurfaceVariant;
          },
        ),
      ),

      // Scaffold background
      scaffoldBackgroundColor: colorScheme.surface,

      // Visual density
      visualDensity: VisualDensity.adaptivePlatformDensity,

      // Platform brightness
      brightness: Brightness.light,

      // Custom theme extensions
      extensions: <ThemeExtension<dynamic>>[
        AppCustomColors.light,
        AppSpacing.standard,
        AppRadius.standard,
      ],
    );
  }

  /// Dark theme configuration
  ///
  /// Features:
  /// - Dark charcoal background
  /// - Light text for optimal readability
  /// - Material 3 design system
  /// - Maintains visual hierarchy from light theme
  static ThemeData get dark {
    final colorScheme = AppColorSchemes.dark;
    final textTheme = AppTextTheme.darkTextTheme(
      colorScheme.onSurface,
      colorScheme.onSurface,
    );

    return ThemeData(
      // Enable Material 3
      useMaterial3: true,

      // Color scheme
      colorScheme: colorScheme,

      // Typography
      textTheme: textTheme,

      // Primary text theme (for text on primary color)
      primaryTextTheme: AppTextTheme.darkTextTheme(
        colorScheme.onPrimary,
        colorScheme.onPrimary,
      ),

      // Component themes
      elevatedButtonTheme: AppButtonTheme.elevatedButtonTheme(colorScheme),
      outlinedButtonTheme: AppButtonTheme.outlinedButtonTheme(colorScheme),
      textButtonTheme: AppButtonTheme.textButtonTheme(colorScheme),
      iconButtonTheme: AppButtonTheme.iconButtonTheme(colorScheme),
      floatingActionButtonTheme:
          AppButtonTheme.floatingActionButtonTheme(colorScheme),

      inputDecorationTheme: AppInputDecorationTheme.dark(colorScheme),
      cardTheme: AppCardTheme.dark(colorScheme),
      appBarTheme: AppAppBarTheme.dark(colorScheme, textTheme),

      // Dialog theme - uses textTheme references
      dialogTheme: DialogThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: colorScheme.surfaceTint,
        elevation: 3,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        titleTextStyle: textTheme.headlineMedium?.copyWith(
          color: colorScheme.onSurface,
        ),
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),

      // Bottom sheet theme
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surface,
        surfaceTintColor: Colors.transparent, // Disable Material 3 tint overlay
        elevation: 3,
        shadowColor: colorScheme.shadow.withValues(alpha: 0.3),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        modalBackgroundColor: colorScheme.surface,
        modalElevation: 3,
      ),

      // Snackbar theme - uses textTheme reference
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colorScheme.inverseSurface,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: colorScheme.onInverseSurface,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 6,
      ),

      // Divider theme
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surface,
        deleteIconColor: colorScheme.onSurfaceVariant,
        disabledColor: colorScheme.onSurface.withValues(alpha: 0.12),
        selectedColor: colorScheme.secondaryContainer,
        secondarySelectedColor: colorScheme.primaryContainer,
        shadowColor: colorScheme.shadow,
        labelStyle: textTheme.labelLarge?.copyWith(
          color: colorScheme.onSurface,
        ),
        secondaryLabelStyle: textTheme.labelLarge?.copyWith(
          color: colorScheme.onSecondaryContainer,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.onPrimary;
            }
            return colorScheme.outline;
          },
        ),
        trackColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.primary;
            }
            return colorScheme.surfaceContainerHighest;
          },
        ),
      ),

      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.primary;
            }
            return null;
          },
        ),
        checkColor: WidgetStateProperty.all(colorScheme.onPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),

      // Radio theme
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.primary;
            }
            return colorScheme.onSurfaceVariant;
          },
        ),
      ),

      // Scaffold background
      scaffoldBackgroundColor: colorScheme.surface,

      // Visual density
      visualDensity: VisualDensity.adaptivePlatformDensity,

      // Platform brightness
      brightness: Brightness.dark,

      // Custom theme extensions
      extensions: <ThemeExtension<dynamic>>[
        AppCustomColors.dark,
        AppSpacing.standard,
        AppRadius.standard,
      ],
    );
  }
}
