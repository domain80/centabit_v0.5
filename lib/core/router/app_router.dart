import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/injection.dart';
import '../../core/router/navigation/app_nav_shell.dart';
import '../../core/router/navigation/nav_cubit.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/budgets/presentation/pages/budget_details_page.dart';
import '../../features/budgets/presentation/pages/budgets_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/transactions/presentation/pages/transactions_page.dart';

/// Application router configuration using go_router
///
/// Defines all navigation routes and their corresponding pages.
class AppRouter {
  // Private constructor to prevent instantiation
  AppRouter._();

  /// Route paths
  static const String login = '/login';
  static const String dashboard = '/';
  static const String transactions = '/transactions';
  static const String budgets = '/budgets';

  /// GoRouter instance with StatefulShellRoute for nested navigation
  static final GoRouter router = GoRouter(
    initialLocation: login,
    debugLogDiagnostics: true,
    routes: [
      // Login route (unauthenticated)
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),

      // Main app shell with bottom navigation (authenticated routes)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return BlocProvider(
            create: (_) => getIt<NavCubit>(),
            child: AppNavShell(navigationShell: navigationShell),
          );
        },
        branches: [
          // Dashboard branch (index 0)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: dashboard,
                name: 'dashboard',
                builder: (context, state) => const DashboardPage(),
              ),
            ],
          ),

          // Transactions branch (index 1)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: transactions,
                name: 'transactions',
                builder: (context, state) => const TransactionsPage(),
              ),
            ],
          ),

          // Budgets branch (index 2)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: budgets,
                name: 'budgets',
                builder: (context, state) => const BudgetsPage(),
                routes: [
                  // Budget details sub-route
                  GoRoute(
                    path: ':id',
                    name: 'budget-details',
                    builder: (context, state) {
                      final id = state.pathParameters['id']!;
                      return BudgetDetailsPage(budgetId: id);
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],
    // Error page (optional - shows when route not found)
    errorBuilder: (context, state) => const LoginPage(),
  );
}
