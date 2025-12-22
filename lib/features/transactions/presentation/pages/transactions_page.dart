import 'package:centabit/core/di/injection.dart';
import 'package:centabit/core/router/navigation/nav_cubit.dart';
import 'package:centabit/core/theme/theme_extensions.dart';
import 'package:centabit/features/transactions/presentation/cubits/transaction_list_cubit.dart';
import 'package:centabit/features/transactions/presentation/cubits/transaction_list_state.dart';
import 'package:centabit/shared/widgets/shared_app_bar.dart';
import 'package:centabit/shared/widgets/transaction_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
      child: Builder(
        builder: (context) {
          // Enable search for this page with scope context
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<NavCubit>().enableSearch(true, scope: 'transactions');
          });

          return Scaffold(
            appBar: sharedAppBar(context, title: const Text('Transactions')),
            body: BlocBuilder<TransactionListCubit, TransactionListState>(
              builder: (context, state) {
                return BlocListener<NavCubit, NavState>(
                  listenWhen: (prev, curr) =>
                      prev.searchQuery != curr.searchQuery,
                  listener: (context, navState) {
                    // Page receives search query updates
                    if (navState.searchQuery.isNotEmpty) {
                      // TODO: Implement searchTransactions in TransactionListCubit
                      // context.read<TransactionListCubit>()
                      //     .searchTransactions(navState.searchQuery);
                    } else {
                      // Reload all transactions when search is cleared
                      // TODO: Implement in TransactionListCubit if needed
                    }
                  },
                  child: state.when(
                    initial: () => const SizedBox(),
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    success: (transactions, _, _) {
                      if (transactions.isEmpty) {
                        return const Center(child: Text('No transactions yet'));
                      }

                      final spacing = Theme.of(
                        context,
                      ).extension<AppSpacing>()!;

                      return ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: spacing.lg),
                        itemCount: transactions.length,
                        itemBuilder: (context, index) => TransactionTile(
                          transaction: transactions[index],
                          onEdit: () {
                            // TODO: Implement edit transaction
                          },
                          onDelete: () => context
                              .read<TransactionListCubit>()
                              .deleteTransaction(transactions[index].id),
                          onCopy: () {
                            // TODO: Implement copy transaction
                          },
                        ),
                      );
                    },
                    error: (message) => Center(child: Text('Error: $message')),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
