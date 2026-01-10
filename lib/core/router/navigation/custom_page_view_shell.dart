import 'dart:ui';

import 'package:centabit/core/di/injection.dart';
import 'package:centabit/core/router/navigation/nav_cubit.dart';
import 'package:centabit/core/router/navigation/searchable_nav_container.dart';
import 'package:centabit/core/theme/theme_extensions.dart';
import 'package:centabit/features/budgets/presentation/cubits/budget_list_cubit.dart';
import 'package:centabit/features/budgets/presentation/pages/budgets_page.dart';
import 'package:centabit/features/dashboard/presentation/cubits/dashboard_cubit.dart';
import 'package:centabit/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:centabit/features/transactions/presentation/cubits/transaction_list_cubit.dart';
import 'package:centabit/features/transactions/presentation/pages/transactions_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// Custom navigation shell using PageView for animated tab transitions
///
/// **Features**:
/// - iOS-style slide + fade animations between tabs (300ms slide)
/// - Preserves state across tab switches (singleton cubits)
/// - Bidirectional sync between NavCubit and PageView
/// - Native swipe gesture support
///
/// **Architecture**:
/// - PageView manages visual transition animations (300ms)
/// - NavCubit manages tab state and nav bar visibility
/// - Singleton cubits survive page rebuilds (real-time updates work)
/// - AnimatedBuilder applies fade based on scroll position
class CustomPageViewShell extends StatefulWidget {
  const CustomPageViewShell({super.key});

  @override
  State<CustomPageViewShell> createState() => _CustomPageViewShellState();
}

class _CustomPageViewShellState extends State<CustomPageViewShell> {
  late PageController _pageController;
  bool _isAnimating = false;
  String? _previousRoute;

  @override
  void initState() {
    super.initState();
    // Initialize PageController with current tab from NavCubit
    final navCubit = context.read<NavCubit>();
    _pageController = PageController(
      initialPage: navCubit.state.selectedIndex,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkRouteChange();
  }

  @override
  void didUpdateWidget(CustomPageViewShell oldWidget) {
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

  /// Builds a page with fade transition based on scroll position
  Widget _buildPageWithFade({required int index, required Widget child}) {
    return AnimatedBuilder(
      animation: _pageController,
      builder: (context, child) {
        double value = 1.0;
        if (_pageController.position.haveDimensions) {
          value = _pageController.page ?? 0.0;
          value = (1 - (value - index).abs()).clamp(0.0, 1.0);
          // Apply a curve to the opacity for smoother transition
          value = Curves.easeInOut.transform(value);
        }
        return Opacity(
          opacity: value,
          child: child!,
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<NavCubit, NavState>(
      // Listen for tab changes from nav bar taps
      listenWhen: (prev, curr) =>
          prev.selectedIndex != curr.selectedIndex && !_isAnimating,
      listener: (context, state) {
        // Animate PageView to match nav bar selection
        _isAnimating = true;
        _pageController
            .animateToPage(
          state.selectedIndex,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        )
            .then((_) {
          if (mounted) {
            _isAnimating = false;
          }
        });
      },
      child: Scaffold(
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            // Sync NavCubit when user swipes PageView
            if (!_isAnimating) {
              context.read<NavCubit>().updateTab(index);
            }
          },
          children: [
            // Use BlocProvider.value() to prevent disposal when swiping
            // Wrap each page with fade transition
            _buildPageWithFade(
              index: 0,
              child: BlocProvider.value(
                value: getIt<DashboardCubit>(),
                child: const DashboardPage(),
              ),
            ),
            _buildPageWithFade(
              index: 1,
              child: BlocProvider.value(
                value: getIt<TransactionListCubit>(),
                child: const TransactionsPage(),
              ),
            ),
            _buildPageWithFade(
              index: 2,
              child: BlocProvider.value(
                value: getIt<BudgetListCubit>(),
                child: const BudgetsPage(),
              ),
            ),
          ],
        ),
        extendBody: true,
        bottomNavigationBar: Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: _buildNavBar(context),
        ),
      ),
    );
  }

  /// Build styled nav bar with glasmorphic effect and search support
  Widget _buildNavBar(BuildContext context) {
    return BlocBuilder<NavCubit, NavState>(
      buildWhen: (prev, curr) =>
          prev.selectedIndex != curr.selectedIndex ||
          prev.isNavBarVisible != curr.isNavBarVisible ||
          prev.isSearching != curr.isSearching ||
          prev.searchEnabled != curr.searchEnabled,
      builder: (context, state) {
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
                    // Use SearchableNavContainer for search support
                    SearchableNavContainer(
                      selectedIndex: state.selectedIndex,
                      onTabChange: (index) {
                        context.read<NavCubit>().updateTab(index);
                      },
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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}
