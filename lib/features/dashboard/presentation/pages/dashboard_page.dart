import 'package:centabit/core/di/injection.dart';
import 'package:centabit/core/theme/theme_extensions.dart';
import 'package:centabit/features/transactions/presentation/cubits/transaction_list_cubit.dart';
import 'package:centabit/features/transactions/presentation/cubits/transaction_list_state.dart';
import 'package:centabit/shared/widgets/shared_app_bar.dart';
import 'package:centabit/shared/widgets/transaction_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Dashboard page - main screen after login
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TransactionListCubit>(),
      child: const _DashboardView(),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final spacing = theme.extension<AppSpacing>()!;

    return Scaffold(
      appBar: sharedAppBar(
        context,
        title: Row(
          children: [
            _buildWavingHand(),
            SizedBox(width: spacing.sm),
            const Text('Hi David'),
          ],
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: spacing.lg),
        child: BlocBuilder<TransactionListCubit, TransactionListState>(
          builder: (context, state) {
            return state.when(
              initial: () => const SizedBox(),
              loading: () => const Center(child: CircularProgressIndicator()),
              success: (transactions, currentPage, hasMore) {
                if (transactions.isEmpty) {
                  return Center(
                    child: Text(
                      'No transactions yet',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = transactions[index];
                    return TransactionTile(
                      transaction: transaction,
                      onEdit: () {
                        // TODO: Navigate to edit transaction
                      },
                      onDelete: () {
                        context.read<TransactionListCubit>().deleteTransaction(
                          transaction.id,
                        );
                      },
                      onCopy: () {
                        // TODO: Copy transaction
                      },
                    );
                  },
                );
              },
              error: (message) => Center(
                child: Text(
                  'Error: $message',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.error,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  TweenAnimationBuilder<double> _buildWavingHand() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(seconds: 2), // 2 waves total
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        // creates back-forth-back-forth
        final wave = (value * 4);
        final t = wave <= 2
            ? (wave <= 1 ? wave : 2 - wave)
            : (wave <= 3 ? wave - 2 : 4 - wave);

        return Transform.rotate(
          angle: 0.3 * t,
          origin: const Offset(12, 0),
          child: child,
        );
      },
      child: const Text("👋"),
    );
  }
}
