import 'dart:ui';

import 'package:centabit/core/di/injection.dart';
import 'package:centabit/core/router/navigation/nav_cubit.dart';
import 'package:centabit/core/router/navigation/nav_scroll_behavior.dart';
import 'package:centabit/core/theme/theme_extensions.dart';
import 'package:centabit/core/utils/date_formatter.dart';
import 'package:centabit/core/utils/show_modal.dart';
import 'package:centabit/data/models/transaction_model.dart';
import 'package:centabit/data/repositories/transaction_repository.dart';
import 'package:centabit/features/transactions/presentation/cubits/transaction_list_cubit.dart';
import 'package:centabit/features/transactions/presentation/cubits/transaction_list_state.dart';
import 'package:centabit/features/transactions/presentation/widgets/transaction_form_modal.dart';
import 'package:centabit/shared/v_models/transaction_v_model.dart';
import 'package:centabit/shared/widgets/custom_date_picker_icon.dart';
import 'package:centabit/shared/widgets/shared_app_bar.dart';
import 'package:centabit/shared/widgets/transaction_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sticky_grouped_list/sticky_grouped_list.dart';

/// Transactions page displaying a list of all transactions
///
/// Features:
/// - Search-enabled navigation variant
/// - Searchable transaction list
/// - Transaction management (delete, edit, copy)
class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TransactionListCubit>(),
      child: const _TransactionsView(),
    );
  }
}

class _TransactionsView extends StatefulWidget {
  const _TransactionsView();

  @override
  State<_TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends State<_TransactionsView> {
  final GroupedItemScrollController _scrollController =
      GroupedItemScrollController();

  NavCubit? _navCubit; // Store reference to avoid context access in dispose

  @override
  void initState() {
    super.initState();

    // Register filter action widget when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _navCubit = context.read<NavCubit>();
        _navCubit?.setFilterAction(
          CustomDatePickerIcon(
            currentDate: DateTime.now(),
            onDateChanged: (date) {
              context.read<TransactionListCubit>().setSelectedDate(date);
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    // Clear filter action when leaving page (using stored reference)
    _navCubit?.setFilterAction(null);
    super.dispose();
  }

  void _scrollToDate(DateTime date, List<TransactionVModel> transactions) {
    final normalizedDate = DateFormatter.normalizeToDay(date);

    // Find the index of the first transaction that matches the target date
    final index = transactions.indexWhere((transaction) {
      final transactionDate = DateFormatter.normalizeToDay(
        transaction.transactionDate,
      );
      return transactionDate == normalizedDate;
    });

    if (index != -1) {
      _scrollController.scrollTo(
        index: index,
        automaticAlignment: true,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final spacing = Theme.of(context).extension<AppSpacing>()!;

    return Scaffold(
      appBar: sharedAppBar(context, title: const Text('Transactions')),
      body: NavScrollWrapper(
        child: BlocBuilder<TransactionListCubit, TransactionListState>(
          builder: (context, state) {
            return BlocListener<NavCubit, NavState>(
              listenWhen: (prev, curr) => prev.searchQuery != curr.searchQuery,
              listener: (context, navState) {
                // Page receives search query updates from nav bar
                if (navState.searchQuery.isNotEmpty) {
                  context.read<TransactionListCubit>().searchTransactions(
                    navState.searchQuery,
                  );
                } else {
                  // Clear search when query is empty
                  context.read<TransactionListCubit>().clearFilters();
                }
              },
              child: BlocListener<TransactionListCubit, TransactionListState>(
                listenWhen: (prev, curr) {
                  DateTime? prevDate;
                  DateTime? currDate;

                  prev.maybeWhen(
                    success: (_, _, _, _, date) => prevDate = date,
                    orElse: () {},
                  );

                  curr.maybeWhen(
                    success: (_, _, _, _, date) => currDate = date,
                    orElse: () {},
                  );

                  return prevDate != currDate;
                },
                listener: (context, state) {
                  state.maybeWhen(
                    success: (transactions, _, _, _, selectedDate) {
                      if (selectedDate != null) {
                        _scrollToDate(selectedDate, transactions);
                      }
                    },
                    orElse: () {},
                  );
                },
                child: state.when(
                  initial: () => const SizedBox(),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  success: (transactions, _, _, _, _) {
                    if (transactions.isEmpty) {
                      return RefreshIndicator(
                        onRefresh: () {
                          context.read<TransactionListCubit>().refresh();
                          return Future<void>.delayed(
                            const Duration(milliseconds: 300),
                          );
                        },
                        child: const Center(child: Text('No transactions yet')),
                      );
                    }

                    return StickyGroupedListView<TransactionVModel, DateTime>(
                      elements: transactions.toList(),
                      groupBy: (transaction) => DateFormatter.normalizeToDay(
                        transaction.transactionDate,
                      ),
                      groupSeparatorBuilder: (TransactionVModel transaction) {
                        final date = DateFormatter.normalizeToDay(
                          transaction.transactionDate,
                        );
                        return _buildDateHeader(context, date, spacing);
                      },
                      itemBuilder: (context, TransactionVModel transaction) {
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: spacing.lg),
                          child: TransactionTile(
                            transaction: transaction,
                            onEdit: () {
                              final transactionModel =
                                  getIt<TransactionRepository>().transactions
                                      .firstWhere(
                                        (t) => t.id == transaction.id,
                                      );

                              showModalBottomSheetUtil(
                                context,
                                builder: (_) => TransactionFormModal(
                                  initialValue: transactionModel,
                                ),
                                modalFractionalHeight: 0.78,
                              );
                            },
                            onDelete: () => context
                                .read<TransactionListCubit>()
                                .deleteTransaction(transaction.id),
                            onCopy: () {
                              final original = getIt<TransactionRepository>()
                                  .transactions
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
                                builder: (_) =>
                                    TransactionFormModal(initialValue: copy),
                                modalFractionalHeight: 0.78,
                              );
                            },
                          ),
                        );
                      },
                      itemScrollController: _scrollController,
                      floatingHeader: true,
                      order: StickyGroupedListOrder.DESC,
                      separator: const SizedBox.shrink(),
                      padding: EdgeInsets.only(bottom: 120),
                    );
                  },
                  error: (message) => Center(child: Text('Error: $message')),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Builds a sticky date header widget.
  ///
  /// Displays "Today", "Yesterday", or formatted date (e.g., "December 24, 2024").
  /// Has a surface background color so it's not transparent when sticking.
  Widget _buildDateHeader(
    BuildContext context,
    DateTime date,
    AppSpacing spacing,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final dateLabel = DateFormatter.formatHeaderDate(date);

    // Full-width blur background that stretches across the page
    return SizedBox(
      width: double.infinity,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
          child: Container(
            width: double.infinity,
            color: colorScheme.surface.withAlpha(200),
            padding: EdgeInsets.only(
              left: spacing.lg,
              right: spacing.lg,
              top: spacing.md,
              bottom: spacing.sm,
            ),
            child: Text(
              dateLabel,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
