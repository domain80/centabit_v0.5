import 'dart:async';

import 'package:centabit/core/utils/date_formatter.dart';
import 'package:centabit/data/repositories/category_repository.dart';
import 'package:centabit/data/repositories/transaction_repository.dart';
import 'package:centabit/features/transactions/presentation/cubits/transaction_list_state.dart';
import 'package:centabit/shared/v_models/transaction_v_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionListCubit extends Cubit<TransactionListState> {
  final TransactionRepository _transactionRepository;
  final CategoryRepository _categoryRepository;

  StreamSubscription? _transactionSubscription;
  StreamSubscription? _categorySubscription;

  int _currentPage = 0;
  static const int _pageSize = 20;

  TransactionListCubit(this._transactionRepository, this._categoryRepository)
    : super(const TransactionListState.initial()) {
    _subscribeToStreams();
  }

  void _subscribeToStreams() {
    // Listen to transaction changes
    _transactionSubscription = _transactionRepository.transactionsStream.listen((
      _,
    ) {
      _loadTransactions();
    });

    // Listen to category changes (affects denormalization)
    _categorySubscription = _categoryRepository.categoriesStream.listen((_) {
      _loadTransactions();
    });

    // Initial load
    _loadTransactions();
  }

  void _loadTransactions() {
    // Extract current filters from state BEFORE emitting loading
    String searchQuery = '';
    DateTime? selectedDate;

    state.maybeWhen(
      success: (_, __, ___, query, date) {
        searchQuery = query;
        selectedDate = date;
      },
      orElse: () {},
    );

    emit(const TransactionListState.loading());

    try {

      // Get all transactions
      var allTransactions = _transactionRepository.transactions;

      // Apply search filter (if query exists)
      if (searchQuery.isNotEmpty) {
        print('Filtering ${allTransactions.length} transactions with query: "$searchQuery"');
        allTransactions = allTransactions.where((tx) {
          final category = tx.categoryId != null
              ? _categoryRepository.getCategoryByIdSync(tx.categoryId!)
              : null;

          final matchesName =
              tx.name.toLowerCase().contains(searchQuery.toLowerCase());
          final matchesCategory = category?.name
                  .toLowerCase()
                  .contains(searchQuery.toLowerCase()) ??
              false;

          return matchesName || matchesCategory;
        }).toList();
        print('After filtering: ${allTransactions.length} transactions');
      }

      // Apply pagination on filtered results
      final startIndex = _currentPage * _pageSize;
      final endIndex =
          (startIndex + _pageSize).clamp(0, allTransactions.length);

      if (startIndex >= allTransactions.length && allTransactions.isNotEmpty) {
        // No more pages
        List<TransactionVModel> currentTransactions = [];
        state.maybeWhen(
          success: (transactions, _, __, ___, ____) {
            currentTransactions = transactions;
          },
          orElse: () {},
        );

        emit(
          TransactionListState.success(
            transactions: currentTransactions,
            currentPage: _currentPage,
            hasMore: false,
            searchQuery: searchQuery,
            selectedDate: selectedDate,
          ),
        );
        return;
      }

      final pageTransactions = allTransactions.isNotEmpty
          ? allTransactions.sublist(startIndex, endIndex)
          : <dynamic>[];

      // Denormalize: combine transaction + category data
      final viewItems = pageTransactions.map((transaction) {
        final category = transaction.categoryId != null
            ? _categoryRepository.getCategoryByIdSync(transaction.categoryId!)
            : null;

        return TransactionVModel(
          id: transaction.id,
          name: transaction.name,
          amount: transaction.amount,
          type: transaction.type,
          transactionDate: transaction.transactionDate,
          formattedDate: DateFormatter.formatTransactionDateTime(
            transaction.transactionDate,
          ),
          formattedTime: DateFormatter.formatTime(transaction.transactionDate),
          categoryId: transaction.categoryId,
          categoryName: category?.name,
          categoryIconName: category?.iconName,
          notes: transaction.notes,
        );
      }).toList();

      final hasMore = endIndex < allTransactions.length;

      emit(
        TransactionListState.success(
          transactions: viewItems,
          currentPage: _currentPage,
          hasMore: hasMore,
          searchQuery: searchQuery,
          selectedDate: selectedDate,
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
    await _transactionRepository.deleteTransaction(id);
    // Stream will automatically trigger reload
  }

  /// Search transactions by name or category name
  void searchTransactions(String query) {
    print('TransactionListCubit.searchTransactions called with: "$query"');

    // Reset to page 0 when search changes
    _currentPage = 0;

    // Update state with new search query first
    state.maybeWhen(
      success: (transactions, currentPage, hasMore, _, selectedDate) {
        emit(TransactionListState.success(
          transactions: transactions,
          currentPage: currentPage,
          hasMore: hasMore,
          searchQuery: query,
          selectedDate: selectedDate,
        ));
      },
      orElse: () {},
    );

    // Reload with new search query
    _loadTransactions();
  }

  /// Set selected date for scroll-to-date functionality
  void setSelectedDate(DateTime? date) {
    print('TransactionListCubit.setSelectedDate called with: $date');

    // Just update state, don't reload (scroll happens in UI)
    state.maybeWhen(
      success: (transactions, currentPage, hasMore, searchQuery, _) {
        emit(TransactionListState.success(
          transactions: transactions,
          currentPage: currentPage,
          hasMore: hasMore,
          searchQuery: searchQuery,
          selectedDate: date,
        ));
        print('Emitted new state with selectedDate: $date');
      },
      orElse: () {
        print('setSelectedDate called but state is not success');
      },
    );
  }

  /// Clear all filters
  void clearFilters() {
    _currentPage = 0;

    // Clear filters and reload
    state.maybeWhen(
      success: (transactions, currentPage, hasMore, _, __) {
        emit(TransactionListState.success(
          transactions: transactions,
          currentPage: currentPage,
          hasMore: hasMore,
          searchQuery: '',
          selectedDate: null,
        ));
      },
      orElse: () {},
    );

    _loadTransactions();
  }

  @override
  Future<void> close() {
    _transactionSubscription?.cancel();
    _categorySubscription?.cancel();
    return super.close();
  }
}
