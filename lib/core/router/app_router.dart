import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/di/injection.dart';
import '../../core/router/navigation/custom_page_view_shell.dart';
import '../../core/router/navigation/nav_cubit.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/budgets/presentation/pages/budget_details_page.dart';
import '../../features/dashboard/presentation/pages/monthly_overview_detail_page.dart';

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

  /// GoRouter instance with CustomPageViewShell for animated tab navigation
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

      // Main app shell with PageView navigation (authenticated routes)
      GoRoute(
        path: dashboard,
        name: 'dashboard',
        builder: (context, state) {
          return BlocProvider(
            create: (_) => getIt<NavCubit>(),
            child: const CustomPageViewShell(),
          );
        },
        routes: [
          // Monthly overview detail sub-route
          GoRoute(
            path: 'monthly-overview',
            name: 'monthly-overview-detail',
            builder: (context, state) => const MonthlyOverviewDetailPage(),
          ),
          // Budget details sub-route
          GoRoute(
            path: 'budgets/:id',
            name: 'budget-details',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return BudgetDetailsPage(budgetId: id);
            },
          ),
        ],
      ),
    ],
    // Error page (optional - shows when route not found)
    errorBuilder: (context, state) => const LoginPage(),
  );
}
