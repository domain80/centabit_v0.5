# Models Overview

Domain models represent the core business entities in Centabit v0.5. All models use the Freezed package for immutability, equality, and JSON serialization.

## Architecture

Models live in the **domain layer** and are separate from database entities:

```
Database (Drift entities) → Repositories → Domain Models → Cubits → UI
```

**Key Principles:**
- **Immutable**: All models use `@freezed` for immutability
- **Type-safe**: Full type checking at compile time
- **JSON-ready**: Auto-generated serialization with `@JsonSerializable`
- **UUID-based**: All entities use UUID v4 for primary keys
- **Timestamped**: All entities track `createdAt` and `updatedAt`

## Core Models

### [TransactionModel](./transaction-model.md)
Represents a financial transaction (debit or credit).

**Key Fields:**
- `id`, `name`, `amount`, `transactionDate`
- `type` (enum: `credit` | `debit`)
- `categoryId` (nullable - links to category)
- `budgetId` (nullable - links to budget or unassigned)
- `notes` (optional description)

**Factory Constructors:**
- `TransactionModel.create()` - Auto-generates ID and timestamps
- `TransactionModel.fromJson()` - Deserializes from JSON

### [BudgetModel](./budget-model.md)
Represents a budget period with spending limit and date range.

**Key Fields:**
- `id`, `name`, `amount`
- `startDate`, `endDate` (defines budget period)
- Used for BAR (Budget Adherence Ratio) calculations

**Extension Methods:**
- `isActive()` - Checks if budget is currently active
- `totalDays()` - Calculates period length
- `elapsedDays()` - Calculates days elapsed
- `withUpdatedTimestamp()` - Creates copy with updated timestamp

### [CategoryModel](./category-model.md)
Represents a spending category (e.g., Groceries, Dining, Transport).

**Key Fields:**
- `id`, `name`
- `iconName` (links to app icon assets)

**Usage:**
- Linked from transactions via `categoryId`
- Linked from allocations via `categoryId`
- Denormalized in view models for UI display

### [AllocationModel](./allocation-model.md)
Represents budget allocation to a specific category.

**Key Fields:**
- `id`, `amount`
- `categoryId` (which category)
- `budgetId` (which budget)

**Relationships:**
```
Budget (1) ──< (N) Allocations ──> (1) Category
```

**Extension Methods:**
- `withUpdatedTimestamp()` - Creates copy with updated timestamp
- `isValidAmount()` - Validates amount is positive

**List Extensions:**
- `totalAmount()` - Sum of all allocation amounts
- `groupByCategory()` - Groups by category ID
- `groupByBudget()` - Groups by budget ID
- `forBudget()` - Filters by budget ID
- `forCategory()` - Filters by category ID

## Model Naming Convention

All domain models follow these conventions:

**File naming:**
```
lib/data/models/[entity]_model.dart
```

**Class naming:**
```dart
@freezed
abstract class [Entity]Model with _$[Entity]Model {
  const factory [Entity]Model({ ... }) = _[Entity]Model;
}
```

**Examples:**
- `TransactionModel` in `transaction_model.dart`
- `BudgetModel` in `budget_model.dart`
- `CategoryModel` in `category_model.dart`
- `AllocationModel` in `allocation_model.dart`

## Code Generation

Models use Freezed code generation. After modifying a model:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Generated Files** (do not edit manually):
- `[model].freezed.dart` - Freezed implementations
- `[model].g.dart` - JSON serialization

## Common Patterns

### Factory Constructor Pattern

All models provide a `.create()` factory for new instances:

```dart
// Auto-generates ID and timestamps
final transaction = TransactionModel.create(
  name: 'Grocery Shopping',
  amount: 45.50,
  type: TransactionType.debit,
  categoryId: groceryCategoryId,
);
```

### CopyWith Pattern

Freezed provides immutable updates via `copyWith()`:

```dart
// Update amount without mutating original
final updated = transaction.copyWith(amount: 50.00);
```

### JSON Serialization

All models support JSON serialization:

```dart
// Serialize
final json = transaction.toJson();

// Deserialize
final restored = TransactionModel.fromJson(json);
```

## Domain vs Database Models

**Domain Models** (this section):
- Used in business logic and UI
- Clean, simple data classes
- No sync metadata or user IDs

**Database Entities** (Drift):
- Used in local storage layer
- Include sync fields: `isSynced`, `isDeleted`, `lastSyncedAt`
- Include `userId` for multi-user support

**Transformation:**
Repositories handle conversion between domain and database models:

```dart
// In TransactionRepository
TransactionModel _mapToModel(db.Transaction dbTransaction) {
  return TransactionModel(
    id: dbTransaction.id,
    name: dbTransaction.name,
    amount: dbTransaction.amount,
    // ... (excludes userId, isSynced, etc.)
  );
}
```

## Next Steps

- [TransactionModel →](./transaction-model.md) - Transaction details
- [BudgetModel →](./budget-model.md) - Budget details
- [CategoryModel →](./category-model.md) - Category details
- [AllocationModel →](./allocation-model.md) - Allocation details

See also:
- [Repositories →](../repositories/index.md) - Data access layer
- [Cubits →](../cubits/index.md) - State management
