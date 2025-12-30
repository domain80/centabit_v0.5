import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:centabit/data/models/budget_model.dart';
import 'package:centabit/data/repositories/budget_repository.dart';
import 'package:centabit/data/repositories/allocation_repository.dart';
import 'package:centabit/features/budgets/presentation/cubits/budget_list_state.dart';

/// Cubit for managing budget list state.
///
/// Subscribes to budget and allocation repository streams to provide reactive
/// updates when budgets or allocations change. Aggregates budget data with
/// their allocations into view models for list display.
///
/// **Architecture Pattern**: MVVM with Cubit
/// - Uses repository pattern (not direct service access)
/// - Stream subscriptions trigger auto-reload on data changes
/// - Builds view models with denormalized data (budget + allocations)
///
/// **Responsibilities**:
/// 1. Subscribe to budget and allocation streams for reactive updates
/// 2. Fetch budgets and allocations from repositories
/// 3. Denormalize data (join budget with its allocations)
/// 4. Calculate metrics (total allocated, days remaining, status)
/// 5. Build BudgetListVModel for each budget
/// 6. Emit state changes for UI updates
///
/// **Data Flow**:
/// ```
/// Repositories emit changes
///   ↓
/// Stream subscriptions trigger _loadBudgets()
///   ↓
/// Get all budgets + allocations
///   ↓
/// For each budget:
///   - Find its allocations
///   - Calculate totalAllocated
///   - Check if active
///   - Create BudgetListVModel
///   ↓
/// Emit BudgetListState.success([BudgetListVModel, ...])
///   ↓
/// UI rebuilds with BlocBuilder
/// ```
///
/// **Usage**:
/// ```dart
/// BlocProvider(
///   create: (_) => getIt<BudgetListCubit>(),
///   child: BudgetsPage(),
/// )
/// ```
class BudgetListCubit extends Cubit<BudgetListState> {
  final BudgetRepository _budgetRepository;
  final AllocationRepository _allocationRepository;

  // Stream subscriptions for reactive updates
  StreamSubscription? _budgetSubscription;
  StreamSubscription? _allocationSubscription;

  /// Creates budget list cubit with repository dependencies.
  ///
  /// Automatically starts listening to repository streams and loads initial data.
  ///
  /// **Example** (via GetIt):
  /// ```dart
  /// final cubit = getIt<BudgetListCubit>();
  /// ```
  BudgetListCubit(
    this._budgetRepository,
    this._allocationRepository,
  ) : super(const BudgetListState.initial()) {
    _subscribeToStreams();
  }

  /// Subscribes to budget and allocation streams for reactive updates.
  ///
  /// Any change in budgets or allocations triggers a full list reload.
  /// This ensures the UI always shows current data.
  ///
  /// **Triggers Reload On**:
  /// - Budget created/updated/deleted
  /// - Allocation created/updated/deleted
  ///
  /// **Performance Note**:
  /// Recalculates everything on any change. For <100 budgets, this is
  /// acceptable. If performance becomes an issue:
  /// - Add debouncing to prevent rapid successive updates
  /// - Implement incremental updates (only recalculate changed budgets)
  /// - Cache last computation
  void _subscribeToStreams() {
    _budgetSubscription = _budgetRepository.budgetsStream.listen((_) {
      _loadBudgets();
    });

    _allocationSubscription = _allocationRepository.allocationsStream.listen((_) {
      _loadBudgets();
    });

    // Initial load
    _loadBudgets();
  }

  /// Loads and aggregates budget list data from repositories.
  ///
  /// **Process**:
  /// 1. Emit loading state
  /// 2. Get all budgets from repository (synchronous cache access)
  /// 3. Get all allocations from repository (synchronous cache access)
  /// 4. For each budget, build a BudgetListVModel with its allocations
  /// 5. Emit success state with view models list
  ///
  /// **Error Handling**:
  /// Catches any exceptions and emits error state with message.
  ///
  /// **Sorting**:
  /// Budgets are sorted by:
  /// 1. Active budgets first (currently in period)
  /// 2. Then by start date (newest first)
  /// This ensures active budgets appear at the top of the list.
  void _loadBudgets() {
    emit(const BudgetListState.loading());

    try {
      // Get all budgets and allocations from repositories
      final budgets = _budgetRepository.budgets;
      final allocations = _allocationRepository.allocations;

      // Build view model for each budget
      final budgetViewModels = budgets.map((budget) {
        // Find allocations for this budget
        final budgetAllocations = allocations
            .where((allocation) => allocation.budgetId == budget.id)
            .toList();

        // Calculate total allocated amount
        final totalAllocated = budgetAllocations.fold<double>(
          0.0,
          (sum, allocation) => sum + allocation.amount,
        );

        // Check if budget is currently active
        final isActive = budget.isActive();

        // Create view model
        return BudgetListVModel(
          budget: budget,
          allocations: budgetAllocations,
          totalAllocated: totalAllocated,
          isActive: isActive,
        );
      }).toList();

      // Sort budgets: active first, then by start date (newest first)
      budgetViewModels.sort((a, b) {
        // Active budgets come first
        if (a.isActive && !b.isActive) return -1;
        if (!a.isActive && b.isActive) return 1;

        // Within same active status, sort by start date (newest first)
        return b.budget.startDate.compareTo(a.budget.startDate);
      });

      emit(BudgetListState.success(budgets: budgetViewModels));
    } catch (e) {
      emit(BudgetListState.error(e.toString()));
    }
  }

  /// Manually triggers a refresh of budget list data.
  ///
  /// Useful for pull-to-refresh functionality. Calls `_loadBudgets()`
  /// which re-fetches data and emits new state.
  ///
  /// **Usage**:
  /// ```dart
  /// RefreshIndicator(
  ///   onRefresh: () => context.read<BudgetListCubit>().refresh(),
  ///   child: BudgetList(),
  /// )
  /// ```
  Future<void> refresh() {
    _loadBudgets();
    return Future.value();
  }

  /// Cancels all stream subscriptions when cubit is closed.
  ///
  /// **Critical**: Prevents memory leaks by cleaning up subscriptions.
  /// Called automatically by BLoC when the cubit is disposed.
  @override
  Future<void> close() {
    _budgetSubscription?.cancel();
    _allocationSubscription?.cancel();
    return super.close();
  }
}
