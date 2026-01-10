import 'dart:ui';

import 'package:centabit/core/router/navigation/nav_cubit.dart';
import 'package:centabit/core/router/navigation/searchable_nav_container.dart';
import 'package:centabit/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Main navigation shell widget for authenticated pages
///
/// Provides semantic layout with:
/// - Content area that extends behind the nav bar
/// - Bottom navigation bar supporting two variants:
///   1. Simple Nav (no search capability)
///   2. Searchable Nav (with animated search mode)
/// - Proper spacing and padding
/// - Auto-shows navbar on route changes
///
/// Follows v0.4 semantic patterns for clean, composable architecture.
class AppNavShell extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const AppNavShell({super.key, required this.navigationShell});

  @override
  State<AppNavShell> createState() => _AppNavShellState();
}

class _AppNavShellState extends State<AppNavShell> {
  String? _previousRoute;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkRouteChange();
  }

  @override
  void didUpdateWidget(AppNavShell oldWidget) {
    super.didUpdateWidget(oldWidget);
    _checkRouteChange();
  }

  /// Check if route changed and show navbar
  void _checkRouteChange() {
    final currentRoute = GoRouterState.of(context).uri.toString();

    if (_previousRoute != null && _previousRoute != currentRoute) {
      // Route changed - show navbar
      context.read<NavCubit>().setNavBarVisible(true);
    }

    _previousRoute = currentRoute;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavCubit, NavState>(
      // Only rebuild when relevant state changes (performance optimization)
      buildWhen: (prev, curr) =>
          prev.selectedIndex != curr.selectedIndex ||
          prev.isNavBarVisible != curr.isNavBarVisible ||
          prev.isSearching != curr.isSearching ||
          prev.searchEnabled != curr.searchEnabled,
      builder: (context, state) {
        return Scaffold(
          body: widget.navigationShell,
          extendBody: true,
          bottomNavigationBar: Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: _buildStyledNavBar(context, state),
          ),
        );
      },
    );
  }

  // void _handleSwipe(
  //   BuildContext context,
  //   NavState state,
  //   DragEndDetails details,
  // ) {
  //   final velocity = details.primaryVelocity ?? 0;
  //   if (velocity.abs() < 300) return; // Ignore slow swipes

  //   // Don't swipe during search mode
  //   if (state.isSearching) return;

  //   final currentIndex = state.selectedIndex;
  //   int newIndex;

  //   if (velocity < 0) {
  //     // Swipe left → next tab
  //     newIndex = (currentIndex + 1) % 3;
  //   } else {
  //     // Swipe right → previous tab
  //     newIndex = (currentIndex - 1 + 3) % 3;
  //   }

  //   context.read<NavCubit>().updateTab(newIndex);
  //   navigationShell.goBranch(newIndex, initialLocation: false);
  // }

  /// Build styled nav bar with glasmorphic effect and search support
  Widget _buildStyledNavBar(BuildContext context, NavState state) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = theme.extension<AppSpacing>()!;

    // Don't hide during search mode
    final shouldShow = state.isNavBarVisible || state.isSearching;

    return AnimatedSlide(
      offset: shouldShow ? Offset.zero : const Offset(0, 1),
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1),
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.3),
            ),
            padding: EdgeInsets.only(
              top: state.searchEnabled ? spacing.md : 0,
              bottom: 32,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SearchableNavContainer(navigationShell: widget.navigationShell),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
