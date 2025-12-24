import 'dart:async';

import 'package:centabit/data/services/category_service.dart';
import 'package:centabit/data/services/transaction_service.dart';
import 'package:centabit/features/transactions/presentation/cubits/transaction_list_state.dart';
import 'package:centabit/shared/v_models/transaction_v_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class TransactionListCubit extends Cubit<TransactionListState> {
  final TransactionService _transactionService;
  final CategoryService _categoryService;

  StreamSubscription? _transactionSubscription;
  StreamSubscription? _categorySubscription;

  int _currentPage = 0;
  static const int _pageSize = 20;

  TransactionListCubit(this._transactionService, this._categoryService)
    : super(const TransactionListState.initial()) {
    _subscribeToStreams();
  }

  void _subscribeToStreams() {
    // Listen to transaction changes
    _transactionSubscription = _transactionService.transactionsStream.listen((
      _,
    ) {
      _loadTransactions();
    });

    // Listen to category changes (affects denormalization)
    _categorySubscription = _categoryService.categoriesStream.listen((_) {
      _loadTransactions();
    });

    // Initial load
    _loadTransactions();
  }

  void _loadTransactions() {
    emit(const TransactionListState.loading());

    try {
      final transactions = _transactionService.getTransactionsPaginated(
        page: _currentPage,
        pageSize: _pageSize,
      );

      // Denormalize: combine transaction + category data
      final viewItems = transactions.map((transaction) {
        final category = transaction.categoryId != null
            ? _categoryService.getCategoryById(transaction.categoryId!)
            : null;

        return TransactionVModel(
          id: transaction.id,
          name: transaction.name,
          amount: transaction.amount,
          type: transaction.type,
          transactionDate: transaction.transactionDate,
          formattedDate: _formatDate(transaction.transactionDate),
          categoryId: transaction.categoryId,
          categoryName: category?.name,
          categoryIconName: category?.iconName,
          notes: transaction.notes,
        );
      }).toList();

      final hasMore = transactions.length == _pageSize;

      emit(
        TransactionListState.success(
          transactions: viewItems,
          currentPage: _currentPage,
          hasMore: hasMore,
        ),
      );
    } catch (e) {
      emit(TransactionListState.error(e.toString()));
    }
  }

  void loadNextPage() {
    _currentPage++;
    _loadTransactions();
  }

  Future<void> refresh() {
    _currentPage = 0;
    _loadTransactions();
    return Future.value();
  }

  Future<void> deleteTransaction(String id) async {
    await _transactionService.deleteTransaction(id);
    // Stream will automatically trigger reload
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return "Today | ${DateFormat('hh:mm a').format(date)}";
    } else if (transactionDate == yesterday) {
      return "Yesterday | ${DateFormat('hh:mm a').format(date)}";
    } else {
      return DateFormat('MMM d, yy | hh:mm a').format(date);
    }
  }

  @override
  Future<void> close() {
    _transactionSubscription?.cancel();
    _categorySubscription?.cancel();
    return super.close();
  }
}
