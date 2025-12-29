import 'package:centabit/core/router/navigation/nav_cubit.dart';
import 'package:centabit/core/router/navigation/shared_nav_bar.dart';
import 'package:centabit/core/router/navigation/widgets/nav_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Container managing both navigation and search bar with animated transitions
///
/// Displays two variants:
/// 1. **Simple Nav** (when searchEnabled=false):
///    - Shows standard navigation bar with tabs + action button
///    - No search UI
///
/// 2. **Searchable Nav** (when searchEnabled=true):
///    - **Navigation Mode** (default): Nav bar prominent, search minimized
///    - **Search Mode**: Search bar enlarged, nav bar scaled down
///    - Smooth 300ms animations between states
///
/// Stack layout with:
/// - Search bar on top (positioned layer)
/// - Navigation bar on bottom (positioned layer, scaled when searching)
class SearchableNavContainer extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const SearchableNavContainer({super.key, required this.navigationShell});

  @override
  State<SearchableNavContainer> createState() => _SearchableNavContainerState();
}

class _SearchableNavContainerState extends State<SearchableNavContainer> {
  late FocusNode _searchFocusNode;

  @override
  void initState() {
    super.initState();
    _searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavCubit, NavState>(
      builder: (context, navState) {
        return Column(
          spacing: 0,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Search bar - always present, scales to 0 when not enabled
            GestureDetector(
              onTap: navState.isSearching
                  ? null
                  : () => context.read<NavCubit>().toggleSearchMode(),
              child: AbsorbPointer(
                absorbing: !navState.isSearching,
                child: AnimatedScale(
                  scale: navState.searchEnabled
                      ? (navState.isSearching ? 1.0 : 0.45)
                      : 0.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 300,
                    child: NavSearchBar(focusNode: _searchFocusNode),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: navState.isSearching
                  ? () {
                      context.read<NavCubit>().toggleSearchMode();
                      _searchFocusNode.unfocus();
                    }
                  : null,
              child: AbsorbPointer(
                absorbing: navState.isSearching,
                child: AnimatedScale(
                  scale: navState.isSearching ? 0.45 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  alignment: Alignment.center,
                  child: SharedNavBar(
                    navigationShell: widget.navigationShell,
                    actionType: navState.actionType,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/*
        // Variant 1: Simple Nav (no search capability)
        if (!navState.searchEnabled) {
          return Padding(
            padding: EdgeInsets.only(
              left: spacing.md,
              right: spacing.md,
              bottom: spacing.md,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SharedNavBar(
                  navigationShell: widget.navigationShell,
                  actionType: navState.actionType,
                ),
              ],
            ),
          );
        }

        // Variant 2: Searchable Nav with dual states
        return Stack(
          children: [
            // Navigation Bar (bottom layer) - scales down when searching
            Positioned(
              bottom: 0,
              left: spacing.md,
              right: spacing.md,
              child: AnimatedScale(
                scale: navState.isSearching ? 0.85 : 1.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: AnimatedOpacity(
                  opacity: navState.isSearching ? 0.6 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: SharedNavBar(
                    navigationShell: widget.navigationShell,
                    actionType: navState.actionType,
                  ),
                ),
              ),
            ),

            // Search Bar (top layer)
            if (navState.isSearching)
              Positioned(
                bottom: spacing.xl6,
                left: spacing.md,
                right: spacing.md,
                child: AnimatedOpacity(
                  opacity: navState.isSearching ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: AnimatedScale(
                    scale: navState.isSearching ? 1.0 : 0.75,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: SearchInput(focusNode: _searchFocusNode),
                  ),
                ),
              )
            else
              Positioned(
                bottom: spacing.xl * 3,
                left: spacing.md,
                right: spacing.md,
                child: AnimatedOpacity(
                  opacity: navState.isSearching ? 0.0 : 1.0,
                  duration: const Duration(milliseconds: 300),
                  child: AnimatedScale(
                    scale: navState.isSearching ? 0.75 : 1.0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: MinimizedSearchBar(),
                  ),
                ),
              ),
          ],
        );
*/
