import 'package:centabit/core/di/injection.dart';
import 'package:centabit/core/localizations/app_localizations.dart';
import 'package:centabit/core/theme/theme_extensions.dart';
import 'package:centabit/core/utils/show_modal.dart';
import 'package:centabit/data/models/transaction_model.dart';
import 'package:centabit/data/repositories/transaction_repository.dart';
import 'package:centabit/features/dashboard/presentation/cubits/date_filter_cubit.dart';
import 'package:centabit/features/dashboard/presentation/cubits/date_filter_state.dart';
import 'package:centabit/features/transactions/presentation/widgets/transaction_form_modal.dart';
import 'package:centabit/shared/widgets/transaction_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Scrollable transaction list with auto-reset on date change.
///
/// This widget wraps the transaction list in its own scrollable container
/// and automatically scrolls to the top when the selected date changes.
///
/// **Features**:
/// - Independent scroll controller for transaction list only
/// - Auto-scroll to top on date change (300ms smooth animation)
/// - Minimum height constraint to prevent layout shifts
/// - Listens to DateFilterCubit for date changes
///
/// **Usage**:
/// ```dart
/// ScrollableTransactionList(
///   transactions: state.filteredTransactions,
///   selectedDate: state.selectedDate,
///   minHeight: screenHeight - 400,
/// )
/// ```
class ScrollableTransactionList extends StatefulWidget {
  final double minHeight;

  const ScrollableTransactionList({super.key, required this.minHeight});

  @override
  State<ScrollableTransactionList> createState() =>
      _ScrollableTransactionListState();
}

class _ScrollableTransactionListState extends State<ScrollableTransactionList> {
  late final ScrollController _scrollController;
  DateTime? _previousDate;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final spacing = theme.extension<AppSpacing>()!;
    final transactionRepository = getIt<TransactionRepository>();

    return BlocConsumer<DateFilterCubit, DateFilterState>(
      listenWhen: (previous, current) =>
          previous.selectedDate != current.selectedDate,
      listener: (context, state) {
        // Reset scroll position to top when date changes
        if (_previousDate != null &&
            _previousDate != state.selectedDate &&
            _scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
        _previousDate = state.selectedDate;
      },
      builder: (context, state) {
        // Empty state
        if (state.filteredTransactions.isEmpty) {
          return ConstrainedBox(
            constraints: BoxConstraints(minHeight: widget.minHeight),
            child: Column(
              mainAxisAlignment: .start,
              children: [
                SizedBox(height: spacing.xl4),
                Center(
                  child: Text(
                    l10n.noTransactionsForDate,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Transaction list with scroll
        return ConstrainedBox(
          constraints: BoxConstraints(minHeight: widget.minHeight),
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: state.filteredTransactions
                    .map(
                      (transaction) => TransactionTile(
                        transaction: transaction,
                        onEdit: () {
                          final transactionModel = transactionRepository
                              .transactions
                              .firstWhere((t) => t.id == transaction.id);

                          showModalBottomSheetUtil(
                            context,
                            builder: (_) => TransactionFormModal(
                              initialValue: transactionModel,
                            ),
                            modalFractionalHeight: 0.78,
                          );
                        },
                        onDelete: () {
                          transactionRepository.deleteTransaction(
                            transaction.id,
                          );
                        },
                        onCopy: () {
                          final original = transactionRepository.transactions
                              .firstWhere((t) => t.id == transaction.id);
                          final copy = TransactionModel.create(
                            name: original.name,
                            amount: original.amount,
                            type: original.type,
                            transactionDate: DateTime.now(),
                            categoryId: original.categoryId,
                            budgetId: original.budgetId,
                            notes: original.notes,
                          );

                          showModalBottomSheetUtil(
                            context,
                            builder: (_) => TransactionFormModal(
                              initialValue: copy,
                              isCopy: true,
                            ),
                            modalFractionalHeight: 0.78,
                          );
                        },
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        );
      },
    );
  }
}
