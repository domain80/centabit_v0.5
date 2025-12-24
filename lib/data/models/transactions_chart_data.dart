/// View model for budget chart data display.
///
/// This is a denormalized model that combines allocation and transaction data
/// for a single category. It's used by [BudgetBarChart] to render side-by-side
/// bars comparing budgeted amounts vs actual spending.
///
/// **Not a freezed model**: This is a simple view model that doesn't need
/// serialization or complex equality. Created fresh each time chart data is built.
///
/// **Data Flow**:
/// ```
/// DashboardCubit._buildChartData()
///   ↓
/// For each category:
///   - Get allocation amount (from AllocationModel)
///   - Get transaction sum (from TransactionModel list)
///   - Get category metadata (from CategoryModel)
///   ↓
/// Create TransactionsChartData
///   ↓
/// Pass to BudgetBarChart widget
///   ↓
/// Render as side-by-side bars
/// ```
///
/// **Example**:
/// ```dart
/// final chartData = TransactionsChartData(
///   categoryId: 'uuid-123',
///   categoryName: 'Groceries',
///   categoryIconName: 'cart',
///   allocationAmount: 400.0,      // Budgeted: $400
///   transactionAmount: 325.50,    // Spent: $325.50
/// );
/// ```
///
/// **Chart Interpretation**:
/// - `allocationAmount` = Height of first bar (budget)
/// - `transactionAmount` = Height of second bar (actual)
/// - If `transactionAmount > allocationAmount`: Overspending in this category
/// - Category icon shown on X-axis
class TransactionsChartData {
  /// Category unique identifier
  ///
  /// Links to [CategoryModel.id] for reference.
  final String categoryId;

  /// Category display name
  ///
  /// Shown in chart tooltips and legend.
  /// Example: "Groceries", "Entertainment", "Transport"
  final String categoryName;

  /// Category icon name
  ///
  /// Used to display icon on chart X-axis.
  /// Matches icon font family (e.g., Tabler Icons).
  /// Example: "cart", "ticket", "car"
  final String categoryIconName;

  /// Allocated budget amount for this category
  ///
  /// The planned/budgeted amount from [AllocationModel.amount].
  /// Represents the first bar in the side-by-side chart.
  ///
  /// **Color**: Typically rendered in `colorScheme.onSurface`
  final double allocationAmount;

  /// Actual transaction total for this category
  ///
  /// Sum of all [TransactionModel.amount] for this category in the budget period.
  /// Represents the second bar in the side-by-side chart.
  ///
  /// **Calculation**: Sum of transaction amounts where `categoryId` matches.
  /// For credit transactions, amount is subtracted (income reduces spending).
  ///
  /// **Color**: Typically rendered in `colorScheme.secondary`
  final double transactionAmount;

  /// Creates chart data for one category.
  ///
  /// All fields are required. If a category has no allocation, use 0.0.
  /// If a category has no transactions, use 0.0.
  const TransactionsChartData({
    required this.categoryId,
    required this.categoryName,
    required this.categoryIconName,
    required this.allocationAmount,
    required this.transactionAmount,
  });

  /// Calculates the remaining budget for this category.
  ///
  /// Returns: `allocationAmount - transactionAmount`
  ///
  /// **Interpretation**:
  /// - Positive: Under budget, funds remaining
  /// - Zero: Exactly on budget
  /// - Negative: Over budget, overspending
  ///
  /// **Example**:
  /// ```dart
  /// final remaining = chartData.remainingBudget();
  /// if (remaining < 0) {
  ///   print('Over budget by \$${remaining.abs()}');
  /// }
  /// ```
  double remainingBudget() {
    return allocationAmount - transactionAmount;
  }

  /// Calculates the spending percentage for this category.
  ///
  /// Returns: `(transactionAmount / allocationAmount) * 100`
  ///
  /// **Special Cases**:
  /// - Returns 0% if allocation is 0 (avoid division by zero)
  /// - Can exceed 100% if overspending
  ///
  /// **Example**:
  /// ```dart
  /// final percent = chartData.spendingPercentage();
  /// print('${percent.toStringAsFixed(1)}% spent'); // "81.4% spent"
  /// ```
  double spendingPercentage() {
    if (allocationAmount <= 0) return 0.0;
    return (transactionAmount / allocationAmount) * 100;
  }

  /// Checks if this category is overspent.
  ///
  /// Returns `true` if actual spending exceeds allocated amount.
  ///
  /// **Example**:
  /// ```dart
  /// if (chartData.isOverspent()) {
  ///   // Show warning color
  /// }
  /// ```
  bool isOverspent() {
    return transactionAmount > allocationAmount;
  }

  /// Returns a string representation for debugging.
  ///
  /// **Example Output**:
  /// ```
  /// TransactionsChartData(
  ///   Groceries: allocated=$400.00, spent=$325.50, remaining=$74.50
  /// )
  /// ```
  @override
  String toString() {
    return 'TransactionsChartData('
        '$categoryName: '
        'allocated=\$${allocationAmount.toStringAsFixed(2)}, '
        'spent=\$${transactionAmount.toStringAsFixed(2)}, '
        'remaining=\$${remainingBudget().toStringAsFixed(2)}'
        ')';
  }

  /// Equality comparison based on category ID only.
  ///
  /// Two chart data objects are equal if they represent the same category.
  /// Amounts may differ (e.g., different budget periods).
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TransactionsChartData && other.categoryId == categoryId;
  }

  @override
  int get hashCode => categoryId.hashCode;
}

/// Helper extension for working with lists of chart data.
extension TransactionsChartDataListExtensions on List<TransactionsChartData> {
  /// Calculates total allocated amount across all categories.
  ///
  /// **Example**:
  /// ```dart
  /// final chartData = dashboardCubit.state.budgetPages.first.chartData;
  /// final totalBudget = chartData.totalAllocated(); // Sum of all allocations
  /// ```
  double totalAllocated() {
    return fold<double>(0, (sum, data) => sum + data.allocationAmount);
  }

  /// Calculates total spent amount across all categories.
  ///
  /// **Example**:
  /// ```dart
  /// final totalSpent = chartData.totalSpent();
  /// ```
  double totalSpent() {
    return fold<double>(0, (sum, data) => sum + data.transactionAmount);
  }

  /// Calculates total remaining budget across all categories.
  ///
  /// Can be negative if overall overspending.
  ///
  /// **Example**:
  /// ```dart
  /// final remaining = chartData.totalRemaining();
  /// if (remaining < 0) {
  ///   print('Overall budget exceeded by \$${remaining.abs()}');
  /// }
  /// ```
  double totalRemaining() {
    return totalAllocated() - totalSpent();
  }

  /// Filters to categories that are overspent.
  ///
  /// **Example**:
  /// ```dart
  /// final overspent = chartData.overspentCategories();
  /// if (overspent.isNotEmpty) {
  ///   print('${overspent.length} categories over budget');
  /// }
  /// ```
  List<TransactionsChartData> overspentCategories() {
    return where((data) => data.isOverspent()).toList();
  }

  /// Filters to categories with allocated funds (excludes zero allocations).
  ///
  /// Useful for displaying only categories included in the budget.
  ///
  /// **Example**:
  /// ```dart
  /// final budgeted = chartData.withAllocations();
  /// // Only show bars for categories actually in the budget
  /// ```
  List<TransactionsChartData> withAllocations() {
    return where((data) => data.allocationAmount > 0).toList();
  }

  /// Sorts by allocation amount (descending).
  ///
  /// Useful for displaying highest-budget categories first.
  ///
  /// **Example**:
  /// ```dart
  /// final sorted = chartData.sortedByAllocation();
  /// // Top budget categories appear first
  /// ```
  List<TransactionsChartData> sortedByAllocation() {
    final sorted = List<TransactionsChartData>.from(this);
    sorted.sort((a, b) => b.allocationAmount.compareTo(a.allocationAmount));
    return sorted;
  }

  /// Sorts by spending percentage (descending).
  ///
  /// Useful for highlighting categories closest to or exceeding budget.
  ///
  /// **Example**:
  /// ```dart
  /// final sorted = chartData.sortedBySpendingPercentage();
  /// // Categories with highest % spent appear first
  /// ```
  List<TransactionsChartData> sortedBySpendingPercentage() {
    final sorted = List<TransactionsChartData>.from(this);
    sorted.sort((a, b) {
      return b.spendingPercentage().compareTo(a.spendingPercentage());
    });
    return sorted;
  }
}
