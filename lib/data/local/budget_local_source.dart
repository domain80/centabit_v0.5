import 'package:drift/drift.dart';
import 'package:centabit/data/local/database.dart';

/// Local data source for budgets with userId filtering
///
/// All queries are automatically filtered by userId for security and multi-user support.
class BudgetLocalSource {
  final AppDatabase _db;
  final String userId; // CRITICAL: Injected userId for filtering

  BudgetLocalSource(this._db, this.userId);

  /// Reactive stream of all non-deleted budgets FOR THIS USER
  Stream<List<Budget>> watchAllBudgets() {
    return (_db.select(_db.budgets)
          ..where((b) =>
              b.userId.equals(userId) & // CRITICAL: Filter by userId
              b.isDeleted.equals(false))
          ..orderBy([(b) => OrderingTerm.desc(b.startDate)]))
        .watch();
  }

  /// Reactive stream of active budgets FOR THIS USER
  Stream<List<Budget>> watchActiveBudgets() {
    final now = DateTime.now();
    return (_db.select(_db.budgets)
          ..where((b) =>
              b.userId.equals(userId) & // CRITICAL: Filter by userId
              b.isDeleted.equals(false) &
              b.startDate.isSmallerOrEqualValue(now) &
              b.endDate.isBiggerOrEqualValue(now)))
        .watch();
  }

  /// Get single budget FOR THIS USER
  Future<Budget?> getBudgetById(String id) {
    return (_db.select(_db.budgets)
          ..where((b) =>
              b.userId.equals(userId) & // CRITICAL: Filter by userId
              b.id.equals(id)))
        .getSingleOrNull();
  }

  /// Get all budgets (non-reactive) FOR THIS USER
  Future<List<Budget>> getAllBudgets() {
    return (_db.select(_db.budgets)
          ..where((b) =>
              b.userId.equals(userId) & // CRITICAL: Filter by userId
              b.isDeleted.equals(false))
          ..orderBy([(b) => OrderingTerm.desc(b.startDate)]))
        .get();
  }

  /// Get active budgets (non-reactive) FOR THIS USER
  Future<List<Budget>> getActiveBudgets() {
    final now = DateTime.now();
    return (_db.select(_db.budgets)
          ..where((b) =>
              b.userId.equals(userId) & // CRITICAL: Filter by userId
              b.isDeleted.equals(false) &
              b.startDate.isSmallerOrEqualValue(now) &
              b.endDate.isBiggerOrEqualValue(now)))
        .get();
  }

  /// Create budget (userId automatically added)
  Future<void> createBudget(BudgetsCompanion budget) {
    // Ensure userId is set
    final withUser = budget.copyWith(userId: Value(userId));
    return _db.into(_db.budgets).insert(withUser);
  }

  /// Update budget (userId check for security)
  Future<void> updateBudget(Budget budget) {
    if (budget.userId != userId) {
      throw Exception('Cannot update budget for different user');
    }
    return _db.update(_db.budgets).replace(budget);
  }

  /// Soft delete FOR THIS USER
  Future<void> deleteBudget(String id) {
    return (_db.update(_db.budgets)
          ..where((b) =>
              b.userId.equals(userId) & // CRITICAL: Filter by userId
              b.id.equals(id)))
        .write(const BudgetsCompanion(isDeleted: Value(true)));
  }

  /// Get unsynced budgets FOR THIS USER
  Future<List<Budget>> getUnsyncedBudgets() {
    return (_db.select(_db.budgets)
          ..where((b) =>
              b.userId.equals(userId) & // CRITICAL: Filter by userId
              b.isSynced.equals(false)))
        .get();
  }

  /// Mark as synced FOR THIS USER
  Future<void> markAsSynced(String id) {
    return (_db.update(_db.budgets)
          ..where((b) =>
              b.userId.equals(userId) & // CRITICAL: Filter by userId
              b.id.equals(id)))
        .write(BudgetsCompanion(
          isSynced: const Value(true),
          lastSyncedAt: Value(DateTime.now()),
        ));
  }
}
