import 'package:get_it/get_it.dart';
import 'package:centabit/core/router/navigation/nav_cubit.dart';
import 'package:centabit/data/services/category_service.dart';
import 'package:centabit/data/services/transaction_service.dart';
import 'package:centabit/features/transactions/presentation/cubits/transaction_list_cubit.dart';

/// Service locator instance for dependency injection
final getIt = GetIt.instance;

/// Initialize all dependencies
///
/// Call this method in main() before runApp()
Future<void> configureDependencies() async {
  // Register services (singletons - same instance everywhere)
  getIt.registerLazySingleton<CategoryService>(() => CategoryService());
  getIt.registerLazySingleton<TransactionService>(
    () => TransactionService(getIt<CategoryService>()),
  );

  // Register Cubits (factories - new instance each time)
  getIt.registerFactory<NavCubit>(() => NavCubit());
  getIt.registerFactory<TransactionListCubit>(
    () => TransactionListCubit(
      getIt<TransactionService>(),
      getIt<CategoryService>(),
    ),
  );
}
