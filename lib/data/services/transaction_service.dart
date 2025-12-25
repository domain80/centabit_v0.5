import 'dart:async';

import 'package:centabit/data/models/transaction_model.dart';
import 'package:centabit/data/services/category_service.dart';

class TransactionService {
  final List<TransactionModel> _transactions = [];
  final _transactionsController =
      StreamController<List<TransactionModel>>.broadcast();
  final CategoryService _categoryService;

  Stream<List<TransactionModel>> get transactionsStream =>
      _transactionsController.stream;

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
    final entertainmentId = categories
        .firstWhere((c) => c.name == 'Entertainment')
        .id;
    final transportId = categories.firstWhere((c) => c.name == 'Transport').id;
    final healthcareId = categories
        .firstWhere((c) => c.name == 'Healthcare')
        .id;
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
        id: '34',
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
        id: '44',
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
        id: '54',
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
        id: '64',
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
        id: '74',
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
        id: '84',
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
        id: '94',
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
        id: '35',
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
      TransactionModel(
        id: '9',
        name: 'Amazon Purchase',
        amount: 89.99,
        type: TransactionType.debit,
        categoryId: entertainmentId,
        budgetId: null,
        transactionDate: twoDaysAgo.copyWith(hour: 14, minute: 20),
        notes: 'Books and electronics',
        createdAt: twoDaysAgo,
        updatedAt: twoDaysAgo,
      ),
      TransactionModel(
        id: '10',
        name: 'Gym Membership',
        amount: 49.99,
        type: TransactionType.debit,
        categoryId: healthcareId,
        budgetId: null,
        transactionDate: twoDaysAgo.copyWith(hour: 9, minute: 0),
        notes: 'Monthly membership',
        createdAt: twoDaysAgo,
        updatedAt: twoDaysAgo,
      ),
      TransactionModel(
        id: '11',
        name: 'Trader Joes',
        amount: 67.45,
        type: TransactionType.debit,
        categoryId: groceriesId,
        budgetId: null,
        transactionDate: now
            .subtract(const Duration(days: 3))
            .copyWith(hour: 11, minute: 30),
        notes: 'Weekly groceries',
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
      TransactionModel(
        id: '12',
        name: 'Lyft Ride',
        amount: 18.75,
        type: TransactionType.debit,
        categoryId: transportId,
        budgetId: null,
        transactionDate: now
            .subtract(const Duration(days: 3))
            .copyWith(hour: 19, minute: 0),
        notes: 'Airport pickup',
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
      TransactionModel(
        id: '13',
        name: 'Morning Coffee',
        amount: 4.50,
        type: TransactionType.debit,
        categoryId: coffeeId,
        budgetId: null,
        transactionDate: now
            .subtract(const Duration(days: 4))
            .copyWith(hour: 7, minute: 45),
        notes: null,
        createdAt: now.subtract(const Duration(days: 4)),
        updatedAt: now.subtract(const Duration(days: 4)),
      ),
      TransactionModel(
        id: '14',
        name: 'Movie Tickets',
        amount: 32.00,
        type: TransactionType.debit,
        categoryId: entertainmentId,
        budgetId: null,
        transactionDate: now
            .subtract(const Duration(days: 4))
            .copyWith(hour: 20, minute: 0),
        notes: '2 tickets',
        createdAt: now.subtract(const Duration(days: 4)),
        updatedAt: now.subtract(const Duration(days: 4)),
      ),
      TransactionModel(
        id: '15',
        name: 'Costco',
        amount: 156.78,
        type: TransactionType.debit,
        categoryId: groceriesId,
        budgetId: null,
        transactionDate: now
            .subtract(const Duration(days: 5))
            .copyWith(hour: 14, minute: 0),
        notes: 'Bulk shopping',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
      TransactionModel(
        id: '16',
        name: 'Pharmacy',
        amount: 23.45,
        type: TransactionType.debit,
        categoryId: healthcareId,
        budgetId: null,
        transactionDate: now
            .subtract(const Duration(days: 5))
            .copyWith(hour: 10, minute: 30),
        notes: 'Prescription refill',
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
      TransactionModel(
        id: '17',
        name: 'Thai Restaurant',
        amount: 38.50,
        type: TransactionType.debit,
        categoryId: diningId,
        budgetId: null,
        transactionDate: now
            .subtract(const Duration(days: 6))
            .copyWith(hour: 19, minute: 30),
        notes: 'Lunch with friends',
        createdAt: now.subtract(const Duration(days: 6)),
        updatedAt: now.subtract(const Duration(days: 6)),
      ),
      TransactionModel(
        id: '18',
        name: 'Shell Gas',
        amount: 52.00,
        type: TransactionType.debit,
        categoryId: gasId,
        budgetId: null,
        transactionDate: now
            .subtract(const Duration(days: 6))
            .copyWith(hour: 8, minute: 0),
        notes: 'Full tank',
        createdAt: now.subtract(const Duration(days: 6)),
        updatedAt: now.subtract(const Duration(days: 6)),
      ),
      TransactionModel(
        id: '19',
        name: 'Freelance Payment',
        amount: 750.00,
        type: TransactionType.credit,
        categoryId: null,
        budgetId: null,
        transactionDate: now
            .subtract(const Duration(days: 7))
            .copyWith(hour: 12, minute: 0),
        notes: 'Website project',
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(days: 7)),
      ),
      TransactionModel(
        id: '20',
        name: 'Spotify Premium',
        amount: 9.99,
        type: TransactionType.debit,
        categoryId: entertainmentId,
        budgetId: null,
        transactionDate: now
            .subtract(const Duration(days: 7))
            .copyWith(hour: 0, minute: 1),
        notes: 'Monthly subscription',
        createdAt: now.subtract(const Duration(days: 7)),
        updatedAt: now.subtract(const Duration(days: 7)),
      ),
      TransactionModel(
        id: '21',
        name: 'Target',
        amount: 94.32,
        type: TransactionType.debit,
        categoryId: groceriesId,
        budgetId: null,
        transactionDate: now
            .subtract(const Duration(days: 8))
            .copyWith(hour: 15, minute: 45),
        notes: 'Household items',
        createdAt: now.subtract(const Duration(days: 8)),
        updatedAt: now.subtract(const Duration(days: 8)),
      ),
      TransactionModel(
        id: '22',
        name: 'Uber Eats',
        amount: 28.99,
        type: TransactionType.debit,
        categoryId: diningId,
        budgetId: null,
        transactionDate: now
            .subtract(const Duration(days: 8))
            .copyWith(hour: 20, minute: 30),
        notes: 'Late night delivery',
        createdAt: now.subtract(const Duration(days: 8)),
        updatedAt: now.subtract(const Duration(days: 8)),
      ),
      TransactionModel(
        id: '23',
        name: 'Blue Bottle Coffee',
        amount: 6.25,
        type: TransactionType.debit,
        categoryId: coffeeId,
        budgetId: null,
        transactionDate: now
            .subtract(const Duration(days: 9))
            .copyWith(hour: 9, minute: 15),
        notes: null,
        createdAt: now.subtract(const Duration(days: 9)),
        updatedAt: now.subtract(const Duration(days: 9)),
      ),
      TransactionModel(
        id: '24',
        name: 'Metro Card Reload',
        amount: 50.00,
        type: TransactionType.debit,
        categoryId: transportId,
        budgetId: null,
        transactionDate: now
            .subtract(const Duration(days: 9))
            .copyWith(hour: 7, minute: 30),
        notes: 'Monthly pass',
        createdAt: now.subtract(const Duration(days: 9)),
        updatedAt: now.subtract(const Duration(days: 9)),
      ),
      TransactionModel(
        id: '25',
        name: 'Concert Tickets',
        amount: 120.00,
        type: TransactionType.debit,
        categoryId: entertainmentId,
        budgetId: null,
        transactionDate: now
            .subtract(const Duration(days: 10))
            .copyWith(hour: 10, minute: 0),
        notes: 'Live music event',
        createdAt: now.subtract(const Duration(days: 10)),
        updatedAt: now.subtract(const Duration(days: 10)),
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
    _transactions.sort(
      (a, b) => b.transactionDate.compareTo(a.transactionDate),
    );
  }

  void _emitTransactions() {
    _transactionsController.add(List.unmodifiable(_transactions));
  }

  void dispose() {
    _transactionsController.close();
  }
}
