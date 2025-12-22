import 'dart:async';
import 'package:centabit/data/models/transaction_model.dart';
import 'package:centabit/data/services/category_service.dart';

class TransactionService {
  final List<TransactionModel> _transactions = [];
  final _transactionsController = StreamController<List<TransactionModel>>.broadcast();
  final CategoryService _categoryService;

  Stream<List<TransactionModel>> get transactionsStream => _transactionsController.stream;

  List<TransactionModel> get transactions => List.unmodifiable(_transactions);

  TransactionService(this._categoryService) {
    _initializeSampleTransactions();
  }

  void _initializeSampleTransactions() {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    final twoDaysAgo = now.subtract(const Duration(days: 2));

    // Get category IDs from the service
    final categories = _categoryService.categories;
    final groceriesId = categories.firstWhere((c) => c.name == 'Groceries').id;
    final entertainmentId = categories.firstWhere((c) => c.name == 'Entertainment').id;
    final transportId = categories.firstWhere((c) => c.name == 'Transport').id;
    final healthcareId = categories.firstWhere((c) => c.name == 'Healthcare').id;
    final diningId = categories.firstWhere((c) => c.name == 'Dining').id;
    final coffeeId = categories.firstWhere((c) => c.name == 'Coffee').id;
    final gasId = categories.firstWhere((c) => c.name == 'Gas & Fuel').id;

    final samples = [
      TransactionModel(
        id: '1',
        name: 'Whole Foods',
        amount: 45.99,
        type: TransactionType.debit,
        categoryId: groceriesId,
        budgetId: null,
        transactionDate: now.copyWith(hour: 10, minute: 30),
        notes: null,
        createdAt: now,
        updatedAt: now,
      ),
      TransactionModel(
        id: '2',
        name: 'Uber Ride',
        amount: 12.50,
        type: TransactionType.debit,
        categoryId: transportId,
        budgetId: null,
        transactionDate: now.copyWith(hour: 14, minute: 15),
        notes: 'Trip to office',
        createdAt: now,
        updatedAt: now,
      ),
      TransactionModel(
        id: '3',
        name: 'Netflix Subscription',
        amount: 15.99,
        type: TransactionType.debit,
        categoryId: entertainmentId,
        budgetId: null,
        transactionDate: yesterday.copyWith(hour: 9, minute: 0),
        notes: 'Monthly subscription',
        createdAt: yesterday,
        updatedAt: yesterday,
      ),
      TransactionModel(
        id: '4',
        name: 'Coffee at Starbucks',
        amount: 5.75,
        type: TransactionType.debit,
        categoryId: coffeeId,
        budgetId: null,
        transactionDate: yesterday.copyWith(hour: 8, minute: 30),
        notes: null,
        createdAt: yesterday,
        updatedAt: yesterday,
      ),
      TransactionModel(
        id: '5',
        name: 'Doctor Appointment',
        amount: 85.00,
        type: TransactionType.debit,
        categoryId: healthcareId,
        budgetId: null,
        transactionDate: twoDaysAgo.copyWith(hour: 11, minute: 0),
        notes: 'Checkup',
        createdAt: twoDaysAgo,
        updatedAt: twoDaysAgo,
      ),
      TransactionModel(
        id: '6',
        name: 'Salary Deposit',
        amount: 3500.00,
        type: TransactionType.credit,
        categoryId: null,
        budgetId: null,
        transactionDate: twoDaysAgo.copyWith(hour: 7, minute: 0),
        notes: null,
        createdAt: twoDaysAgo,
        updatedAt: twoDaysAgo,
      ),
      TransactionModel(
        id: '7',
        name: 'Dinner at Restaurant',
        amount: 52.30,
        type: TransactionType.debit,
        categoryId: diningId,
        budgetId: null,
        transactionDate: now.copyWith(hour: 19, minute: 45),
        notes: 'Date night',
        createdAt: now,
        updatedAt: now,
      ),
      TransactionModel(
        id: '8',
        name: 'Gas Station',
        amount: 45.00,
        type: TransactionType.debit,
        categoryId: gasId,
        budgetId: null,
        transactionDate: yesterday.copyWith(hour: 17, minute: 30),
        notes: null,
        createdAt: yesterday,
        updatedAt: yesterday,
      ),
    ];

    _transactions.addAll(samples);
    _sortTransactions();
    _emitTransactions();
  }

  Future<void> createTransaction(TransactionModel transaction) async {
    _transactions.add(transaction);
    _sortTransactions();
    _emitTransactions();
  }

  Future<void> updateTransaction(TransactionModel transaction) async {
    final index = _transactions.indexWhere((t) => t.id == transaction.id);
    if (index != -1) {
      _transactions[index] = transaction.copyWith(updatedAt: DateTime.now());
      _sortTransactions();
      _emitTransactions();
    }
  }

  Future<void> deleteTransaction(String id) async {
    _transactions.removeWhere((t) => t.id == id);
    _emitTransactions();
  }

  TransactionModel? getTransactionById(String id) {
    try {
      return _transactions.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

  List<TransactionModel> getTransactionsPaginated({
    int page = 0,
    int pageSize = 20,
  }) {
    final start = page * pageSize;
    final end = (start + pageSize).clamp(0, _transactions.length);

    if (start >= _transactions.length) return [];
    return _transactions.sublist(start, end);
  }

  void _sortTransactions() {
    _transactions.sort((a, b) => b.transactionDate.compareTo(a.transactionDate));
  }

  void _emitTransactions() {
    _transactionsController.add(List.unmodifiable(_transactions));
  }

  void dispose() {
    _transactionsController.close();
  }
}
