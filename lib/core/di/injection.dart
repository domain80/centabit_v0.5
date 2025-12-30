import 'package:centabit/core/auth/auth_manager.dart';
import 'package:centabit/core/logging/app_logger.dart';
import 'package:centabit/core/router/navigation/nav_cubit.dart';
import 'package:centabit/data/local/allocation_local_source.dart';
import 'package:centabit/data/local/budget_local_source.dart';
import 'package:centabit/data/local/category_local_source.dart';
import 'package:centabit/data/local/database.dart';
import 'package:centabit/data/local/transaction_local_source.dart';
import 'package:centabit/data/repositories/allocation_repository.dart';
import 'package:centabit/data/repositories/budget_repository.dart';
import 'package:centabit/data/repositories/category_repository.dart';
import 'package:centabit/data/repositories/transaction_repository.dart';
import 'package:centabit/data/sync/sync_manager.dart';
import 'package:centabit/features/categories/presentation/cubits/category_form_cubit.dart';
import 'package:centabit/features/dashboard/presentation/cubits/dashboard_cubit.dart';
import 'package:centabit/features/dashboard/presentation/cubits/date_filter_cubit.dart';
import 'package:centabit/features/transactions/presentation/cubits/transaction_form_cubit.dart';
import 'package:centabit/features/transactions/presentation/cubits/transaction_list_cubit.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

/// Initialize all dependencies for the application (v5 local-first architecture).
///
/// Registers dependencies in order:
/// 1. SharedPreferences (async initialization)
/// 2. AuthManager (anonymous tokens + future OAuth)
/// 3. Database (Drift SQLite)
/// 4. LocalSources (userId-filtered data access)
/// 5. Repositories (local-only, sync stubs for future API)
/// 6. SyncManager (isolate-based background sync)
/// 7. Cubits (depend on repositories)
///
/// **Architecture** (v5):
/// ```
/// Cubits → Repositories → LocalSources → Drift Database
///                                      ↓
///                                 SyncManager (isolate)
/// ```
///
/// **Registered Components**:
/// - AuthManager: Anonymous user tokens (with userId filtering)
/// - AppDatabase: Drift SQLite database
/// - LocalSources: Transaction, Category, Budget, Allocation (userId-filtered)
/// - Repositories: Local-only with sync stubs (ready for future API)
/// - SyncManager: Isolate-based background sync (periodic + manual)
/// - Cubits: NavCubit, TransactionListCubit, DashboardCubit, DateFilterCubit
///
/// **Example Usage**:
/// ```dart
/// // Get a repository
/// final transactionRepo = getIt<TransactionRepository>();
///
/// // Get a cubit (in widget)
/// BlocProvider(create: (_) => getIt<TransactionListCubit>())
/// ```
Future<void> configureDependencies() async {
  // ========================================
  // Logging Infrastructure
  // ========================================

  // AppLogger singleton
  getIt.registerLazySingleton<AppLogger>(() => AppLogger.instance);

  // ========================================
  // Foundation (SharedPreferences, Auth)
  // ========================================

  // SharedPreferences (async initialization required)
  final prefs = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => prefs);

  // Auth Manager (anonymous tokens + future OAuth)
  getIt.registerLazySingleton<AuthManager>(
    () => AuthManager(getIt<SharedPreferences>()),
  );

  // Get current userId (await here to ensure auth is ready)
  final userId = await getIt<AuthManager>().getCurrentUserId();

  // ========================================
  // Database Layer (Drift)
  // ========================================

  // Drift database
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // ========================================
  // Local Data Sources (userId-filtered)
  // ========================================

  getIt.registerLazySingleton<TransactionLocalSource>(
    () => TransactionLocalSource(getIt<AppDatabase>(), userId),
  );

  getIt.registerLazySingleton<CategoryLocalSource>(
    () => CategoryLocalSource(getIt<AppDatabase>(), userId),
  );

  getIt.registerLazySingleton<BudgetLocalSource>(
    () => BudgetLocalSource(getIt<AppDatabase>(), userId),
  );

  getIt.registerLazySingleton<AllocationLocalSource>(
    () => AllocationLocalSource(getIt<AppDatabase>(), userId),
  );

  // ========================================
  // Repositories (Local-Only for Now)
  // ========================================

  getIt.registerLazySingleton<TransactionRepository>(
    () => TransactionRepository(getIt<TransactionLocalSource>()),
  );

  getIt.registerLazySingleton<CategoryRepository>(
    () => CategoryRepository(getIt<CategoryLocalSource>()),
  );

  getIt.registerLazySingleton<BudgetRepository>(
    () => BudgetRepository(getIt<BudgetLocalSource>()),
  );

  getIt.registerLazySingleton<AllocationRepository>(
    () => AllocationRepository(getIt<AllocationLocalSource>()),
  );

  // ========================================
  // Sync Manager (Isolate-Based)
  // ========================================

  getIt.registerLazySingleton<SyncManager>(() => SyncManager());

  // Start periodic sync in background isolate
  await getIt<SyncManager>().startPeriodicSync();

  // ========================================
  // Cubits (Factories)
  // ========================================

  getIt.registerFactory<NavCubit>(() => NavCubit());

  getIt.registerFactory<TransactionListCubit>(
    () => TransactionListCubit(
      getIt<TransactionRepository>(),
      getIt<CategoryRepository>(),
    ),
  );

  getIt.registerFactory<TransactionFormCubit>(
    () => TransactionFormCubit(
      getIt<TransactionRepository>(),
      getIt<BudgetRepository>(),
      getIt<CategoryRepository>(),
    ),
  );

  getIt.registerFactory<CategoryFormCubit>(
    () => CategoryFormCubit(
      getIt<CategoryRepository>(),
    ),
  );

  getIt.registerFactory<DashboardCubit>(
    () => DashboardCubit(
      getIt<BudgetRepository>(),
      getIt<AllocationRepository>(),
      getIt<TransactionRepository>(),
      getIt<CategoryRepository>(),
    ),
  );

  getIt.registerFactory<DateFilterCubit>(
    () => DateFilterCubit(
      getIt<TransactionRepository>(),
      getIt<CategoryRepository>(),
    ),
  );
}
