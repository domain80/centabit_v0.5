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

/// Custom navigation shell with fade animations for tab transitions
///
/// **Features**:
/// - Smooth fade animations between tabs (300ms)
/// - Preserves state across tab switches (singleton cubits)
/// - Tab state managed by NavCubit
///
/// **Architecture**:
/// - AnimatedSwitcher with FadeTransition for page changes
/// - NavCubit manages tab state and nav bar visibility
/// - Singleton cubits survive page rebuilds (real-time updates work)
/// - ValueKeys prevent widget recycling during transitions
class CustomPageViewShell extends StatefulWidget {
  const CustomPageViewShell({super.key});

  @override
  State<CustomPageViewShell> createState() => _CustomPageViewShellState();
}

class _CustomPageViewShellState extends State<CustomPageViewShell> {
  String? _previousRoute;

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

  /// Get the page widget for the given index
  Widget _getPageForIndex(int index) {
    switch (index) {
      case 0:
        return BlocProvider.value(
          key: const ValueKey('dashboard'),
          value: getIt<DashboardCubit>(),
          child: const DashboardPage(),
        );
      case 1:
        return BlocProvider.value(
          key: const ValueKey('transactions'),
          value: getIt<TransactionListCubit>(),
          child: const TransactionsPage(),
        );
      case 2:
        return BlocProvider.value(
          key: const ValueKey('budgets'),
          value: getIt<BudgetListCubit>(),
          child: const BudgetsPage(),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavCubit, NavState>(
      buildWhen: (prev, curr) => prev.selectedIndex != curr.selectedIndex,
      builder: (context, state) {
        return Scaffold(
          body: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            child: _getPageForIndex(state.selectedIndex),
          ),
          extendBody: true,
          bottomNavigationBar: Padding(
            padding: MediaQuery.of(context).viewInsets,
            child: _buildNavBar(context),
          ),
        );
      },
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
}
