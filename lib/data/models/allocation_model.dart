import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'allocation_model.freezed.dart';
part 'allocation_model.g.dart';

/// Represents an allocation of budget funds to a specific category.
///
/// Allocations distribute a budget's total amount across different spending
/// categories. The sum of all allocations for a budget may be less than the
/// budget's total amount (unallocated funds).
///
/// **Example**:
/// ```dart
/// final allocation = AllocationModel.create(
///   amount: 400.0,
///   categoryId: groceriesCategoryId,
///   budgetId: decemberBudgetId,
/// );
/// ```
///
/// **Relationship**:
/// ```
/// Budget (1) ──< (N) Allocations ──> (1) Category
/// ```
///
/// **Used For**:
/// - Budget planning: Distribute total budget across categories
/// - Chart data: Compare allocated amounts vs actual spending
/// - BAR calculation: Total allocations = total budgeted amount
@freezed
abstract class AllocationModel with _$AllocationModel {
  /// Creates an allocation with all required fields.
  ///
  /// Use [AllocationModel.create] factory for creating new allocations with
  /// auto-generated IDs and timestamps.
  const factory AllocationModel({
    /// Unique identifier (UUID v4)
    required String id,

    /// Amount allocated to this category in this budget
    ///
    /// Should be positive and typically less than the budget's total amount.
    /// Multiple allocations for the same budget should sum to <= budget.amount.
    required double amount,

    /// Reference to the category receiving this allocation
    ///
    /// Links to [CategoryModel.id].
    required String categoryId,

    /// Reference to the parent budget
    ///
    /// Links to [BudgetModel.id].
    required String budgetId,

    /// Timestamp when allocation was created
    required DateTime createdAt,

    /// Timestamp when allocation was last modified
    required DateTime updatedAt,
  }) = _AllocationModel;

  /// Creates a new allocation with auto-generated ID and timestamps.
  ///
  /// **Example**:
  /// ```dart
  /// final allocation = AllocationModel.create(
  ///   amount: 300.0,
  ///   categoryId: diningCategoryId,
  ///   budgetId: januaryBudgetId,
  /// );
  /// ```
  ///
  /// **Validation Considerations**:
  /// - Amount should be positive
  /// - CategoryId must exist in CategoryService
  /// - BudgetId must exist in BudgetService
  /// - Sum of allocations shouldn't exceed budget.amount (soft limit)
  factory AllocationModel.create({
    required double amount,
    required String categoryId,
    required String budgetId,
  }) {
    final now = DateTime.now();
    return AllocationModel(
      id: const Uuid().v4(),
      amount: amount,
      categoryId: categoryId,
      budgetId: budgetId,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Creates an allocation from JSON.
  ///
  /// Used for deserialization from local storage or API responses.
  factory AllocationModel.fromJson(Map<String, dynamic> json) =>
      _$AllocationModelFromJson(json);
}

/// Extension methods for AllocationModel.
extension AllocationModelExtensions on AllocationModel {
  /// Returns a copy of this allocation with updated timestamp.
  ///
  /// Convenience method for update operations.
  ///
  /// **Example**:
  /// ```dart
  /// final updated = allocation.withUpdatedTimestamp().copyWith(amount: 450);
  /// ```
  AllocationModel withUpdatedTimestamp() {
    return copyWith(updatedAt: DateTime.now());
  }

  /// Validates that the allocation amount is positive.
  ///
  /// **Example**:
  /// ```dart
  /// if (!allocation.isValidAmount()) {
  ///   throw Exception('Allocation amount must be positive');
  /// }
  /// ```
  bool isValidAmount() {
    return amount > 0;
  }
}

/// Helper extension for working with lists of allocations.
extension AllocationListExtensions on List<AllocationModel> {
  /// Calculates the total amount across all allocations.
  ///
  /// **Example**:
  /// ```dart
  /// final allocations = allocationService.getAllocationsForBudget(budgetId);
  /// final totalAllocated = allocations.totalAmount(); // Sum of all amounts
  /// ```
  double totalAmount() {
    return fold<double>(0, (sum, allocation) => sum + allocation.amount);
  }

  /// Groups allocations by category ID.
  ///
  /// Returns a map where keys are category IDs and values are lists of
  /// allocations for that category.
  ///
  /// **Example**:
  /// ```dart
  /// final byCategory = allocations.groupByCategory();
  /// byCategory[groceriesCategoryId]?.forEach((alloc) {
  ///   print('${alloc.amount} in ${alloc.budgetId}');
  /// });
  /// ```
  Map<String, List<AllocationModel>> groupByCategory() {
    final Map<String, List<AllocationModel>> grouped = {};
    for (final allocation in this) {
      grouped.putIfAbsent(allocation.categoryId, () => []).add(allocation);
    }
    return grouped;
  }

  /// Groups allocations by budget ID.
  ///
  /// Returns a map where keys are budget IDs and values are lists of
  /// allocations for that budget.
  ///
  /// **Example**:
  /// ```dart
  /// final byBudget = allocations.groupByBudget();
  /// final decAllocations = byBudget[decemberBudgetId] ?? [];
  /// ```
  Map<String, List<AllocationModel>> groupByBudget() {
    final Map<String, List<AllocationModel>> grouped = {};
    for (final allocation in this) {
      grouped.putIfAbsent(allocation.budgetId, () => []).add(allocation);
    }
    return grouped;
  }

  /// Finds all allocations for a specific budget.
  ///
  /// Convenience method for filtering by budget ID.
  ///
  /// **Example**:
  /// ```dart
  /// final januaryAllocations = allAllocations.forBudget(januaryBudgetId);
  /// ```
  List<AllocationModel> forBudget(String budgetId) {
    return where((a) => a.budgetId == budgetId).toList();
  }

  /// Finds all allocations for a specific category.
  ///
  /// Convenience method for filtering by category ID.
  ///
  /// **Example**:
  /// ```dart
  /// final groceryAllocations = allAllocations.forCategory(groceriesCategoryId);
  /// ```
  List<AllocationModel> forCategory(String categoryId) {
    return where((a) => a.categoryId == categoryId).toList();
  }
}
