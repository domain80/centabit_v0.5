import 'dart:async';

import 'package:centabit/core/utils/date_formatter.dart';
import 'package:centabit/data/repositories/category_repository.dart';
import 'package:centabit/data/repositories/transaction_repository.dart';
import 'package:centabit/features/dashboard/presentation/cubits/date_filter_state.dart';
import 'package:centabit/shared/v_models/transaction_v_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Cubit for managing date-filtered transaction display.
///
/// Filters transactions by selected date and denormalizes them with category
/// data for UI display. Used by Daily Transactions Section in the dashboard.
///
/// **Architecture Pattern**: MVVM with Cubit
/// - Separate from DashboardCubit (Single Responsibility Principle)
/// - Reusable for other date-filtered views
/// - Direct service access (no repository needed)
///
/// **Responsibilities**:
/// 1. Manage selected date
/// 2. Filter transactions by date (day/month/year match)
/// 3. Denormalize transactions with category data
/// 4. Format dates for display
/// 5. React to transaction/category changes
///
/// **Data Flow**:
/// ```
/// User selects date (InfiniteDateScroller)
///   ↓
/// changeDate(newDate)
///   ↓
/// _filterTransactionsByDate(newDate)
///   ↓
/// Filter: transactions where date matches
///   ↓
/// Denormalize: add category name/icon
///   ↓
/// Format: add smart date string
///   ↓
/// Emit: DateFilterState(date, filteredTransactions)
///   ↓
/// UI: DailyTransactionsSection rebuilds
/// ```
///
/// **Usage**:
/// ```dart
/// BlocProvider(
///   create: (_) => getIt<DateFilterCubit>(),
///   child: DashboardPage(),
/// )
///
/// // In widget:
/// InfiniteDateScroller(
///   currentDate: state.selectedDate,
///   onDateChanged: (date) {
///     context.read<DateFilterCubit>().changeDate(date);
///   },
/// )
/// ```
class DateFilterCubit extends Cubit<DateFilterState> {
  final TransactionRepository _transactionRepository;
  final CategoryRepository _categoryRepository;

  // Stream subscriptions for reactive updates
  StreamSubscription? _transactionSubscription;
  StreamSubscription? _categorySubscription;

  /// Creates date filter cubit with service dependencies.
  ///
  /// Initializes with today's date and starts listening to service streams.
  ///
  /// **Example** (via GetIt):
  /// ```dart
  /// final cubit = getIt<DateFilterCubit>();
  /// ```
  DateFilterCubit(
    this._transactionRepository,
    this._categoryRepository,
  ) : super(DateFilterState(
          selectedDate: DateFormatter.normalizeToDay(DateTime.now()),
          filteredTransactions: [],
        )) {
    _subscribeToStreams();
  }

  /// Subscribes to service streams for reactive updates.
  ///
  /// When transactions or categories change, automatically refilters
  /// the current date to keep UI in sync.
  ///
  /// **Example Scenarios**:
  /// - User adds a new transaction → refilter current date
  /// - User changes a category name → update denormalized data
  void _subscribeToStreams() {
    _transactionSubscription = _transactionRepository.transactionsStream.listen((_) {
      _filterTransactionsByDate(state.selectedDate);
    });

    _categorySubscription = _categoryRepository.categoriesStream.listen((_) {
      _filterTransactionsByDate(state.selectedDate);
    });

    // Initial load for today's date
    _filterTransactionsByDate(state.selectedDate);
  }

  /// Changes the selected date and filters transactions.
  ///
  /// **Public API** - Called by UI when user selects a new date.
  ///
  /// **Parameters**:
  /// - `newDate`: The date to filter by (time component is ignored)
  ///
  /// **Example**:
  /// ```dart
  /// // User taps December 20th in date picker
  /// cubit.changeDate(DateTime(2025, 12, 20));
  /// ```
  void changeDate(DateTime newDate) {
    final normalizedDate = DateFormatter.normalizeToDay(newDate);
    _filterTransactionsByDate(normalizedDate);
  }

  /// Filters transactions by date and denormalizes with category data.
  ///
  /// **Algorithm**:
  /// 1. Normalize date to 00:00:00 for accurate comparison
  /// 2. Filter transactions where year/month/day match
  /// 3. For each transaction:
  ///    - Look up category by ID
  ///    - Create TransactionVModel with denormalized data
  ///    - Format date string
  /// 4. Emit new state
  ///
  /// **Pattern**: Same as TransactionListCubit._loadTransactions()
  ///
  /// **Parameters**:
  /// - `date`: The date to filter by (should be normalized)
  void _filterTransactionsByDate(DateTime date) {
    // Get all transactions
    final allTransactions = _transactionRepository.transactions;

    // Filter by date (year, month, day match)
    final transactionsOnDate = allTransactions.where((transaction) {
      final txDate = transaction.transactionDate;
      return txDate.year == date.year &&
          txDate.month == date.month &&
          txDate.day == date.day;
    }).toList();

    // Denormalize with category data (pattern from TransactionListCubit)
    final viewModels = transactionsOnDate.map((transaction) {
      // Look up category if transaction has one
      final category = transaction.categoryId != null
          ? _categoryRepository.getCategoryByIdSync(transaction.categoryId!)
          : null;

      // Create view model with denormalized data
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

    // Emit new state
    emit(DateFilterState(
      selectedDate: date,
      filteredTransactions: viewModels,
    ));
  }

  /// Cancels stream subscriptions when cubit is closed.
  ///
  /// **Critical**: Prevents memory leaks.
  @override
  Future<void> close() {
    _transactionSubscription?.cancel();
    _categorySubscription?.cancel();
    return super.close();
  }
}
