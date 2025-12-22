import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';

/// Application router configuration using go_router
///
/// Defines all navigation routes and their corresponding pages.
class AppRouter {
  // Private constructor to prevent instantiation
  AppRouter._();

  /// Route paths
  static const String login = '/login';
  static const String dashboard = '/';

  /// GoRouter instance
  static final GoRouter router = GoRouter(
    initialLocation: login,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: dashboard,
        name: 'dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
    ],
    // Error page (optional - shows when route not found)
    errorBuilder: (context, state) => const LoginPage(),
  );
}
