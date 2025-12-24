import 'dart:async';
import 'package:centabit/data/models/budget_model.dart';

/// Service for managing budgets with in-memory storage and reactive streams.
///
/// Provides CRUD operations for budgets and exposes a broadcast stream for
/// reactive updates. Follows the same pattern as [CategoryService] and
/// [TransactionService] for consistency.
///
/// **Architecture**: Simple in-memory service (no Repository layer needed)
/// - Stores budgets in a list
/// - Emits stream events on changes
/// - Cubits subscribe to stream for reactive UI updates
///
/// **Default Data**:
/// Initializes with one budget for the current month to enable immediate
/// dashboard functionality.
///
/// **Example Usage**:
/// ```dart
/// final budgetService = BudgetService();
///
/// // Listen to changes
/// budgetService.budgetsStream.listen((budgets) {
///   print('Budgets updated: ${budgets.length}');
/// });
///
/// // Create a budget
/// final budget = BudgetModel.create(
///   name: 'January 2026',
///   amount: 2500.0,
///   startDate: DateTime(2026, 1, 1),
///   endDate: DateTime(2026, 1, 31, 23, 59, 59),
/// );
/// await budgetService.createBudget(budget);
///
/// // Get active budgets
/// final active = budgetService.getActiveBudgets();
/// ```
///
/// **Stream Subscriptions**:
/// - DashboardCubit subscribes to `budgetsStream`
/// - Any change triggers dashboard recalculation
class BudgetService {
  /// Internal list of all budgets
  final List<BudgetModel> _budgets = [];

  /// Broadcast stream controller for budget changes
  ///
  /// Use broadcast to allow multiple listeners (cubits).
  final _budgetsController = StreamController<List<BudgetModel>>.broadcast();

  /// Stream of budget changes
  ///
  /// Emits an immutable list of budgets whenever the collection changes.
  /// Subscribe to this stream for reactive UI updates.
  ///
  /// **Example**:
  /// ```dart
  /// _budgetSubscription = budgetService.budgetsStream.listen((_) {
  ///   _loadDashboardData();
  /// });
  /// ```
  Stream<List<BudgetModel>> get budgetsStream => _budgetsController.stream;

  /// Immutable snapshot of all budgets
  ///
  /// Returns a read-only copy of the budget list.
  /// Use this for synchronous access (e.g., in service methods).
  List<BudgetModel> get budgets => List.unmodifiable(_budgets);

  /// Creates the budget service and initializes with default data.
  BudgetService() {
    _initializeDefaultBudget();
  }

  /// Initializes the service with one default monthly budget.
  ///
  /// Creates a budget for the current month (December 2025) with $2000 total.
  /// This enables immediate dashboard functionality without requiring users
  /// to create a budget first.
  ///
  /// **Default Budget**:
  /// - Name: "December 2025" (current month/year)
  /// - Amount: $2000
  /// - Period: Start to end of current month
  void _initializeDefaultBudget() {
    final now = DateTime.now();

    // Start of current month at 00:00:00
    final startOfMonth = DateTime(now.year, now.month, 1);

    // End of current month at 23:59:59
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    // Month name + year (e.g., "December 2025")
    final monthNames = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final budgetName = '${monthNames[now.month]} ${now.year}';

    final defaultBudget = BudgetModel.create(
      name: budgetName,
      amount: 2000.0,
      startDate: startOfMonth,
      endDate: endOfMonth,
    );

    _budgets.add(defaultBudget);
    _emitBudgets();
  }

  /// Creates a new budget.
  ///
  /// Adds the budget to the collection and notifies all stream listeners.
  ///
  /// **Example**:
  /// ```dart
  /// final budget = BudgetModel.create(
  ///   name: 'Q1 2026',
  ///   amount: 7500.0,
  ///   startDate: DateTime(2026, 1, 1),
  ///   endDate: DateTime(2026, 3, 31, 23, 59, 59),
  /// );
  /// await budgetService.createBudget(budget);
  /// ```
  ///
  /// **Validation Considerations**:
  /// - Amount should be positive
  /// - StartDate should be before endDate
  /// - Period shouldn't overlap with existing budgets (soft rule)
  Future<void> createBudget(BudgetModel budget) async {
    _budgets.add(budget);
    _emitBudgets();
  }

  /// Updates an existing budget.
  ///
  /// Replaces the budget with matching ID and updates its timestamp.
  /// If the budget doesn't exist, no action is taken.
  ///
  /// **Example**:
  /// ```dart
  /// final updated = budget.copyWith(amount: 2500.0);
  /// await budgetService.updateBudget(updated);
  /// ```
  Future<void> updateBudget(BudgetModel budget) async {
    final index = _budgets.indexWhere((b) => b.id == budget.id);
    if (index != -1) {
      _budgets[index] = budget.withUpdatedTimestamp();
      _emitBudgets();
    }
  }

  /// Deletes a budget by ID.
  ///
  /// Removes the budget from the collection and notifies listeners.
  ///
  /// **Warning**: Deleting a budget doesn't cascade delete allocations!
  /// Consider implementing cascade delete or preventing deletion of budgets
  /// with allocations.
  ///
  /// **Example**:
  /// ```dart
  /// await budgetService.deleteBudget(budgetId);
  /// ```
  Future<void> deleteBudget(String id) async {
    _budgets.removeWhere((b) => b.id == id);
    _emitBudgets();
  }

  /// Finds a budget by ID.
  ///
  /// Returns the budget if found, null otherwise.
  ///
  /// **Example**:
  /// ```dart
  /// final budget = budgetService.getBudgetById(budgetId);
  /// if (budget != null) {
  ///   print('Found: ${budget.name}');
  /// }
  /// ```
  BudgetModel? getBudgetById(String id) {
    try {
      return _budgets.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Returns all budgets that are currently active.
  ///
  /// A budget is active if the current date/time falls within its period
  /// (`startDate` <= now <= `endDate`).
  ///
  /// **Used By**: DashboardCubit to show current budget reports
  ///
  /// **Example**:
  /// ```dart
  /// final activeBudgets = budgetService.getActiveBudgets();
  /// for (final budget in activeBudgets) {
  ///   print('${budget.name}: \$${budget.amount}');
  /// }
  /// ```
  ///
  /// **Note**: Usually returns 0-1 budgets for monthly budgets, but could
  /// return multiple if budget periods overlap.
  List<BudgetModel> getActiveBudgets() {
    final now = DateTime.now();
    return _budgets.where((b) => b.isActive()).toList();
  }

  /// Returns all budgets for a specific time period.
  ///
  /// Useful for historical analysis or filtering by date range.
  ///
  /// **Example**:
  /// ```dart
  /// final year2025 = budgetService.getBudgetsInPeriod(
  ///   DateTime(2025, 1, 1),
  ///   DateTime(2025, 12, 31, 23, 59, 59),
  /// );
  /// ```
  List<BudgetModel> getBudgetsInPeriod(DateTime start, DateTime end) {
    return _budgets.where((b) {
      // Budget overlaps if it starts before period end and ends after period start
      return b.startDate.isBefore(end) && b.endDate.isAfter(start);
    }).toList();
  }

  /// Sorts budgets by start date (descending, most recent first).
  ///
  /// Modifies the internal list order. Useful for displaying budgets in
  /// chronological order.
  ///
  /// **Example**:
  /// ```dart
  /// budgetService.sortByDate();
  /// final budgets = budgetService.budgets; // Sorted, newest first
  /// ```
  void sortByDate() {
    _budgets.sort((a, b) => b.startDate.compareTo(a.startDate));
    _emitBudgets();
  }

  /// Emits the current budget list to all stream listeners.
  ///
  /// Called after any mutation (create, update, delete).
  /// Sends an immutable copy to prevent external modification.
  void _emitBudgets() {
    _budgetsController.add(List.unmodifiable(_budgets));
  }

  /// Disposes of the stream controller.
  ///
  /// Call this when the service is no longer needed (app shutdown).
  /// In most cases, services are singletons that live for the app lifetime.
  ///
  /// **Example**:
  /// ```dart
  /// @override
  /// void dispose() {
  ///   budgetService.dispose();
  ///   super.dispose();
  /// }
  /// ```
  void dispose() {
    _budgetsController.close();
  }
}
