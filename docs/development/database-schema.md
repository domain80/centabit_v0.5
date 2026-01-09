# Database Schema

Drift database schema and design for Centabit.

## Overview

Centabit uses **Drift** (formerly Moor) as a type-safe SQLite ORM with reactive queries.

## Tables

### Transactions
```dart
class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  RealColumn get amount => real()();
  TextColumn get description => text().nullable()();
  TextColumn get categoryId => text()();
  TextColumn get budgetId => text().nullable()();
  DateTimeColumn get transactionDate => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
```

### Budgets
```dart
class Budgets extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  RealColumn get amount => real()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
```

### Categories
```dart
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  TextColumn get icon => text().nullable()();
  TextColumn get color => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
```

### Allocations
```dart
class Allocations extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get budgetId => text()();
  TextColumn get categoryId => text()();
  RealColumn get amount => real()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
```

## Key Design Patterns

### 1. userId Filtering

**Every table has userId** for multi-user support and security:
- Enables future OAuth integration
- Ensures data isolation between users
- All queries MUST filter by userId

### 2. Sync Metadata

Three columns track sync state:
- `isSynced`: Has this record been synced to server?
- `isDeleted`: Soft delete flag (mark as deleted, don't remove)
- `lastSyncedAt`: When was the last successful sync?

### 3. Soft Deletes

Records are marked as deleted, not removed:
- Allows sync of deletions to server
- Enables undo functionality
- Maintains referential integrity

### 4. Timestamps

Every table has:
- `createdAt`: When the record was created
- `updatedAt`: When the record was last modified

### 5. UUIDs

All IDs use UUIDs (`uuid` package):
- Prevents ID conflicts across devices
- Enables offline creation without server coordination
- Uses v4 (random) UUIDs

## Relationships

```
Budgets 1 ----* Allocations
  ^
  |
  *
Transactions

Categories 1 ----* Allocations
  ^
  |
  *
Transactions
```

## Indexes

Drift automatically creates indexes for:
- Primary keys
- Foreign key columns (when defined)

Additional indexes can be added for:
- Frequently queried columns
- Sort columns
- Filter columns

## Queries

### Example: userId-Filtered Query

```dart
Future<List<Transaction>> getTransactionsByBudget(String budgetId) {
  return (select(transactions)
        ..where((t) =>
            t.userId.equals(userId) &  // REQUIRED
            t.budgetId.equals(budgetId) &
            t.isDeleted.equals(false))
        ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
      .get();
}
```

### Example: Reactive Watch Query

```dart
Stream<List<Budget>> watchActiveBudgets() {
  final now = DateTime.now();
  return (select(budgets)
        ..where((b) =>
            b.userId.equals(userId) &
            b.isDeleted.equals(false) &
            b.endDate.isBiggerOrEqualValue(now))
        ..orderBy([(b) => OrderingTerm.desc(b.startDate)]))
      .watch();
}
```

## Code Generation

After modifying schema:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Next Steps

- [Adding Features](./adding-features.html)
- [Patterns & Conventions](./patterns-and-conventions.html)
- [Data Flow](/architecture/data-flow.html)
