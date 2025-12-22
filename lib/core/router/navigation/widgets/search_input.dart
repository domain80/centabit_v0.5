import 'dart:ui';

import 'package:centabit/core/router/navigation/nav_cubit.dart';
import 'package:centabit/core/theme/tabler_icons.dart';
import 'package:centabit/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Full-size search input widget for active search state
///
/// Shows search field with:
/// - Search icon (left)
/// - Text input (center)
/// - Clear button when text present (right)
/// - Filter/Calendar button (far right)
///
/// Automatically receives focus when displayed and propagates queries to NavCubit
class SearchInput extends StatefulWidget {
  final FocusNode focusNode;

  const SearchInput({
    super.key,
    required this.focusNode,
  });

  @override
  State<SearchInput> createState() => _SearchInputState();
}

class _SearchInputState extends State<SearchInput> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    // Auto-focus when widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = theme.extension<AppSpacing>()!;
    final radius = theme.extension<AppRadius>()!;

    return BlocBuilder<NavCubit, NavState>(
      builder: (context, navState) {
        return Container(
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
                  vertical: spacing.sm,
                ),
                child: Row(
                  children: [
                    // Search icon
                    Icon(
                      TablerIcons.search,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      size: 20,
                    ),
                    SizedBox(width: spacing.sm),

                    // Text input
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: widget.focusNode,
                        onChanged: (value) {
                          context.read<NavCubit>().updateSearchQuery(value);
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          hintText: navState.searchScope.isNotEmpty
                              ? 'Search ${navState.searchScope}'
                              : 'Search',
                          hintStyle: TextStyle(
                            color:
                                colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        style: TextStyle(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),

                    // Clear button (shows when text present)
                    if (_controller.text.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _controller.clear();
                          context.read<NavCubit>().updateSearchQuery('');
                          setState(() {});
                        },
                        child: Icon(
                          TablerIcons.x,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                          size: 20,
                        ),
                      )
                    else
                      SizedBox(width: 20),

                    SizedBox(width: spacing.sm),

                    // Filter/Calendar button
                    GestureDetector(
                      onTap: () {
                        // TODO: Implement filter/calendar functionality
                      },
                      child: Icon(
                        TablerIcons.calendar,
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
