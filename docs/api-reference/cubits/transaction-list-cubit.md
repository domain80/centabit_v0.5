# TransactionListCubit

Manages transaction list state with search, filtering, pagination, and denormalization.

## Overview

`TransactionListCubit` orchestrates transaction data from repositories, denormalizes with category data, and provides search, filtering, and pagination functionality.

**Location:** `lib/features/transactions/presentation/cubits/transaction_list_cubit.dart`

## Class Definition

```dart
class TransactionListCubit extends Cubit<TransactionListState> {
  final TransactionRepository _transactionRepository;
  final CategoryRepository _categoryRepository;
  final _logger = AppLogger.instance;

  StreamSubscription? _transactionSubscription;
  StreamSubscription? _categorySubscription;

  int _currentPage = 0;
  static const int _pageSize = 20;

  TransactionListCubit(
    this._transactionRepository,
    this._categoryRepository,
  ) : super(const TransactionListState.initial()) {
    _subscribeToStreams();
  }
}
```

## State

### TransactionListState

```dart
@freezed
abstract class TransactionListState with _$TransactionListState {
  const factory TransactionListState.initial() = _Initial;
  const factory TransactionListState.loading() = _Loading;
  const factory TransactionListState.success({
    required List<TransactionVModel> transactions,
    required int currentPage,
    required bool hasMore,
    @Default('') String searchQuery,
    DateTime? selectedDate,
  }) = _Success;
  const factory TransactionListState.error(String message) = _Error;
}
```

**State Fields:**
- `transactions` - Denormalized transaction view models
- `currentPage` - Current pagination page (0-indexed)
- `hasMore` - Whether more pages exist
- `searchQuery` - Active search filter
- `selectedDate` - Selected date for scroll-to functionality

### TransactionVModel

Denormalized view model with category data:

```dart
class TransactionVModel {
  final String id;
  final String name;
  final double amount;
  final TransactionType type;
  final DateTime transactionDate;
  final String formattedDate;     // "Dec 15, 2025"
  final String formattedTime;     // "2:30 PM"
  final String? categoryId;
  final String? categoryName;     // Denormalized from CategoryRepository
  final String? categoryIconName; // Denormalized from CategoryRepository
  final String? notes;
}
```

**Benefits:**
- All data in one object
- No async lookups in UI
- Pre-formatted dates
- Category names/icons ready for display

## Methods

### Constructor

Initializes cubit and subscribes to repository streams.

**Signature:**
```dart
TransactionListCubit(
  TransactionRepository transactionRepository,
  CategoryRepository categoryRepository,
)
```

**Side effects:**
- Subscribes to transaction and category streams
- Triggers initial data load

**Example:**
```dart
BlocProvider(
  create: (_) => getIt<TransactionListCubit>(),
  child: TransactionsPage(),
)
```

### `refresh()`

Resets to page 0 and reloads transactions.

**Signature:**
```dart
Future<void> refresh()
```

**Returns:** Future that completes immediately (for RefreshIndicator).

**Example:**
```dart
RefreshIndicator(
  onRefresh: () async {
    context.read<TransactionListCubit>().refresh();
  },
  child: TransactionList(),
)
```

### `loadNextPage()`

Loads next page of transactions.

**Signature:**
```dart
void loadNextPage()
```

**Side effects:**
- Increments `_currentPage`
- Reloads transactions with new page

**Example:**
```dart
// In scroll listener
if (scrollController.position.pixels ==
    scrollController.position.maxScrollExtent) {
  context.read<TransactionListCubit>().loadNextPage();
}
```

### `searchTransactions(String query)`

Filters transactions by name or category name.

**Signature:**
```dart
void searchTransactions(String query)
```

**Parameters:**
- `query` - Search text (case-insensitive)

**Side effects:**
- Resets to page 0
- Updates state with search query
- Reloads filtered transactions

**Matching:**
- Transaction name (partial match)
- Category name (partial match)

**Example:**
```dart
// In search bar
TextField(
  onChanged: (query) {
    context.read<TransactionListCubit>().searchTransactions(query);
  },
)
```

### `setSelectedDate(DateTime? date)`

Sets selected date for scroll-to-date functionality.

**Signature:**
```dart
void setSelectedDate(DateTime? date)
```

**Parameters:**
- `date` - Date to scroll to (or `null` to clear)

**Side effects:**
- Updates state with selected date
- Does NOT reload transactions (scroll happens in UI)

**Example:**
```dart
// In date picker
context.read<TransactionListCubit>().setSelectedDate(
  DateTime(2025, 12, 15),
);
```

### `clearFilters()`

Clears all filters and reloads.

**Signature:**
```dart
void clearFilters()
```

**Side effects:**
- Resets to page 0
- Clears search query
- Clears selected date
- Reloads all transactions

**Example:**
```dart
IconButton(
  icon: Icon(Icons.clear),
  onPressed: () {
    context.read<TransactionListCubit>().clearFilters();
  },
)
```

### `deleteTransaction(String id)`

Deletes a transaction.

**Signature:**
```dart
Future<void> deleteTransaction(String id)
```

**Parameters:**
- `id` - Transaction ID to delete

**Side effects:**
- Calls repository to delete
- Stream automatically triggers reload

**Example:**
```dart
// In dismissible widget
onDismissed: (_) async {
  await context.read<TransactionListCubit>()
    .deleteTransaction(transaction.id);
}
```

## Private Methods

### `_subscribeToStreams()`

Subscribes to transaction and category repository streams.

**Implementation:**
```dart
void _subscribeToStreams() {
  _transactionSubscription = _transactionRepository
    .transactionsStream
    .listen((_) => _loadTransactions());

  _categorySubscription = _categoryRepository
    .categoriesStream
    .listen((_) => _loadTransactions()); // Reload on category changes

  _loadTransactions(); // Initial load
}
```

**Why subscribe to categories?**
If a category name/icon changes, transaction view models need to reload with updated data.

### `_loadTransactions()`

Main data loading and transformation method.

**Process:**
1. Preserve current filters (searchQuery, selectedDate)
2. Emit loading state
3. Get all transactions from repository
4. Apply search filter if active
5. Apply pagination
6. Denormalize with category data
7. Build `TransactionVModel` list
8. Emit success state

**Denormalization:**
```dart
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
    categoryName: category?.name,         // Joined
    categoryIconName: category?.iconName, // Joined
    notes: transaction.notes,
  );
}).toList();
```

## Usage Examples

### Basic Setup

```dart
class TransactionsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TransactionListCubit>(),
      child: TransactionsView(),
    );
  }
}
```

### Display Transaction List

```dart
class TransactionsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionListCubit, TransactionListState>(
      builder: (context, state) {
        return state.when(
          initial: () => const SizedBox.shrink(),
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          success: (transactions, page, hasMore, query, date) {
            if (transactions.isEmpty) {
              return Center(
                child: Text(
                  query.isNotEmpty
                    ? 'No transactions found for "$query"'
                    : 'No transactions yet',
                ),
              );
            }

            return ListView.builder(
              itemCount: transactions.length + (hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == transactions.length) {
                  // Load more indicator
                  context.read<TransactionListCubit>().loadNextPage();
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final tx = transactions[index];
                return TransactionTile(transaction: tx);
              },
            );
          },
          error: (message) => ErrorView(message: message),
        );
      },
    );
  }
}
```

### Search Bar Integration

```dart
class TransactionSearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionListCubit, TransactionListState>(
      builder: (context, state) {
        final searchQuery = state.maybeWhen(
          success: (_, __, ___, query, ____) => query,
          orElse: () => '',
        );

        return TextField(
          decoration: InputDecoration(
            hintText: 'Search transactions or categories...',
            prefixIcon: Icon(Icons.search),
            suffixIcon: searchQuery.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear),
                  onPressed: () {
                    context.read<TransactionListCubit>().clearFilters();
                  },
                )
              : null,
          ),
          onChanged: (query) {
            context.read<TransactionListCubit>().searchTransactions(query);
          },
        );
      },
    );
  }
}
```

### Transaction Tile with Category

```dart
class TransactionTile extends StatelessWidget {
  final TransactionVModel transaction;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(transaction.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 16),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) async {
        await context.read<TransactionListCubit>()
          .deleteTransaction(transaction.id);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${transaction.name} deleted')),
        );
      },
      child: ListTile(
        leading: CircleAvatar(
          child: Icon(_getCategoryIcon(transaction.categoryIconName)),
        ),
        title: Text(transaction.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(transaction.categoryName ?? 'Uncategorized'),
            Text(
              transaction.formattedDate,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: Text(
          '\$${transaction.amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: transaction.type == TransactionType.debit
              ? Colors.red
              : Colors.green,
          ),
        ),
        onTap: () {
          // Navigate to transaction detail/edit
        },
      ),
    );
  }
}
```

### Date Picker Integration

```dart
class TransactionDatePicker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.calendar_today),
      onPressed: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );

        if (date != null) {
          context.read<TransactionListCubit>().setSelectedDate(date);
        }
      },
    );
  }
}
```

### Pagination Implementation

```dart
class TransactionList extends StatefulWidget {
  @override
  _TransactionListState createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      final cubit = context.read<TransactionListCubit>();
      final state = cubit.state;

      state.maybeWhen(
        success: (_, __, hasMore, ___, ____) {
          if (hasMore) {
            cubit.loadNextPage();
          }
        },
        orElse: () {},
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionListCubit, TransactionListState>(
      builder: (context, state) {
        return state.when(
          initial: () => const SizedBox(),
          loading: () => const LoadingIndicator(),
          success: (transactions, page, hasMore, query, date) {
            return ListView.builder(
              controller: _scrollController,
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                return TransactionTile(
                  transaction: transactions[index],
                );
              },
            );
          },
          error: (msg) => ErrorView(message: msg),
        );
      },
    );
  }
}
```

## Data Flow

### Complete Cycle (Create → Display)

```
1. User creates transaction in form
   ↓
2. FormCubit calls transactionRepository.createTransaction()
   ↓
3. Repository writes to database
   ↓
4. Drift watch() stream emits change
   ↓
5. TransactionRepository emits to transactionsStream
   ↓
6. TransactionListCubit's _transactionSubscription fires
   ↓
7. _loadTransactions() called
   ↓
8. Get all transactions from repository
   ↓
9. Apply search filter (if active)
   ↓
10. Apply pagination (page 0, items 0-19)
   ↓
11. Denormalize each transaction with category data
    categoryRepository.getCategoryByIdSync(categoryId)
   ↓
12. Build TransactionVModel list
   ↓
13. Emit TransactionListState.success(...)
   ↓
14. BlocBuilder rebuilds ListView
   ↓
15. User sees new transaction in list with category name/icon
```

### Search Flow

```
1. User types "coffee" in search bar
   ↓
2. TextField.onChanged calls searchTransactions("coffee")
   ↓
3. _currentPage reset to 0
   ↓
4. State updated with searchQuery: "coffee"
   ↓
5. _loadTransactions() called
   ↓
6. Filter transactions:
   - name.contains("coffee") OR
   - category.name.contains("coffee")
   ↓
7. Apply pagination to filtered results
   ↓
8. Emit success state with filtered transactions
   ↓
9. ListView shows only matching transactions
```

## Performance

### Pagination

- **Page size:** 20 transactions per page
- **Load trigger:** Scroll to bottom of list
- **Initial load:** Page 0 (items 0-19)
- **Next loads:** Pages 1, 2, 3... (items 20-39, 40-59, etc.)

**Benefits:**
- Reduces initial render time
- Improves scroll performance
- Works well with long transaction histories

### Denormalization

All transactions are denormalized with category data in cubit:

```dart
// ✅ Good - denormalize once in cubit
final viewModel = TransactionVModel(
  categoryName: category?.name,
  categoryIconName: category?.iconName,
);

// Widget just displays
ListTile(
  leading: Icon(_getIcon(transaction.categoryIconName)),
  title: Text(transaction.categoryName ?? 'Uncategorized'),
)
```

**Alternative (bad):**
```dart
// ❌ Bad - lookup in widget
ListTile(
  leading: FutureBuilder(
    future: categoryRepo.getCategoryById(tx.categoryId),
    builder: (context, snapshot) { ... },
  ),
)
```

## Best Practices

### Subscribe to Both Repositories

```dart
// ✅ Good - subscribes to transactions AND categories
_transactionSubscription = _transactionRepository
  .transactionsStream.listen((_) => _loadTransactions());

_categorySubscription = _categoryRepository
  .categoriesStream.listen((_) => _loadTransactions());

// ❌ Bad - only subscribes to transactions
// UI won't update when category names change
```

### Preserve Filters on Reload

```dart
// ✅ Good - extracts filters before emitting loading
void _loadTransactions() {
  String searchQuery = '';
  DateTime? selectedDate;

  state.maybeWhen(
    success: (_, _, _, query, date) {
      searchQuery = query;
      selectedDate = date;
    },
    orElse: () {},
  );

  emit(const TransactionListState.loading());
  // ... load with preserved filters
}

// ❌ Bad - loses filters on reload
void _loadTransactions() {
  emit(const TransactionListState.loading());
  // searchQuery is lost!
}
```

### Handle Empty Results

```dart
// ✅ Good - distinguishes empty states
if (transactions.isEmpty) {
  if (searchQuery.isNotEmpty) {
    return Text('No results for "$searchQuery"');
  } else {
    return Text('No transactions yet');
  }
}

// ❌ Bad - generic message
if (transactions.isEmpty) {
  return Text('No transactions');
}
```

### Reset Page on Filter Change

```dart
// ✅ Good - resets pagination
void searchTransactions(String query) {
  _currentPage = 0; // Reset to page 0
  _loadTransactions();
}

// ❌ Bad - stays on current page
void searchTransactions(String query) {
  _loadTransactions(); // May show wrong items!
}
```

## See Also

- [TransactionListState](./transaction-list-cubit.md#transactionliststate) - State definition
- [TransactionRepository](../repositories/transaction-repository.md) - Transaction data
- [CategoryRepository](../repositories/category-repository.md) - Category lookups
- [TransactionModel](../models/transaction-model.md) - Domain model
