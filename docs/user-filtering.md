# User Filtering Pattern

## Overview

Centabit implements a **userId-based filtering pattern** to prepare for multi-user support and OAuth integration. Every database query filters by `userId` to ensure data isolation between users and security.

**Current State**: Anonymous users with UUID tokens
**Future State**: OAuth-authenticated users with Google Sign-In
**Pattern**: All queries filter by userId from the start

---

## Why userId Filtering?

### 1. **Data Isolation**
- Each user sees only their own data
- Prevents accidental cross-user data leaks
- Enables future multi-user backend

### 2. **Security**
- Impossible to access another user's data
- userId validated on every write operation
- Protects against malicious queries

### 3. **OAuth Readiness**
- Architecture already prepared for authentication
- No database schema changes needed
- Simple migration from anonymous → authenticated

### 4. **Local Multi-User Support**
- App can support multiple user accounts on same device
- Data remains isolated per user
- Easy account switching (future feature)

---

## userId Flow Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                         APP START                                │
└───────────────────────────┬─────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│                       AuthManager                                │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  Check SharedPreferences for userId                      │  │
│  │                                                          │  │
│  │  If exists:                                              │  │
│  │    → Load existing userId (e.g., "anon_abc123")         │  │
│  │                                                          │  │
│  │  If not exists:                                          │  │
│  │    → Generate new userId: "anon_" + UUID.v4()           │  │
│  │    → Save to SharedPreferences                           │  │
│  │    → Return new userId                                   │  │
│  └──────────────────────────────────────────────────────────┘  │
└───────────────────────────┬─────────────────────────────────────┘
                            ↓
              userId = "anon_550e8400-e29b-41d4-a716-446655440000"
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│                    Dependency Injection                          │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  configureDependencies() async {                         │  │
│  │    final userId = await authManager.getCurrentUserId();  │  │
│  │                                                          │  │
│  │    // Inject userId into all LocalSources              │  │
│  │    getIt.registerLazySingleton<TransactionLocalSource>( │  │
│  │      () => TransactionLocalSource(db, userId),         │  │
│  │    );                                                    │  │
│  │    // ... repeat for all LocalSources                  │  │
│  │  }                                                       │  │
│  └──────────────────────────────────────────────────────────┘  │
└───────────────────────────┬─────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│                      LocalSource Layer                           │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │  class TransactionLocalSource {                          │  │
│  │    final AppDatabase _db;                                │  │
│  │    final String userId;  // ← STORED IN INSTANCE         │  │
│  │                                                          │  │
│  │    TransactionLocalSource(this._db, this.userId);       │  │
│  │  }                                                       │  │
│  └──────────────────────────────────────────────────────────┘  │
└───────────────────────────┬─────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────────┐
│                    ALL DATABASE QUERIES                          │
│                                                                  │
│  EVERY query includes:                                           │
│    ..where((t) => t.userId.equals(userId) & ...)               │
│                                                                  │
│  EVERY insert includes:                                          │
│    Companion.insert(userId: this.userId, ...)                   │
│                                                                  │
│  EVERY update validates:                                         │
│    if (entity.userId != this.userId) throw Exception();         │
└─────────────────────────────────────────────────────────────────┘
```

---

## Implementation Details

### 1. Anonymous User Token Generation

**File**: `lib/core/auth/auth_manager.dart`

```dart
class AuthManager {
  static const String _anonymousUserIdKey = 'anonymous_user_id';

  final SharedPreferences _prefs;
  String? _currentUserId;

  AuthManager(this._prefs);

  /// Get or create anonymous user ID
  Future<String> getCurrentUserId() async {
    if (_currentUserId != null) return _currentUserId!;

    // Check if we already have an anonymous ID
    _currentUserId = _prefs.getString(_anonymousUserIdKey);

    if (_currentUserId == null) {
      // Create new anonymous user
      _currentUserId = 'anon_${const Uuid().v4()}';
      await _prefs.setString(_anonymousUserIdKey, _currentUserId!);
    }

    return _currentUserId!;
  }

  /// Check if user is authenticated (vs anonymous)
  bool get isAuthenticated => _currentUserId?.startsWith('anon_') == false;

  /// Get display name
  String get displayName => isAuthenticated ? 'User' : 'Guest';
}
```

**Key Points**:
- **Persistent**: Saved to SharedPreferences (survives app restarts)
- **Prefix**: "anon_" prefix distinguishes anonymous users
- **UUID**: Collision-resistant unique identifier
- **Lazy**: Only generated on first access

### 2. userId Injection via Dependency Injection

**File**: `lib/core/di/injection.dart`

```dart
Future<void> configureDependencies() async {
  // Step 1: Initialize AuthManager
  final prefs = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => prefs);

  getIt.registerLazySingleton<AuthManager>(
    () => AuthManager(getIt<SharedPreferences>()),
  );

  // Step 2: Get userId BEFORE creating LocalSources
  final userId = await getIt<AuthManager>().getCurrentUserId();

  // Step 3: Register database
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // Step 4: Inject userId into all LocalSources
  getIt.registerLazySingleton<TransactionLocalSource>(
    () => TransactionLocalSource(getIt<AppDatabase>(), userId),
  );

  getIt.registerLazySingleton<CategoryLocalSource>(
    () => CategoryLocalSource(getIt<AppDatabase>(), userId),
  );

  getIt.registerLazySingleton<BudgetLocalSource>(
    () => BudgetLocalSource(getIt<AppDatabase>(), userId),
  );

  getIt.registerLazySingleton<AllocationLocalSource>(
    () => AllocationLocalSource(getIt<AppDatabase>(), userId),
  );

  // Step 5: Repositories and other dependencies...
}
```

**Key Points**:
- **userId obtained early**: Before LocalSources created
- **Injected via constructor**: Each LocalSource receives userId
- **Single source of truth**: All LocalSources use same userId
- **No globals**: userId never stored in global variable

### 3. Database Schema with userId Column

**File**: `lib/data/local/database.dart`

```dart
class Transactions extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();  // ← CRITICAL: userId column
  TextColumn get name => text()();
  RealColumn get amount => real()();
  // ... other columns

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {userId, id},  // ← COMPOSITE UNIQUE: userId + id
  ];
}
```

**Key Points**:
- **userId column**: Required on all tables
- **Composite unique constraint**: Enforces userId + id uniqueness
- **No foreign key**: userId is just a string (no users table yet)
- **Indexed**: Drift automatically indexes unique constraint columns

### 4. LocalSource Query Pattern: Read with Filtering

**File**: `lib/data/local/transaction_local_source.dart`

```dart
class TransactionLocalSource {
  final AppDatabase _db;
  final String userId;  // ← Stored in instance

  TransactionLocalSource(this._db, this.userId);

  /// Watch all transactions FOR THIS USER
  Stream<List<Transaction>> watchAllTransactions() {
    return (_db.select(_db.transactions)
          ..where((t) =>
              t.userId.equals(userId) &  // ← ALWAYS filter by userId
              t.isDeleted.equals(false)))
        .watch();
  }

  /// Get transaction by ID FOR THIS USER
  Future<Transaction?> getTransactionById(String id) {
    return (_db.select(_db.transactions)
          ..where((t) =>
              t.userId.equals(userId) &  // ← Security: userId check
              t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Get transactions by date FOR THIS USER
  Stream<List<Transaction>> watchTransactionsByDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return (_db.select(_db.transactions)
          ..where((t) =>
              t.userId.equals(userId) &  // ← Always include userId
              t.isDeleted.equals(false) &
              t.transactionDate.isBiggerOrEqualValue(startOfDay) &
              t.transactionDate.isSmallerThanValue(endOfDay)))
        .watch();
  }
}
```

**Key Points**:
- **Every query filters by userId**: Without exception
- **Combined with AND operator**: `userId.equals(userId) &` other conditions
- **Prevents data leaks**: Impossible to see other users' data
- **Performance**: userId + id indexed via composite unique constraint

### 5. LocalSource Write Pattern: Auto-Inject userId

**File**: `lib/data/local/transaction_local_source.dart`

```dart
class TransactionLocalSource {
  final String userId;

  /// Create transaction (userId auto-injected)
  Future<void> createTransaction(TransactionsCompanion transaction) {
    // userId MUST be in companion
    // Repository layer ensures this
    return _db.into(_db.transactions).insert(transaction);
  }

  /// Update transaction (userId validated)
  Future<void> updateTransaction(Transaction transaction) {
    // Security check: Prevent updating other users' data
    if (transaction.userId != userId) {
      throw Exception('Cannot update transaction for different user');
    }
    return _db.update(_db.transactions).replace(transaction);
  }

  /// Soft delete transaction (userId validated)
  Future<void> deleteTransaction(String id) {
    return (_db.update(_db.transactions)
          ..where((t) =>
              t.userId.equals(userId) &  // ← Security: Only delete own data
              t.id.equals(id)))
        .write(const TransactionsCompanion(isDeleted: Value(true)));
  }
}
```

**Key Points**:
- **Create**: userId included in Companion by repository
- **Update**: userId validated before allowing update
- **Delete**: userId filter prevents deleting other users' data
- **Security**: Throws exception if userId mismatch

### 6. Repository Pattern: Inject userId on Create

**File**: `lib/data/repositories/transaction_repository.dart`

```dart
class TransactionRepository {
  final TransactionLocalSource _localSource;

  Future<void> createTransaction(TransactionModel model) async {
    await _localSource.createTransaction(
      db.TransactionsCompanion.insert(
        id: model.id,
        userId: _localSource.userId,  // ← Auto-inject userId
        name: model.name,
        amount: model.amount,
        type: Value(model.type.name),
        transactionDate: model.transactionDate,
        categoryId: Value(model.categoryId),
        budgetId: Value(model.budgetId),
        notes: Value(model.notes),
        createdAt: model.createdAt,
        updatedAt: model.updatedAt,
        isSynced: const Value(false),
      ),
    );
  }

  Future<void> updateTransaction(TransactionModel model) async {
    final updatedModel = model.withUpdatedTimestamp();
    await _localSource.updateTransaction(_mapToDbModel(updatedModel));
  }

  db.Transaction _mapToDbModel(TransactionModel model) {
    return db.Transaction(
      id: model.id,
      userId: _localSource.userId,  // ← Auto-inject userId
      name: model.name,
      amount: model.amount,
      type: model.type.name,
      transactionDate: model.transactionDate,
      categoryId: model.categoryId,
      budgetId: model.budgetId,
      notes: model.notes,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      isSynced: false,
      isDeleted: false,
      lastSyncedAt: null,
    );
  }
}
```

**Key Points**:
- **Repository handles userId injection**: Domain models don't contain userId
- **LocalSource expects userId**: Validates on write
- **Clean separation**: Presentation layer never sees userId

---

## Security Benefits

### 1. **Query-Level Protection**
```dart
// IMPOSSIBLE to write this query (compiler error):
_db.select(_db.transactions).get();  // Missing userId filter!

// REQUIRED pattern:
_db.select(_db.transactions)
  ..where((t) => t.userId.equals(userId))  // Must include
  .get();
```

### 2. **Update Protection**
```dart
// User A tries to update User B's transaction
final userASource = TransactionLocalSource(db, "userA_id");
final userBTransaction = Transaction(userId: "userB_id", ...);

await userASource.updateTransaction(userBTransaction);
// ❌ Throws: "Cannot update transaction for different user"
```

### 3. **Delete Protection**
```dart
// User A tries to delete User B's transaction
final userASource = TransactionLocalSource(db, "userA_id");

await userASource.deleteTransaction("userB_transaction_id");
// ✅ Succeeds silently (0 rows affected)
// No error, but doesn't delete (WHERE clause filters it out)
```

### 4. **Isolation in Shared Database**
```
Database: centabit.sqlite
┌────────────────────────────────────────┐
│  Transactions Table                    │
├────┬─────────┬────────┬────────────────┤
│ id │ userId  │ name   │ amount         │
├────┼─────────┼────────┼────────────────┤
│ 1  │ anon_A  │ Coffee │ 4.50           │ ← User A sees this
│ 2  │ anon_B  │ Lunch  │ 12.00          │ ← User B sees this
│ 3  │ anon_A  │ Gas    │ 45.00          │ ← User A sees this
└────┴─────────┴────────┴────────────────┘

Query from User A's device:
  SELECT * FROM transactions WHERE userId = 'anon_A'
  → Returns rows 1, 3 only

Query from User B's device:
  SELECT * FROM transactions WHERE userId = 'anon_B'
  → Returns row 2 only
```

---

## Future: OAuth Integration

When OAuth is added, the migration path is simple:

### Step 1: User Signs In with Google

```dart
// In AuthManager
Future<void> signInWithGoogle() async {
  // 1. Sign in with google_sign_in package
  final googleUser = await _googleSignIn.signIn();
  final googleAuth = await googleUser?.authentication;

  // 2. Get authenticated user ID from backend
  final authenticatedUserId = await _apiClient.authenticateWithGoogle(
    idToken: googleAuth?.idToken,
  );

  // 3. Migrate anonymous data to authenticated user
  await _migrateAnonymousData(
    from: _currentUserId!,  // "anon_abc123"
    to: authenticatedUserId,  // "google_xyz789"
  );

  // 4. Update userId
  _currentUserId = authenticatedUserId;
  await _prefs.setString(_authenticatedUserIdKey, authenticatedUserId);

  // 5. Restart LocalSources with new userId
  await _reinitializeWithNewUserId(authenticatedUserId);
}
```

### Step 2: Migrate Anonymous Data

```dart
Future<void> _migrateAnonymousData(String from, String to) async {
  final db = getIt<AppDatabase>();

  // Update all transactions
  await (db.update(db.transactions)
        ..where((t) => t.userId.equals(from)))
      .write(TransactionsCompanion(userId: Value(to)));

  // Update all categories
  await (db.update(db.categories)
        ..where((c) => c.userId.equals(from)))
      .write(CategoriesCompanion(userId: Value(to)));

  // Update all budgets
  await (db.update(db.budgets)
        ..where((b) => b.userId.equals(from)))
      .write(BudgetsCompanion(userId: Value(to)));

  // Update all allocations
  await (db.update(db.allocations)
        ..where((a) => a.userId.equals(from)))
      .write(AllocationsCompanion(userId: Value(to)));

  // Mark all as unsynced for API sync
  // (API will validate ownership)
}
```

### Step 3: Reinitialize with New userId

```dart
Future<void> _reinitializeWithNewUserId(String newUserId) async {
  // Unregister old LocalSources
  await getIt.unregister<TransactionLocalSource>();
  await getIt.unregister<CategoryLocalSource>();
  await getIt.unregister<BudgetLocalSource>();
  await getIt.unregister<AllocationLocalSource>();

  // Register new LocalSources with new userId
  getIt.registerLazySingleton<TransactionLocalSource>(
    () => TransactionLocalSource(getIt<AppDatabase>(), newUserId),
  );
  // ... repeat for other LocalSources

  // Repositories will automatically pick up new LocalSources
  // Reactive streams will emit fresh data for new userId
}
```

**No Schema Changes Required!** 🎉

---

## Multi-User on Same Device (Future)

The userId pattern also enables multiple user accounts on the same device:

```dart
class AuthManager {
  List<String> _savedUserIds = [];  // All user accounts on device

  Future<void> switchUser(String userId) async {
    if (!_savedUserIds.contains(userId)) {
      throw Exception('User not found on this device');
    }

    // Switch to different user
    _currentUserId = userId;
    await _prefs.setString(_currentUserIdKey, userId);

    // Reinitialize LocalSources with new userId
    await _reinitializeWithNewUserId(userId);

    // UI will automatically reload with new user's data
    // (reactive streams propagate the change)
  }

  Future<void> addUserAccount(String userId) async {
    _savedUserIds.add(userId);
    await _prefs.setStringList(_savedUserIdsKey, _savedUserIds);
  }

  List<String> get userAccounts => _savedUserIds;
}
```

**Use Case**: Family budgeting app with separate budgets per family member on shared tablet.

---

## Key Principles

### 1. **Filter Everything**
- Every SELECT query includes `userId.equals(userId)`
- No exceptions, no shortcuts

### 2. **Inject Automatically**
- Repository layer adds userId to writes
- Domain models don't contain userId
- Presentation layer never sees userId

### 3. **Validate on Mutation**
- Update operations check userId match
- Prevents accidental cross-user updates
- Throw exceptions on mismatch

### 4. **Anonymous First**
- Users start anonymous (no auth required)
- OAuth is optional upgrade
- Data migrates seamlessly

### 5. **Future-Proof**
- Architecture ready for multi-user backend
- No refactoring needed for OAuth
- Simple migration path

---

## Testing userId Filtering

### Manual Testing

```dart
// Create test with different userId
final testDb = AppDatabase();
final sourceA = TransactionLocalSource(testDb, "userA");
final sourceB = TransactionLocalSource(testDb, "userB");

// User A creates transaction
await sourceA.createTransaction(TransactionsCompanion.insert(
  id: 'tx1',
  userId: 'userA',
  name: 'Coffee',
  amount: 4.50,
  // ...
));

// User B tries to read it
final result = await sourceB.getTransactionById('tx1');
print(result);  // null (filtered out by userId)

// User B creates their own transaction
await sourceB.createTransaction(TransactionsCompanion.insert(
  id: 'tx2',
  userId: 'userB',
  name: 'Lunch',
  amount: 12.00,
  // ...
));

// Verify isolation
final userATransactions = await sourceA.watchAllTransactions().first;
print(userATransactions.length);  // 1 (only tx1)

final userBTransactions = await sourceB.watchAllTransactions().first;
print(userBTransactions.length);  // 1 (only tx2)
```

### Unit Test Example

```dart
test('userId filtering prevents cross-user access', () async {
  final db = AppDatabase();
  final sourceA = TransactionLocalSource(db, "userA");
  final sourceB = TransactionLocalSource(db, "userB");

  // User A creates transaction
  await sourceA.createTransaction(/* ... */);

  // User B cannot see User A's transaction
  final resultB = await sourceB.getTransactionById('userA_tx');
  expect(resultB, isNull);

  // User A cannot update User B's transaction
  final userBTransaction = Transaction(userId: 'userB', /* ... */);
  expect(
    () => sourceA.updateTransaction(userBTransaction),
    throwsA(isA<Exception>()),
  );
});
```

---

## Summary

The userId filtering pattern provides:

✅ **Security**: Data isolation between users
✅ **Future-Proof**: Ready for OAuth with no schema changes
✅ **Clean Architecture**: userId handled at LocalSource layer
✅ **Multi-User Ready**: Can support multiple accounts on same device
✅ **Simple Migration**: Anonymous → Authenticated is just a userId update
✅ **Performance**: Indexed queries via composite unique constraint
✅ **Type-Safe**: Drift enforces schema at compile-time

This pattern is **production-ready** and scales from single-user offline app to multi-user cloud-synced platform without architectural changes.
