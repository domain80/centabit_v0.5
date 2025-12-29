import 'dart:async';
import 'package:centabit/data/local/allocation_local_source.dart';
import 'package:centabit/data/models/allocation_model.dart';
import 'package:centabit/data/local/database.dart' as db;
import 'package:drift/drift.dart';

/// Repository for allocation data (local-only for now)
///
/// Responsibilities:
/// 1. Coordinate LocalSource (and future RemoteSource)
/// 2. Emit broadcast streams (like v0.5 services)
/// 3. Transform Drift entities ↔ Domain Models
/// 4. Manage sync queue (stub for now - no API yet)
class AllocationRepository {
  final AllocationLocalSource _localSource;

  final _allocationsController =
      StreamController<List<AllocationModel>>.broadcast();
  StreamSubscription? _dbSubscription;

  AllocationRepository(this._localSource) {
    _subscribeToLocalChanges();
  }

  /// Public stream (like v0.5 services)
  Stream<List<AllocationModel>> get allocationsStream =>
      _allocationsController.stream;

  /// Synchronous getter for immediate access (like v0.5 services)
  List<AllocationModel> get allocations => _latestAllocations;

  List<AllocationModel> _latestAllocations = [];

  /// Subscribe to Drift's reactive queries
  void _subscribeToLocalChanges() {
    _dbSubscription = _localSource.watchAllAllocations().listen((dbAllocations) {
      final models = dbAllocations.map(_mapToModel).toList();
      _latestAllocations = models; // Cache for synchronous getter
      _allocationsController.add(models);
    });
  }

  /// Map Drift entity → Domain model
  AllocationModel _mapToModel(db.Allocation dbAllocation) {
    return AllocationModel(
      id: dbAllocation.id,
      amount: dbAllocation.amount,
      categoryId: dbAllocation.categoryId,
      budgetId: dbAllocation.budgetId,
      createdAt: dbAllocation.createdAt,
      updatedAt: dbAllocation.updatedAt,
    );
  }

  /// Map Domain model → Drift entity
  db.Allocation _mapToDbModel(AllocationModel model) {
    return db.Allocation(
      id: model.id,
      userId: _localSource.userId,
      budgetId: model.budgetId,
      categoryId: model.categoryId,
      amount: model.amount,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      isSynced: false,
      isDeleted: false,
      lastSyncedAt: null,
    );
  }

  /// Create allocation (optimistic update - local only for now)
  Future<void> createAllocation(AllocationModel model) async {
    await _localSource.createAllocation(
      db.AllocationsCompanion.insert(
        id: model.id,
        budgetId: model.budgetId,
        categoryId: model.categoryId,
        amount: model.amount,
        createdAt: model.createdAt,
        updatedAt: model.updatedAt,
        isSynced: const Value(false), // Ready for future API sync
      ),
    );

    // TODO: When API is ready, trigger background sync in isolate
  }

  /// Update allocation
  Future<void> updateAllocation(AllocationModel model) async {
    final updatedModel = model.withUpdatedTimestamp();
    await _localSource.updateAllocation(_mapToDbModel(updatedModel));

    // TODO: When API is ready, trigger background sync in isolate
  }

  /// Delete allocation (soft delete)
  Future<void> deleteAllocation(String id) async {
    await _localSource.deleteAllocation(id);

    // TODO: When API is ready, trigger background sync in isolate
  }

  /// Get allocation by ID
  Future<AllocationModel?> getAllocationById(String id) async {
    final dbAllocation = await _localSource.getAllocationById(id);
    return dbAllocation != null ? _mapToModel(dbAllocation) : null;
  }

  /// Get allocations for a specific budget (synchronous - from cache)
  List<AllocationModel> getAllocationsForBudget(String budgetId) {
    return _latestAllocations.forBudget(budgetId);
  }

  /// Get allocations for a specific category (synchronous - from cache)
  List<AllocationModel> getAllocationsForCategory(String categoryId) {
    return _latestAllocations.forCategory(categoryId);
  }

  /// Sync stub (ready for future API)
  Future<void> sync() async {
    // TODO: Implement API sync in isolate when backend is ready
    print('Sync not implemented yet - no API available');
  }

  void dispose() {
    _dbSubscription?.cancel();
    _allocationsController.close();
  }
}
