import 'dart:async';

import 'package:centabit/core/router/navigation/nav_cubit.dart';
import 'package:centabit/core/theme/tabler_icons.dart';
import 'package:centabit/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Search bar with filter button
///
/// Layout:
/// - Pill-shaped search input (white background)
///   - "Search" placeholder on left
///   - X clear button on right (inside the pill)
/// - Circular dark calendar/filter button (separate, on far right)
class NavSearchBar extends StatefulWidget {
  const NavSearchBar({super.key});

  @override
  State<NavSearchBar> createState() => _NavSearchBarState();
}

class _NavSearchBarState extends State<NavSearchBar> {
  late TextEditingController _controller;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _clearSearch() {
    _controller.clear();
    context.read<NavCubit>().updateSearchQuery('');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = theme.extension<AppSpacing>()!;

    return BlocBuilder<NavCubit, NavState>(
      builder: (context, navState) {
        return Row(
          children: [
            // Search input (white pill with X button inside)
            Expanded(
              child: Container(
                height: 48,
                padding: EdgeInsets.only(
                  left: spacing.md,
                  right: spacing.sm,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    // Text input
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        onChanged: (value) {
                          _debounceTimer?.cancel();
                          _debounceTimer =
                              Timer(const Duration(milliseconds: 300), () {
                            context.read<NavCubit>().updateSearchQuery(value);
                          });
                          setState(() {});
                        },
                        textAlignVertical: TextAlignVertical.center,
                        expands: true,
                        maxLines: null,
                        decoration: InputDecoration(
                          hintText: navState.searchScope.isNotEmpty
                              ? 'Search ${navState.searchScope}'
                              : 'Search',
                          hintStyle: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 16,
                          ),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    // X clear button (inside the pill)
                    GestureDetector(
                      onTap: _clearSearch,
                      child: Icon(
                        TablerIcons.x,
                        color: colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: spacing.md),
            // Calendar filter button (dark circle)
            GestureDetector(
              onTap: () {
                // TODO: Implement filter/calendar functionality
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface,
                  shape: BoxShape.circle,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      TablerIcons.calendar,
                      color: colorScheme.surface,
                      size: 22,
                    ),
                    // Code brackets overlay
                    Positioned(
                      right: 10,
                      bottom: 10,
                      child: Icon(
                        TablerIcons.code,
                        color: colorScheme.surface,
                        size: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
