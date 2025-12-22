import 'dart:ui';

import 'package:centabit/core/router/navigation/nav_cubit.dart';
import 'package:centabit/core/theme/tabler_icons.dart';
import 'package:centabit/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Minimized search bar shown when search is disabled
///
/// Compact indicator (32px height) showing:
/// - Search icon
/// - Placeholder text
/// - Tap to activate full search mode
class MinimizedSearchBar extends StatelessWidget {
  const MinimizedSearchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = theme.extension<AppSpacing>()!;
    final radius = theme.extension<AppRadius>()!;

    return GestureDetector(
      onTap: () {
        context.read<NavCubit>().toggleSearchMode();
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: spacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius.xl),
          border: Border.all(
            color: colorScheme.outline.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius.xl),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 0.5, sigmaY: 2.0),
            child: Container(
              color: colorScheme.surface.withValues(alpha: 0.95),
              padding: EdgeInsets.symmetric(
                horizontal: spacing.md,
                vertical: spacing.xs,
              ),
              child: Row(
                children: [
                  // Search icon
                  Icon(
                    TablerIcons.search,
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                    size: 16,
                  ),
                  SizedBox(width: spacing.sm),

                  // Placeholder text
                  Text(
                    'Search',
                    style: TextStyle(
                      color: colorScheme.onSurface.withValues(alpha: 0.5),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
