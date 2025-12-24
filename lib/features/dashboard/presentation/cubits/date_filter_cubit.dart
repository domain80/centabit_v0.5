import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:centabit/data/services/category_service.dart';
import 'package:centabit/data/services/transaction_service.dart';
import 'package:centabit/features/dashboard/presentation/cubits/date_filter_state.dart';
import 'package:centabit/shared/v_models/transaction_v_model.dart';

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
  final TransactionService _transactionService;
  final CategoryService _categoryService;

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
    this._transactionService,
    this._categoryService,
  ) : super(DateFilterState(
          selectedDate: _normalizeDate(DateTime.now()),
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
    _transactionSubscription = _transactionService.transactionsStream.listen((_) {
      _filterTransactionsByDate(state.selectedDate);
    });

    _categorySubscription = _categoryService.categoriesStream.listen((_) {
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
    final normalizedDate = _normalizeDate(newDate);
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
    final allTransactions = _transactionService.transactions;

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
          ? _categoryService.getCategoryById(transaction.categoryId!)
          : null;

      // Create view model with denormalized data
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

    // Emit new state
    emit(DateFilterState(
      selectedDate: date,
      filteredTransactions: viewModels,
    ));
  }

  /// Formats date with smart relative strings.
  ///
  /// **Pattern**: Extracted from TransactionListCubit (could be shared utility)
  ///
  /// **Format Rules**:
  /// - Same day as today → "Today | hh:mm a"
  /// - Yesterday → "Yesterday | hh:mm a"
  /// - Other dates → "MMM d, yy | hh:mm a"
  ///
  /// **Examples**:
  /// - "Today | 02:30 PM"
  /// - "Yesterday | 09:15 AM"
  /// - "Dec 18, 25 | 11:45 AM"
  ///
  /// **Parameters**:
  /// - `date`: The transaction date/time to format
  ///
  /// **Returns**: Formatted date string
  ///
  /// **TODO**: Extract to shared utility class
  /// - Create `lib/core/utils/date_formatter.dart`
  /// - Use in both TransactionListCubit and DateFilterCubit
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

  /// Normalizes date to start of day (00:00:00).
  ///
  /// Ensures accurate date comparison by removing time component.
  ///
  /// **Example**:
  /// ```
  /// Input:  2025-12-20 14:30:45
  /// Output: 2025-12-20 00:00:00
  /// ```
  ///
  /// **Parameters**:
  /// - `date`: Date to normalize
  ///
  /// **Returns**: Date with time set to midnight
  static DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
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
