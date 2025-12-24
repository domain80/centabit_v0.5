import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';

part 'budget_model.freezed.dart';
part 'budget_model.g.dart';

/// Represents a budget period with a total amount and date range.
///
/// A budget defines a spending limit for a specific time period. Multiple
/// allocations can be created to distribute the budget across categories.
///
/// **Example**:
/// ```dart
/// final budget = BudgetModel.create(
///   name: 'December 2025',
///   amount: 2000.0,
///   startDate: DateTime(2025, 12, 1),
///   endDate: DateTime(2025, 12, 31),
/// );
/// ```
///
/// **BAR Calculation**:
/// The budget's date range is crucial for calculating the Budget Available
/// Ratio (BAR), which compares spending rate to time elapsed:
/// ```
/// BAR = (totalSpent / budget.amount) / (elapsedDays / totalDays)
/// ```
///
/// **Related Models**:
/// - [AllocationModel]: Links budgets to categories with allocated amounts
/// - [TransactionModel]: Transactions can optionally reference a budget
@freezed
abstract class BudgetModel with _$BudgetModel {
  /// Creates a budget with all required fields.
  ///
  /// Use [BudgetModel.create] factory for creating new budgets with
  /// auto-generated IDs and timestamps.
  const factory BudgetModel({
    /// Unique identifier (UUID v4)
    required String id,

    /// Display name (e.g., "December 2025", "Q1 2026 Budget")
    required String name,

    /// Total budget amount
    ///
    /// This is distributed across categories via [AllocationModel]s.
    /// The sum of allocations may be less than this amount (unallocated funds).
    required double amount,

    /// Budget period start date (inclusive)
    ///
    /// Used in BAR calculation to determine time elapsed.
    /// Should be at start of day (00:00:00).
    required DateTime startDate,

    /// Budget period end date (inclusive)
    ///
    /// Used in BAR calculation to determine total period length.
    /// Should be at end of day (23:59:59) or start of next day.
    required DateTime endDate,

    /// Timestamp when budget was created
    required DateTime createdAt,

    /// Timestamp when budget was last modified
    required DateTime updatedAt,
  }) = _BudgetModel;

  /// Creates a new budget with auto-generated ID and timestamps.
  ///
  /// **Example**:
  /// ```dart
  /// final budget = BudgetModel.create(
  ///   name: 'January 2026',
  ///   amount: 2500.0,
  ///   startDate: DateTime(2026, 1, 1),
  ///   endDate: DateTime(2026, 1, 31, 23, 59, 59),
  /// );
  /// ```
  ///
  /// **Best Practices**:
  /// - Use month names or quarters for clarity
  /// - Set startDate to beginning of period
  /// - Set endDate to end of period
  /// - Amount should be total available, not sum of allocations
  factory BudgetModel.create({
    required String name,
    required double amount,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final now = DateTime.now();
    return BudgetModel(
      id: const Uuid().v4(),
      name: name,
      amount: amount,
      startDate: startDate,
      endDate: endDate,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Creates a budget from JSON.
  ///
  /// Used for deserialization from local storage or API responses.
  factory BudgetModel.fromJson(Map<String, dynamic> json) =>
      _$BudgetModelFromJson(json);
}

/// Extension methods for BudgetModel.
extension BudgetModelExtensions on BudgetModel {
  /// Checks if this budget is currently active.
  ///
  /// A budget is active if the current date/time falls within its period.
  ///
  /// **Example**:
  /// ```dart
  /// if (budget.isActive()) {
  ///   // Show in "Active Budgets" list
  /// }
  /// ```
  bool isActive() {
    final now = DateTime.now();
    return now.isAfter(startDate) && now.isBefore(endDate);
  }

  /// Calculates the total number of days in this budget period.
  ///
  /// Includes both start and end dates (+1).
  ///
  /// **Example**:
  /// ```dart
  /// final days = budget.totalDays(); // 31 for full month
  /// ```
  int totalDays() {
    return endDate.difference(startDate).inDays + 1;
  }

  /// Calculates the number of elapsed days in this budget period.
  ///
  /// Returns:
  /// - 0 if current date is before budget start
  /// - totalDays if current date is after budget end
  /// - Actual elapsed days (+1 for inclusive) otherwise
  ///
  /// **Used in BAR calculation**:
  /// ```dart
  /// final timeRatio = budget.elapsedDays() / budget.totalDays();
  /// ```
  int elapsedDays() {
    final now = DateTime.now();
    if (now.isBefore(startDate)) {
      return 0;
    } else if (now.isAfter(endDate)) {
      return totalDays();
    } else {
      return now.difference(startDate).inDays + 1;
    }
  }

  /// Returns a copy of this budget with updated timestamp.
  ///
  /// Convenience method for update operations.
  ///
  /// **Example**:
  /// ```dart
  /// final updated = budget.withUpdatedTimestamp().copyWith(amount: 2500);
  /// ```
  BudgetModel withUpdatedTimestamp() {
    return copyWith(updatedAt: DateTime.now());
  }
}
