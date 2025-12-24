import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:centabit/shared/v_models/transaction_v_model.dart';

part 'date_filter_state.freezed.dart';

/// State for date-filtered transactions in the dashboard.
///
/// Represents the currently selected date and the transactions for that date.
/// Used by the Daily Transactions Section to display filtered transaction lists.
///
/// **Simple State Structure**:
/// Unlike DashboardState, this doesn't need loading/error states because:
/// - Filtering is synchronous and fast
/// - Always has a valid date (defaults to today)
/// - Empty list is a valid state (no transactions on that date)
///
/// **Usage**:
/// ```dart
/// BlocBuilder<DateFilterCubit, DateFilterState>(
///   builder: (context, state) {
///     return Column(
///       children: [
///         Text('Date: ${state.selectedDate}'),
///         if (state.filteredTransactions.isEmpty)
///           Text('No transactions for this date')
///         else
///           ...state.filteredTransactions.map((tx) => TransactionTile(tx)),
///       ],
///     );
///   },
/// )
/// ```
@freezed
abstract class DateFilterState with _$DateFilterState {
  /// Creates date filter state with selected date and filtered transactions.
  ///
  /// **Parameters**:
  /// - `selectedDate`: The date to filter by (no time component)
  /// - `filteredTransactions`: Transactions on this date (can be empty)
  ///
  /// **Invariants**:
  /// - `selectedDate` should have time set to 00:00:00 for accurate comparison
  /// - `filteredTransactions` is sorted by transaction date (newest first)
  /// - Each transaction in list has `transactionDate` matching `selectedDate` (day/month/year)
  const factory DateFilterState({
    /// The currently selected date for filtering.
    ///
    /// Used to filter transactions and display in the date picker.
    /// Should be normalized to start of day (00:00:00) for accurate comparison.
    ///
    /// **Default**: Today's date
    required DateTime selectedDate,

    /// Transactions that occurred on the selected date.
    ///
    /// **Denormalized**: Each [TransactionVModel] includes:
    /// - Transaction data (name, amount, type, date)
    /// - Category data (name, icon)
    /// - Formatted date string
    ///
    /// **Sorted**: Newest to oldest by transaction time
    ///
    /// **Empty List**: Valid state when no transactions exist for selected date
    required List<TransactionVModel> filteredTransactions,
  }) = _DateFilterState;
}
