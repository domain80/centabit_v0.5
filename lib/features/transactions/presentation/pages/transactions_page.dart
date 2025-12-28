import 'dart:ui';

import 'package:centabit/core/di/injection.dart';
import 'package:centabit/core/router/navigation/nav_cubit.dart';
import 'package:centabit/core/router/navigation/nav_scroll_behavior.dart';
import 'package:centabit/core/theme/theme_extensions.dart';
import 'package:centabit/features/transactions/presentation/cubits/transaction_list_cubit.dart';
import 'package:centabit/features/transactions/presentation/cubits/transaction_list_state.dart';
import 'package:centabit/shared/v_models/transaction_v_model.dart';
import 'package:centabit/shared/widgets/shared_app_bar.dart';
import 'package:centabit/shared/widgets/transaction_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import 'package:intl/intl.dart';

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
  final Map<DateTime, GlobalKey> _dateKeys = {};

  void _scrollToDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final key = _dateKeys[normalizedDate];

    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        alignment: 0.0, // Align header to top
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
                  context
                      .read<TransactionListCubit>()
                      .searchTransactions(navState.searchQuery);
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
                    success: (_, __, ___, ____, date) => prevDate = date,
                    orElse: () {},
                  );

                  curr.maybeWhen(
                    success: (_, __, ___, ____, date) => currDate = date,
                    orElse: () {},
                  );

                  return prevDate != currDate;
                },
                listener: (context, state) {
                  state.maybeWhen(
                    success: (_, __, ___, ____, selectedDate) {
                      if (selectedDate != null) {
                        _scrollToDate(selectedDate);
                      }
                    },
                    orElse: () {},
                  );
                },
                child: state.when(
                initial: () => const SizedBox(),
                loading: () => const Center(child: CircularProgressIndicator()),
                success: (transactions, _, __, ___, ____) {
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

                  // Group transactions by date
                  final groupedTransactions = _groupTransactionsByDate(
                    transactions,
                  );

                  // Sort dates descending (newest first)
                  final sortedDates = groupedTransactions.keys.toList()
                    ..sort((a, b) => b.compareTo(a));

                  return RefreshIndicator(
                    onRefresh: () {
                      context.read<TransactionListCubit>().refresh();
                      return Future<void>.delayed(
                        const Duration(milliseconds: 300),
                      );
                    },
                    child: CustomScrollView(
                      slivers: [
                        ...sortedDates.map((date) {
                          final dateTransactions = groupedTransactions[date]!;

                          return SliverStickyHeader(
                            header: _buildDateHeader(context, date, spacing),
                            sliver: SliverPadding(
                              padding: EdgeInsets.symmetric(
                                horizontal: spacing.lg,
                              ),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate((
                                  context,
                                  index,
                                ) {
                                  return TransactionTile(
                                    transaction: dateTransactions[index],
                                    onEdit: () {
                                      // TODO: Implement edit transaction
                                    },
                                    onDelete: () => context
                                        .read<TransactionListCubit>()
                                        .deleteTransaction(
                                          dateTransactions[index].id,
                                        ),
                                    onCopy: () {
                                      // TODO: Implement copy transaction
                                    },
                                  );
                                }, childCount: dateTransactions.length),
                              ),
                            ),
                          );
                        }),

                        // Bottom padding for navigation bar
                        const SliverToBoxAdapter(child: SizedBox(height: 120)),
                      ],
                    ),
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

  /// Groups transactions by their transaction date (normalized to day).
  ///
  /// Returns a Map where:
  /// - Key: DateTime (normalized to start of day)
  /// - Value: List of transactions for that date
  Map<DateTime, List<TransactionVModel>> _groupTransactionsByDate(
    List<TransactionVModel> transactions,
  ) {
    final Map<DateTime, List<TransactionVModel>> grouped = {};

    for (final transaction in transactions) {
      final date = DateTime(
        transaction.transactionDate.year,
        transaction.transactionDate.month,
        transaction.transactionDate.day,
      );

      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(transaction);
    }

    return grouped;
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

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    // Normalize date for key lookup
    final normalizedDate = DateTime(date.year, date.month, date.day);

    // Create or retrieve key for this date
    _dateKeys.putIfAbsent(normalizedDate, () => GlobalKey());

    String dateLabel;
    if (date == today) {
      dateLabel = "Today";
    } else if (date == yesterday) {
      dateLabel = "Yesterday";
    } else {
      dateLabel = DateFormat('MMMM d, y').format(date);
    }

    // blur background
    return ClipRRect(
      key: _dateKeys[normalizedDate],
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
        child: Container(
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
              // fontWeight: FontWeight.n,
              color: colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ),
      ),
    );
  }
}

//     return Container(
//       color: colorScheme.surface.withAlpha(100),
//       padding: EdgeInsets.only(
//         left: spacing.lg,
//         right: spacing.lg,
//         top: spacing.md,
//         bottom: spacing.sm,
//       ),
//       child: Text(
//         dateLabel,
//         style: theme.textTheme.bodySmall?.copyWith(
//           // fontWeight: FontWeight.n,
//           color: colorScheme.onSurface.withValues(alpha: 0.8),
//         ),
//       ),
//     );
//   }
// }
