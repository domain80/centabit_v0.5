import 'package:centabit/data/models/allocation_model.dart';
import 'package:centabit/data/models/budget_model.dart';
import 'package:centabit/data/models/category_model.dart';
import 'package:centabit/data/models/transactions_chart_data.dart';
import 'package:centabit/shared/v_models/transaction_v_model.dart';

/// View model for budget details screen - denormalizes budget data for display
class BudgetDetailsVModel {
  final BudgetModel budget;
  final List<AllocationDetailVModel> allocations;
  final List<TransactionVModel> transactions;

  const BudgetDetailsVModel({
    required this.budget,
    required this.allocations,
    required this.transactions,
  });

  // Computed metrics
  double get totalAllocated =>
      allocations.fold(0.0, (sum, a) => sum + a.allocation.amount);

  double get totalSpent => allocations.fold(0.0, (sum, a) => sum + a.spent);

  double get remaining => budget.amount - totalSpent;

  double get unallocated => budget.amount - totalAllocated;

  // BAR calculation (from Dashboard pattern)
  double get barValue {
    final now = DateTime.now();
    if (now.isBefore(budget.startDate)) return 0.0;
    if (now.isAfter(budget.endDate)) return 1.0;

    final totalDays = budget.endDate.difference(budget.startDate).inDays;
    final elapsedDays = now.difference(budget.startDate).inDays;

    if (totalDays == 0 || budget.amount == 0) return 0.0;

    final timeProgress = elapsedDays / totalDays;
    final spendProgress = totalSpent / budget.amount;

    if (timeProgress == 0) return 0.0;

    return spendProgress / timeProgress; // >1.0 = overspending
  }

  // Progress percentage
  double get spentPercentage =>
      budget.amount > 0 ? (totalSpent / budget.amount) * 100 : 0.0;

  // Chart data (for bar/pie charts in Phase 3)
  List<TransactionsChartData> get chartData => allocations
      .map(
        (a) => TransactionsChartData(
          categoryId: a.category.id,
          categoryName: a.category.name,
          categoryIconName: a.category.iconName,
          allocationAmount: a.allocation.amount,
          transactionAmount: a.spent,
        ),
      )
      .toList();
}

/// View model for individual allocation with spending details
class AllocationDetailVModel {
  final AllocationModel allocation;
  final CategoryModel category;
  final List<TransactionVModel> transactions;

  const AllocationDetailVModel({
    required this.allocation,
    required this.category,
    required this.transactions,
  });

  double get spent =>
      transactions.fold(0.0, (sum, t) => sum + t.amount);

  double get remaining => allocation.amount - spent;

  double get spentPercentage =>
      allocation.amount > 0 ? (spent / allocation.amount) * 100 : 0.0;

  bool get isOverspent => spent > allocation.amount;
}
