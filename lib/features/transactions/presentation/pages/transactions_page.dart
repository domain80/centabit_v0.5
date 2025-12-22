import 'package:centabit/core/di/injection.dart';
import 'package:centabit/core/theme/theme_extensions.dart';
import 'package:centabit/features/transactions/presentation/cubits/transaction_list_cubit.dart';
import 'package:centabit/features/transactions/presentation/cubits/transaction_list_state.dart';
import 'package:centabit/shared/widgets/transaction_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Transactions page displaying a list of all transactions
class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TransactionListCubit>(),
      child: Scaffold(
        appBar: AppBar(title: const Text('Transactions')),
        body: BlocBuilder<TransactionListCubit, TransactionListState>(
          builder: (context, state) {
            return state.when(
              initial: () => const SizedBox(),
              loading: () => const Center(child: CircularProgressIndicator()),
              success: (transactions, _, __) {
                if (transactions.isEmpty) {
                  return const Center(child: Text('No transactions yet'));
                }

                final spacing = Theme.of(context).extension<AppSpacing>()!;

                return ListView.builder(
                  padding: EdgeInsets.all(spacing.lg),
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
            );
          },
        ),
      ),
    );
  }
}
