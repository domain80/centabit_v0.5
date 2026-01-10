import 'package:centabit/core/logging/app_logger.dart';
import 'package:centabit/data/models/allocation_model.dart';
import 'package:centabit/data/models/budget_model.dart';
import 'package:centabit/data/models/category_model.dart';
import 'package:centabit/data/models/transaction_model.dart';
import 'package:centabit/data/repositories/allocation_repository.dart';
import 'package:centabit/data/repositories/budget_repository.dart';
import 'package:centabit/data/repositories/category_repository.dart';
import 'package:centabit/data/repositories/transaction_repository.dart';

/// Service for populating the database with demo data for testing and showcasing
class DemoDataSeeder {
  final CategoryRepository _categoryRepository;
  final BudgetRepository _budgetRepository;
  final AllocationRepository _allocationRepository;
  final TransactionRepository _transactionRepository;
  final AppLogger _logger = AppLogger.instance;

  DemoDataSeeder({
    required CategoryRepository categoryRepository,
    required BudgetRepository budgetRepository,
    required AllocationRepository allocationRepository,
    required TransactionRepository transactionRepository,
  })  : _categoryRepository = categoryRepository,
        _budgetRepository = budgetRepository,
        _allocationRepository = allocationRepository,
        _transactionRepository = transactionRepository;

  /// Seeds the database with demo data if it's empty
  Future<void> seedIfEmpty() async {
    try {
      _logger.info('Checking if demo data seeding is needed...');

      // Check if data already exists
      final existingCategories = _categoryRepository.categories;
      if (existingCategories.isNotEmpty) {
        _logger.info('Demo data already exists, skipping seed');
        return;
      }

      _logger.info('Seeding demo data...');

      // Seed in order: Categories → Budget → Allocations → Transactions
      final categories = await _seedCategories();
      final budget = await _seedBudget();
      await _seedAllocations(budget, categories);
      await _seedTransactions(budget, categories);

      _logger.info('Demo data seeding completed successfully');
    } catch (e, st) {
      _logger.error('Failed to seed demo data', error: e, stackTrace: st);
      rethrow;
    }
  }

  /// Creates sample categories for different expense and income types
  Future<List<CategoryModel>> _seedCategories() async {
    _logger.info('Seeding categories...');

    final categories = [
      // Expense categories
      CategoryModel.create(
        name: 'Groceries',
        iconName: 'shopping_cart',
      ),
      CategoryModel.create(
        name: 'Dining Out',
        iconName: 'restaurant',
      ),
      CategoryModel.create(
        name: 'Transportation',
        iconName: 'directions_car',
      ),
      CategoryModel.create(
        name: 'Entertainment',
        iconName: 'movie',
      ),
      CategoryModel.create(
        name: 'Shopping',
        iconName: 'shopping_bag',
      ),
      CategoryModel.create(
        name: 'Utilities',
        iconName: 'bolt',
      ),
      CategoryModel.create(
        name: 'Healthcare',
        iconName: 'local_hospital',
      ),
      CategoryModel.create(
        name: 'Fitness',
        iconName: 'fitness_center',
      ),
      // Income categories
      CategoryModel.create(
        name: 'Salary',
        iconName: 'account_balance_wallet',
      ),
      CategoryModel.create(
        name: 'Freelance',
        iconName: 'work',
      ),
    ];

    for (final category in categories) {
      await _categoryRepository.createCategory(category);
    }

    _logger.info('Created ${categories.length} categories');
    return categories;
  }

  /// Creates a budget for the current month
  Future<BudgetModel> _seedBudget() async {
    _logger.info('Seeding budget...');

    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, 1);
    final endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final monthName = _getMonthName(now.month);
    final budget = BudgetModel.create(
      name: '$monthName ${now.year}',
      amount: 3000.0,
      startDate: startDate,
      endDate: endDate,
    );

    await _budgetRepository.createBudget(budget);
    _logger.info('Created budget: ${budget.name}');

    return budget;
  }

  /// Creates allocations for the budget across categories
  Future<void> _seedAllocations(
    BudgetModel budget,
    List<CategoryModel> categories,
  ) async {
    _logger.info('Seeding allocations...');

    // Only allocate to expense categories (not income)
    final expenseCategories = categories.where((cat) =>
        cat.name != 'Salary' && cat.name != 'Freelance').toList();

    final allocations = <AllocationModel>[
      AllocationModel.create(
        amount: 600.0,
        categoryId: expenseCategories.firstWhere((c) => c.name == 'Groceries').id,
        budgetId: budget.id,
      ),
      AllocationModel.create(
        amount: 300.0,
        categoryId: expenseCategories.firstWhere((c) => c.name == 'Dining Out').id,
        budgetId: budget.id,
      ),
      AllocationModel.create(
        amount: 400.0,
        categoryId: expenseCategories.firstWhere((c) => c.name == 'Transportation').id,
        budgetId: budget.id,
      ),
      AllocationModel.create(
        amount: 200.0,
        categoryId: expenseCategories.firstWhere((c) => c.name == 'Entertainment').id,
        budgetId: budget.id,
      ),
      AllocationModel.create(
        amount: 300.0,
        categoryId: expenseCategories.firstWhere((c) => c.name == 'Shopping').id,
        budgetId: budget.id,
      ),
      AllocationModel.create(
        amount: 500.0,
        categoryId: expenseCategories.firstWhere((c) => c.name == 'Utilities').id,
        budgetId: budget.id,
      ),
      AllocationModel.create(
        amount: 200.0,
        categoryId: expenseCategories.firstWhere((c) => c.name == 'Healthcare').id,
        budgetId: budget.id,
      ),
      AllocationModel.create(
        amount: 150.0,
        categoryId: expenseCategories.firstWhere((c) => c.name == 'Fitness').id,
        budgetId: budget.id,
      ),
    ];

    for (final allocation in allocations) {
      await _allocationRepository.createAllocation(allocation);
    }

    final totalAllocated = allocations.fold<double>(
      0.0,
      (sum, alloc) => sum + alloc.amount,
    );

    _logger.info(
      'Created ${allocations.length} allocations, '
      'total: \$${totalAllocated.toStringAsFixed(2)} / \$${budget.amount.toStringAsFixed(2)}',
    );
  }

  /// Creates sample transactions for the current month
  Future<void> _seedTransactions(
    BudgetModel budget,
    List<CategoryModel> categories,
  ) async {
    _logger.info('Seeding transactions...');

    final now = DateTime.now();
    final transactions = <TransactionModel>[];

    // Helper to find category by name
    CategoryModel getCat(String name) =>
        categories.firstWhere((c) => c.name == name);

    // Income transactions (beginning of month)
    transactions.add(TransactionModel.create(
      name: 'Monthly Salary',
      amount: 4500.0,
      type: TransactionType.credit,
      categoryId: getCat('Salary').id,
      budgetId: null, // Income not counted toward budget
      transactionDate: DateTime(now.year, now.month, 1, 9, 0),
      notes: 'January paycheck',
    ));

    transactions.add(TransactionModel.create(
      name: 'Freelance Project',
      amount: 800.0,
      type: TransactionType.credit,
      categoryId: getCat('Freelance').id,
      budgetId: null,
      transactionDate: DateTime(now.year, now.month, 5, 14, 30),
      notes: 'Website design project',
    ));

    // Expense transactions spread throughout the month
    final expenseData = [
      // Week 1
      {'name': 'Grocery Shopping', 'amount': 125.50, 'category': 'Groceries', 'day': 2, 'hour': 18},
      {'name': 'Gas Station', 'amount': 55.00, 'category': 'Transportation', 'day': 3, 'hour': 8},
      {'name': 'Coffee Shop', 'amount': 12.75, 'category': 'Dining Out', 'day': 4, 'hour': 10},
      {'name': 'Gym Membership', 'amount': 50.00, 'category': 'Fitness', 'day': 5, 'hour': 7},

      // Week 2
      {'name': 'Lunch at Bistro', 'amount': 35.20, 'category': 'Dining Out', 'day': 8, 'hour': 13},
      {'name': 'Electric Bill', 'amount': 120.00, 'category': 'Utilities', 'day': 9, 'hour': 15},
      {'name': 'Grocery Store', 'amount': 98.30, 'category': 'Groceries', 'day': 10, 'hour': 19},
      {'name': 'Movie Tickets', 'amount': 45.00, 'category': 'Entertainment', 'day': 11, 'hour': 20},
      {'name': 'Uber Ride', 'amount': 22.50, 'category': 'Transportation', 'day': 12, 'hour': 22},

      // Week 3
      {'name': 'Pharmacy', 'amount': 35.75, 'category': 'Healthcare', 'day': 15, 'hour': 11},
      {'name': 'New Shoes', 'amount': 89.99, 'category': 'Shopping', 'day': 16, 'hour': 16},
      {'name': 'Dinner Date', 'amount': 78.50, 'category': 'Dining Out', 'day': 17, 'hour': 19},
      {'name': 'Water Bill', 'amount': 45.00, 'category': 'Utilities', 'day': 18, 'hour': 10},
      {'name': 'Groceries', 'amount': 142.80, 'category': 'Groceries', 'day': 19, 'hour': 17},

      // Week 4
      {'name': 'Concert Tickets', 'amount': 120.00, 'category': 'Entertainment', 'day': 22, 'hour': 21},
      {'name': 'Gas', 'amount': 60.00, 'category': 'Transportation', 'day': 23, 'hour': 9},
      {'name': 'Brunch', 'amount': 42.30, 'category': 'Dining Out', 'day': 24, 'hour': 11},
      {'name': 'Home Decor', 'amount': 156.75, 'category': 'Shopping', 'day': 25, 'hour': 15},
      {'name': 'Doctor Visit', 'amount': 85.00, 'category': 'Healthcare', 'day': 26, 'hour': 14},

      // Recent transactions (only if we're past day 28)
      if (now.day >= 28) ...{
        {'name': 'Internet Bill', 'amount': 89.99, 'category': 'Utilities', 'day': 28, 'hour': 12},
        {'name': 'Groceries', 'amount': 76.45, 'category': 'Groceries', 'day': 29, 'hour': 18},
      },
    ];

    for (final data in expenseData) {
      final day = data['day'] as int;
      final hour = data['hour'] as int;

      // Only create transactions for dates that have already passed
      if (day <= now.day) {
        transactions.add(TransactionModel.create(
          name: data['name'] as String,
          amount: data['amount'] as double,
          type: TransactionType.debit,
          categoryId: getCat(data['category'] as String).id,
          budgetId: budget.id,
          transactionDate: DateTime(now.year, now.month, day, hour, 0),
        ));
      }
    }

    // Create all transactions
    for (final transaction in transactions) {
      await _transactionRepository.createTransaction(transaction);
    }

    final totalExpenses = transactions
        .where((t) => t.type == TransactionType.debit)
        .fold<double>(0.0, (sum, t) => sum + t.amount);

    final totalIncome = transactions
        .where((t) => t.type == TransactionType.credit)
        .fold<double>(0.0, (sum, t) => sum + t.amount);

    _logger.info(
      'Created ${transactions.length} transactions '
      '(Income: \$${totalIncome.toStringAsFixed(2)}, '
      'Expenses: \$${totalExpenses.toStringAsFixed(2)})',
    );
  }

  /// Helper to get month name from month number
  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}
