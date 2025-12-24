import 'package:centabit/core/di/injection.dart';
import 'package:centabit/core/localizations/app_localizations.dart';
import 'package:centabit/data/services/transaction_service.dart';
import 'package:centabit/features/dashboard/presentation/cubits/date_filter_cubit.dart';
import 'package:centabit/features/dashboard/presentation/cubits/date_filter_state.dart';
import 'package:centabit/shared/widgets/custom_date_picker.dart';
import 'package:centabit/shared/widgets/infinite_date_scroller.dart';
import 'package:centabit/shared/widgets/transaction_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Daily transactions section with date filtering.
///
/// Displays transactions for the selected date with:
/// - Header with "Transactions" title and calendar picker
/// - Divider
/// - Infinite date scroller for quick date selection
/// - Divider
/// - Transaction list (or empty state)
///
/// **Ported from v0.4**: `lib/ui/transactions/widgets/daily_transactions_section.dart`
/// **Adaptations for v0.5**:
/// - Replaced `CommandBuilder` with `BlocBuilder<DateFilterCubit, DateFilterState>`
/// - Removed `AppTextStyles` dependency (uses theme text styles)
/// - Uses `TransactionService` directly for delete operations
/// - Leave edit/copy callbacks empty (TODO for future)
/// - Maintains all layout and visual design
///
/// **Architecture**:
/// - Uses `DateFilterCubit` for date selection and filtering
/// - Reacts to cubit state changes (selected date, filtered transactions)
/// - Calls `TransactionService.deleteTransaction()` directly
///
/// **Features**:
/// 1. **Date Picker**: Tap calendar icon to show modal date picker
/// 2. **Infinite Date Scroller**: Swipe or tap dates to filter
/// 3. **Transaction List**: Shows transactions for selected date
/// 4. **Empty State**: "No transactions for this date" message
/// 5. **Swipe to Delete**: Dismissible transaction tiles with confirmation
///
/// **Layout**:
/// ```
/// ┌──────────────────────────────────┐
/// │ Transactions            📅       │  <- Header with picker
/// ├──────────────────────────────────┤
/// │  Mon  Tue  Wed  Thu  Fri  Sat    │  <- Date scroller
/// │   19   20  [21]  22   23   24    │
/// ├──────────────────────────────────┤
/// │ 🛒 Groceries         -$45.23     │  <- Transaction tile
/// │ 🍔 Dining            -$28.50     │
/// │ ...                              │
/// └──────────────────────────────────┘
/// ```
///
/// **Usage**:
/// ```dart
/// BlocProvider(
///   create: (_) => getIt<DateFilterCubit>(),
///   child: DailyTransactionsSection(),
/// )
/// ```
class DailyTransactionsSection extends StatelessWidget {
  const DailyTransactionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<DateFilterCubit, DateFilterState>(
      builder: (context, state) {
        final cubit = context.read<DateFilterCubit>();

        return Column(
          children: [
            // HEADER with title and calendar picker
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.transactionsForDate,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Calendar picker icon
                  CustomDatePicker(
                    currentDate: state.selectedDate,
                    onDateChanged: (newDate) => cubit.changeDate(newDate),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Divider
            Divider(
              color: colorScheme.onSurface.withValues(alpha: 0.2),
              indent: 26,
              endIndent: 26,
            ),

            // INFINITE DATE SCROLLER
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: InfiniteDateScroller(
                currentDate: state.selectedDate,
                onDateChanged: (newDate) => cubit.changeDate(newDate),
              ),
            ),

            // Divider
            Divider(
              color: colorScheme.onSurface.withValues(alpha: 0.2),
              indent: 26,
              endIndent: 26,
            ),

            // TRANSACTIONS LIST
            _buildTransactionsList(context, state, l10n, theme),

            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  /// Builds the transactions list or empty state.
  ///
  /// **Empty State**: Shows centered message when no transactions exist
  /// **Transaction List**: Shows column of TransactionTile widgets
  ///
  /// **Delete Behavior**:
  /// - Swipe transaction tile left to reveal delete
  /// - Confirmation dialog appears
  /// - On confirm: calls TransactionService.deleteTransaction()
  /// - DateFilterCubit automatically reacts to service change
  ///
  /// **TODO**:
  /// - Wire up onEdit callback (navigate to edit form)
  /// - Wire up onCopy callback (duplicate transaction)
  ///
  /// **Parameters**:
  /// - `context`: Build context
  /// - `state`: Current date filter state
  /// - `l10n`: Localization strings
  /// - `theme`: Theme data
  ///
  /// **Returns**: Widget showing transactions or empty state
  Widget _buildTransactionsList(
    BuildContext context,
    DateFilterState state,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    // Empty state: no transactions for selected date
    if (state.filteredTransactions.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            l10n.noTransactionsForDate,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    }

    // Transaction list
    final transactionService = getIt<TransactionService>();

    return Column(
      children: state.filteredTransactions
          .map(
            (transaction) => TransactionTile(
              transaction: transaction,
              // Delete: wire up to TransactionService
              onDelete: () {
                transactionService.deleteTransaction(transaction.id);
              },
              // TODO: Wire up edit and copy callbacks
              onEdit: null, // TODO: Navigate to edit form
              onCopy: null, // TODO: Duplicate transaction
            ),
          )
          .toList(),
    );
  }
}
