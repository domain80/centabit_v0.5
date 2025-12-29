import 'dart:async';
import 'package:centabit/data/local/budget_local_source.dart';
import 'package:centabit/data/models/budget_model.dart';
import 'package:centabit/data/local/database.dart' as db;
import 'package:drift/drift.dart';

/// Repository for budget data (local-only for now)
///
/// Responsibilities:
/// 1. Coordinate LocalSource (and future RemoteSource)
/// 2. Emit broadcast streams (like v0.5 services)
/// 3. Transform Drift entities ↔ Domain Models
/// 4. Manage sync queue (stub for now - no API yet)
class BudgetRepository {
  final BudgetLocalSource _localSource;

  final _budgetsController =
      StreamController<List<BudgetModel>>.broadcast();
  StreamSubscription? _dbSubscription;

  BudgetRepository(this._localSource) {
    _subscribeToLocalChanges();
  }

  /// Public stream (like v0.5 services)
  Stream<List<BudgetModel>> get budgetsStream =>
      _budgetsController.stream;

  /// Synchronous getter for immediate access (like v0.5 services)
  List<BudgetModel> get budgets => _latestBudgets;

  List<BudgetModel> _latestBudgets = [];

  /// Subscribe to Drift's reactive queries
  void _subscribeToLocalChanges() {
    _dbSubscription = _localSource.watchAllBudgets().listen((dbBudgets) {
      final models = dbBudgets.map(_mapToModel).toList();
      _latestBudgets = models; // Cache for synchronous getter
      _budgetsController.add(models);
    });
  }

  /// Map Drift entity → Domain model
  BudgetModel _mapToModel(db.Budget dbBudget) {
    return BudgetModel(
      id: dbBudget.id,
      name: dbBudget.name,
      amount: dbBudget.amount,
      startDate: dbBudget.startDate,
      endDate: dbBudget.endDate,
      createdAt: dbBudget.createdAt,
      updatedAt: dbBudget.updatedAt,
    );
  }

  /// Map Domain model → Drift entity
  db.Budget _mapToDbModel(BudgetModel model) {
    return db.Budget(
      id: model.id,
      userId: _localSource.userId,
      name: model.name,
      amount: model.amount,
      startDate: model.startDate,
      endDate: model.endDate,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
      isSynced: false,
      isDeleted: false,
      lastSyncedAt: null,
    );
  }

  /// Create budget (optimistic update - local only for now)
  Future<void> createBudget(BudgetModel model) async {
    await _localSource.createBudget(
      db.BudgetsCompanion.insert(
        id: model.id,
        userId: _localSource.userId,
        name: model.name,
        amount: model.amount,
        startDate: model.startDate,
        endDate: model.endDate,
        createdAt: model.createdAt,
        updatedAt: model.updatedAt,
        isSynced: const Value(false), // Ready for future API sync
      ),
    );

    // TODO: When API is ready, trigger background sync in isolate
  }

  /// Update budget
  Future<void> updateBudget(BudgetModel model) async {
    final updatedModel = model.withUpdatedTimestamp();
    await _localSource.updateBudget(_mapToDbModel(updatedModel));

    // TODO: When API is ready, trigger background sync in isolate
  }

  /// Delete budget (soft delete)
  Future<void> deleteBudget(String id) async {
    await _localSource.deleteBudget(id);

    // TODO: When API is ready, trigger background sync in isolate
  }

  /// Get budget by ID
  Future<BudgetModel?> getBudgetById(String id) async {
    final dbBudget = await _localSource.getBudgetById(id);
    return dbBudget != null ? _mapToModel(dbBudget) : null;
  }

  /// Get active budgets (synchronous - from cache)
  List<BudgetModel> getActiveBudgets() {
    return _latestBudgets.where((budget) => budget.isActive()).toList();
  }

  /// Sync stub (ready for future API)
  Future<void> sync() async {
    // TODO: Implement API sync in isolate when backend is ready
    print('Sync not implemented yet - no API available');
  }

  void dispose() {
    _dbSubscription?.cancel();
    _budgetsController.close();
  }
}
