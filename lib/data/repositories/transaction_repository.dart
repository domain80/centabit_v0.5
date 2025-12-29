import 'dart:async';
import 'package:centabit/data/local/transaction_local_source.dart';
import 'package:centabit/data/models/transaction_model.dart';
import 'package:centabit/data/local/database.dart' as db;
import 'package:drift/drift.dart';

/// Repository for transaction data (local-only for now)
///
/// Responsibilities:
/// 1. Coordinate LocalSource (and future RemoteSource)
/// 2. Emit broadcast streams (like v0.5 services)
/// 3. Transform Drift entities ↔ Domain Models
/// 4. Manage sync queue (stub for now - no API yet)
class TransactionRepository {
  final TransactionLocalSource _localSource;

  final _transactionsController =
      StreamController<List<TransactionModel>>.broadcast();
  StreamSubscription? _dbSubscription;

  TransactionRepository(this._localSource) {
    _subscribeToLocalChanges();
  }

  /// Public stream (like v0.5 services)
  Stream<List<TransactionModel>> get transactionsStream =>
      _transactionsController.stream;

  /// Synchronous getter for immediate access (like v0.5 services)
  List<TransactionModel> get transactions => _latestTransactions;

  List<TransactionModel> _latestTransactions = [];

  /// Subscribe to Drift's reactive queries
  void _subscribeToLocalChanges() {
    _dbSubscription = _localSource.watchAllTransactions().listen((dbTransactions) {
      final models = dbTransactions.map(_mapToModel).toList();
      _latestTransactions = models; // Cache for synchronous getter
      _transactionsController.add(models);
    });
  }

  /// Map Drift entity → Domain model
  TransactionModel _mapToModel(db.Transaction dbTransaction) {
    return TransactionModel(
      id: dbTransaction.id,
      name: dbTransaction.name,
      amount: dbTransaction.amount,
      type: TransactionType.values.firstWhere(
        (e) => e.name == dbTransaction.type,
      ),
      transactionDate: dbTransaction.transactionDate,
      categoryId: dbTransaction.categoryId,
      budgetId: dbTransaction.budgetId,
      notes: dbTransaction.notes,
      createdAt: dbTransaction.createdAt,
      updatedAt: dbTransaction.updatedAt,
    );
  }

  /// Map Domain model → Drift entity
  db.Transaction _mapToDbModel(TransactionModel model) {
    return db.Transaction(
      id: model.id,
      userId: _localSource.userId,
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

  /// Create transaction (optimistic update - local only for now)
  Future<void> createTransaction(TransactionModel model) async {
    await _localSource.createTransaction(
      db.TransactionsCompanion.insert(
        id: model.id,
        name: model.name,
        amount: model.amount,
        type: model.type.name,
        transactionDate: model.transactionDate,
        categoryId: Value(model.categoryId),
        budgetId: Value(model.budgetId),
        notes: Value(model.notes),
        createdAt: model.createdAt,
        updatedAt: model.updatedAt,
        isSynced: const Value(false), // Ready for future API sync
      ),
    );

    // TODO: When API is ready, trigger background sync in isolate
  }

  /// Update transaction
  Future<void> updateTransaction(TransactionModel model) async {
    final updatedModel = model.copyWith(updatedAt: DateTime.now());
    await _localSource.updateTransaction(_mapToDbModel(updatedModel));

    // TODO: When API is ready, trigger background sync in isolate
  }

  /// Delete transaction (soft delete)
  Future<void> deleteTransaction(String id) async {
    await _localSource.deleteTransaction(id);

    // TODO: When API is ready, trigger background sync in isolate
  }

  /// Get transaction by ID
  Future<TransactionModel?> getTransactionById(String id) async {
    final dbTransaction = await _localSource.getTransactionById(id);
    return dbTransaction != null ? _mapToModel(dbTransaction) : null;
  }

  /// Sync stub (ready for future API)
  Future<void> sync() async {
    // TODO: Implement API sync in isolate when backend is ready
    print('Sync not implemented yet - no API available');
  }

  void dispose() {
    _dbSubscription?.cancel();
    _transactionsController.close();
  }
}
