import 'package:drift/drift.dart';
import 'package:centabit/data/local/database.dart';

/// Local data source for transactions with userId filtering
///
/// All queries are automatically filtered by userId for security and multi-user support.
class TransactionLocalSource {
  final AppDatabase _db;
  final String userId; // CRITICAL: Injected userId for filtering

  TransactionLocalSource(this._db, this.userId);

  /// Reactive stream of all non-deleted transactions FOR THIS USER
  Stream<List<Transaction>> watchAllTransactions() {
    return (_db.select(_db.transactions)
          ..where((t) =>
              t.userId.equals(userId) & // CRITICAL: Filter by userId
              t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
        .watch();
  }

  /// Reactive stream filtered by date FOR THIS USER
  Stream<List<Transaction>> watchTransactionsByDate(DateTime date) {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return (_db.select(_db.transactions)
          ..where((t) =>
              t.userId.equals(userId) & // CRITICAL: Filter by userId
              t.isDeleted.equals(false) &
              t.transactionDate.isBiggerOrEqualValue(startOfDay) &
              t.transactionDate.isSmallerThanValue(endOfDay)))
        .watch();
  }

  /// Get single transaction FOR THIS USER
  Future<Transaction?> getTransactionById(String id) {
    return (_db.select(_db.transactions)
          ..where((t) =>
              t.userId.equals(userId) & // CRITICAL: Filter by userId
              t.id.equals(id)))
        .getSingleOrNull();
  }

  /// Create transaction (userId automatically added)
  Future<void> createTransaction(TransactionsCompanion transaction) {
    // Ensure userId is set
    final withUser = transaction.copyWith(userId: Value(userId));
    return _db.into(_db.transactions).insert(withUser);
  }

  /// Update transaction (userId check for security)
  Future<void> updateTransaction(Transaction transaction) {
    if (transaction.userId != userId) {
      throw Exception('Cannot update transaction for different user');
    }
    return _db.update(_db.transactions).replace(transaction);
  }

  /// Soft delete FOR THIS USER
  Future<void> deleteTransaction(String id) {
    return (_db.update(_db.transactions)
          ..where((t) =>
              t.userId.equals(userId) & // CRITICAL: Filter by userId
              t.id.equals(id)))
        .write(const TransactionsCompanion(isDeleted: Value(true)));
  }

  /// Get unsynced transactions FOR THIS USER
  Future<List<Transaction>> getUnsyncedTransactions() {
    return (_db.select(_db.transactions)
          ..where((t) =>
              t.userId.equals(userId) & // CRITICAL: Filter by userId
              t.isSynced.equals(false)))
        .get();
  }

  /// Mark as synced FOR THIS USER
  Future<void> markAsSynced(String id) {
    return (_db.update(_db.transactions)
          ..where((t) =>
              t.userId.equals(userId) & // CRITICAL: Filter by userId
              t.id.equals(id)))
        .write(TransactionsCompanion(
          isSynced: const Value(true),
          lastSyncedAt: Value(DateTime.now()),
        ));
  }
}
