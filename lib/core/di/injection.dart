import 'package:get_it/get_it.dart';
import 'package:centabit/core/router/navigation/nav_cubit.dart';
import 'package:centabit/data/services/category_service.dart';
import 'package:centabit/data/services/transaction_service.dart';
import 'package:centabit/data/services/budget_service.dart';
import 'package:centabit/data/services/allocation_service.dart';
import 'package:centabit/features/transactions/presentation/cubits/transaction_list_cubit.dart';
import 'package:centabit/features/dashboard/presentation/cubits/dashboard_cubit.dart';
import 'package:centabit/features/dashboard/presentation/cubits/date_filter_cubit.dart';

/// Service locator instance for dependency injection
///
/// GetIt provides a simple, performant service locator for dependency injection.
/// We use it to register services (singletons) and cubits (factories) that can
/// be accessed throughout the app.
///
/// **Pattern**:
/// - Services: `registerLazySingleton` (shared instance, created on first access)
/// - Cubits: `registerFactory` (new instance for each request)
///
/// **Initialization**:
/// Call [configureDependencies] in `main()` before `runApp()`:
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await configureDependencies();
///   runApp(MyApp());
/// }
/// ```
final getIt = GetIt.instance;

/// Initialize all dependencies for the application.
///
/// Registers services and cubits in dependency order:
/// 1. Independent services (CategoryService, BudgetService)
/// 2. Dependent services (TransactionService, AllocationService)
/// 3. Cubits (depend on services)
///
/// **Services Registered**:
/// - CategoryService: Manages spending categories
/// - BudgetService: Manages budget periods
/// - TransactionService: Manages transactions (depends on CategoryService)
/// - AllocationService: Manages budget allocations (depends on Category & Budget)
///
/// **Cubits Registered**:
/// - NavCubit: Navigation state
/// - TransactionListCubit: Transaction list with pagination
/// - DashboardCubit: Budget reports and BAR calculation (Phase 3)
/// - DateFilterCubit: Date-based transaction filtering (Phase 3)
///
/// **Example Usage**:
/// ```dart
/// // Get a service
/// final budgetService = getIt<BudgetService>();
///
/// // Get a cubit (in widget)
/// BlocProvider(create: (_) => getIt<TransactionListCubit>())
/// ```
Future<void> configureDependencies() async {
  // ========================================
  // Services (Lazy Singletons)
  // ========================================
  // Created once on first access, shared everywhere

  // Core services with no dependencies
  getIt.registerLazySingleton<CategoryService>(() => CategoryService());
  getIt.registerLazySingleton<BudgetService>(() => BudgetService());

  // Services with dependencies (order matters!)
  getIt.registerLazySingleton<TransactionService>(
    () => TransactionService(getIt<CategoryService>()),
  );

  getIt.registerLazySingleton<AllocationService>(
    () => AllocationService(
      getIt<CategoryService>(),
      getIt<BudgetService>(),
    ),
  );

  // ========================================
  // Cubits (Factories)
  // ========================================
  // Created fresh for each widget that needs them

  getIt.registerFactory<NavCubit>(() => NavCubit());

  getIt.registerFactory<TransactionListCubit>(
    () => TransactionListCubit(
      getIt<TransactionService>(),
      getIt<CategoryService>(),
    ),
  );

  // Dashboard cubits (Phase 3)
  getIt.registerFactory<DashboardCubit>(
    () => DashboardCubit(
      getIt<BudgetService>(),
      getIt<AllocationService>(),
      getIt<TransactionService>(),
      getIt<CategoryService>(),
    ),
  );

  getIt.registerFactory<DateFilterCubit>(
    () => DateFilterCubit(
      getIt<TransactionService>(),
      getIt<CategoryService>(),
    ),
  );
}
