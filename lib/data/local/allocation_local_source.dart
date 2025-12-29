import 'package:drift/drift.dart';
import 'package:centabit/data/local/database.dart';

/// Local data source for allocations with userId filtering
///
/// All queries are automatically filtered by userId for security and multi-user support.
class AllocationLocalSource {
  final AppDatabase _db;
  final String userId; // CRITICAL: Injected userId for filtering

  AllocationLocalSource(this._db, this.userId);

  /// Reactive stream of all non-deleted allocations FOR THIS USER
  Stream<List<Allocation>> watchAllAllocations() {
    return (_db.select(_db.allocations)
          ..where((a) =>
              a.userId.equals(userId) & // CRITICAL: Filter by userId
              a.isDeleted.equals(false)))
        .watch();
  }

  /// Reactive stream of allocations for a specific budget FOR THIS USER
  Stream<List<Allocation>> watchAllocationsByBudget(String budgetId) {
    return (_db.select(_db.allocations)
          ..where((a) =>
              a.userId.equals(userId) & // CRITICAL: Filter by userId
              a.isDeleted.equals(false) &
              a.budgetId.equals(budgetId)))
        .watch();
  }

  /// Get single allocation FOR THIS USER
  Future<Allocation?> getAllocationById(String id) {
    return (_db.select(_db.allocations)
          ..where((a) =>
              a.userId.equals(userId) & // CRITICAL: Filter by userId
              a.id.equals(id)))
        .getSingleOrNull();
  }

  /// Get all allocations (non-reactive) FOR THIS USER
  Future<List<Allocation>> getAllAllocations() {
    return (_db.select(_db.allocations)
          ..where((a) =>
              a.userId.equals(userId) & // CRITICAL: Filter by userId
              a.isDeleted.equals(false)))
        .get();
  }

  /// Get allocations for a specific budget (non-reactive) FOR THIS USER
  Future<List<Allocation>> getAllocationsByBudget(String budgetId) {
    return (_db.select(_db.allocations)
          ..where((a) =>
              a.userId.equals(userId) & // CRITICAL: Filter by userId
              a.isDeleted.equals(false) &
              a.budgetId.equals(budgetId)))
        .get();
  }

  /// Get allocations for a specific category (non-reactive) FOR THIS USER
  Future<List<Allocation>> getAllocationsByCategory(String categoryId) {
    return (_db.select(_db.allocations)
          ..where((a) =>
              a.userId.equals(userId) & // CRITICAL: Filter by userId
              a.isDeleted.equals(false) &
              a.categoryId.equals(categoryId)))
        .get();
  }

  /// Create allocation (userId automatically added)
  Future<void> createAllocation(AllocationsCompanion allocation) {
    // Ensure userId is set
    final withUser = allocation.copyWith(userId: Value(userId));
    return _db.into(_db.allocations).insert(withUser);
  }

  /// Update allocation (userId check for security)
  Future<void> updateAllocation(Allocation allocation) {
    if (allocation.userId != userId) {
      throw Exception('Cannot update allocation for different user');
    }
    return _db.update(_db.allocations).replace(allocation);
  }

  /// Soft delete FOR THIS USER
  Future<void> deleteAllocation(String id) {
    return (_db.update(_db.allocations)
          ..where((a) =>
              a.userId.equals(userId) & // CRITICAL: Filter by userId
              a.id.equals(id)))
        .write(const AllocationsCompanion(isDeleted: Value(true)));
  }

  /// Delete all allocations for a budget FOR THIS USER
  Future<void> deleteAllocationsByBudget(String budgetId) {
    return (_db.update(_db.allocations)
          ..where((a) =>
              a.userId.equals(userId) & // CRITICAL: Filter by userId
              a.budgetId.equals(budgetId)))
        .write(const AllocationsCompanion(isDeleted: Value(true)));
  }

  /// Get unsynced allocations FOR THIS USER
  Future<List<Allocation>> getUnsyncedAllocations() {
    return (_db.select(_db.allocations)
          ..where((a) =>
              a.userId.equals(userId) & // CRITICAL: Filter by userId
              a.isSynced.equals(false)))
        .get();
  }

  /// Mark as synced FOR THIS USER
  Future<void> markAsSynced(String id) {
    return (_db.update(_db.allocations)
          ..where((a) =>
              a.userId.equals(userId) & // CRITICAL: Filter by userId
              a.id.equals(id)))
        .write(AllocationsCompanion(
          isSynced: const Value(true),
          lastSyncedAt: Value(DateTime.now()),
        ));
  }
}
