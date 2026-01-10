import 'package:centabit/core/logging/app_logger.dart';
import 'package:centabit/data/local/category_local_source.dart';
import 'package:centabit/data/local/database.dart';
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
  final AppDatabase _database;
  final CategoryLocalSource _categoryLocalSource;
  final CategoryRepository _categoryRepository;
  final BudgetRepository _budgetRepository;
  final AllocationRepository _allocationRepository;
  final TransactionRepository _transactionRepository;
  final AppLogger _logger = AppLogger.instance;

  DemoDataSeeder({
    required AppDatabase database,
    required CategoryLocalSource categoryLocalSource,
    required CategoryRepository categoryRepository,
    required BudgetRepository budgetRepository,
    required AllocationRepository allocationRepository,
    required TransactionRepository transactionRepository,
  }) : _database = database,
       _categoryLocalSource = categoryLocalSource,
       _categoryRepository = categoryRepository,
       _budgetRepository = budgetRepository,
       _allocationRepository = allocationRepository,
       _transactionRepository = transactionRepository;

  /// Seeds the database with demo data if it's empty
  ///
  /// Set [forceClear] to true to clear all existing data and reseed
  Future<void> seedIfEmpty({bool forceClear = false}) async {
    try {
      if (forceClear) {
        _logger.info('Force clear requested - dropping all data...');
        await _database.clearAllData();
        _logger.info('Database cleared successfully');
      }

      _logger.info('Checking if demo data seeding is needed...');

      // Check if data already exists by querying database directly
      // (repository cache may not be populated yet on app startup)
      final existingCategories = await _categoryLocalSource.getAllCategories();
      if (existingCategories.isNotEmpty) {
        _logger.info(
          'Demo data already exists (${existingCategories.length} categories found), skipping seed',
        );
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
      CategoryModel.create(name: 'Groceries', iconName: 'avocado'),
      CategoryModel.create(name: 'Dining Out', iconName: 'toolsKitchen2'),
      CategoryModel.create(name: 'Transportation', iconName: 'car'),
      CategoryModel.create(name: 'Shopping', iconName: 'shoppingCart'),
      CategoryModel.create(name: 'Utilities', iconName: 'bolt'),
      CategoryModel.create(name: 'Entertainment', iconName: 'movie'),
      CategoryModel.create(name: 'Healthcare', iconName: 'heart'),
      CategoryModel.create(name: 'Fitness', iconName: 'barbell'),
      CategoryModel.create(name: 'Subscriptions', iconName: 'wifi'),
      CategoryModel.create(name: 'Education', iconName: 'book'),
      CategoryModel.create(name: 'Pets', iconName: 'paw'),
      CategoryModel.create(name: 'Coffee & Cafes', iconName: 'coffee'),
      // Income category
      CategoryModel.create(name: 'Income', iconName: 'moneybagPlus'),
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
      amount: 4500.0,
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
    final expenseCategories = categories
        .where((cat) => cat.name != 'Income')
        .toList();

    final allocations = <AllocationModel>[
      AllocationModel.create(
        amount: 800.0,
        categoryId: expenseCategories
            .firstWhere((c) => c.name == 'Groceries')
            .id,
        budgetId: budget.id,
      ),
      AllocationModel.create(
        amount: 400.0,
        categoryId: expenseCategories
            .firstWhere((c) => c.name == 'Dining Out')
            .id,
        budgetId: budget.id,
      ),
      AllocationModel.create(
        amount: 500.0,
        categoryId: expenseCategories
            .firstWhere((c) => c.name == 'Transportation')
            .id,
        budgetId: budget.id,
      ),
      AllocationModel.create(
        amount: 350.0,
        categoryId: expenseCategories
            .firstWhere((c) => c.name == 'Shopping')
            .id,
        budgetId: budget.id,
      ),
      AllocationModel.create(
        amount: 600.0,
        categoryId: expenseCategories
            .firstWhere((c) => c.name == 'Utilities')
            .id,
        budgetId: budget.id,
      ),
      AllocationModel.create(
        amount: 300.0,
        categoryId: expenseCategories
            .firstWhere((c) => c.name == 'Entertainment')
            .id,
        budgetId: budget.id,
      ),
      AllocationModel.create(
        amount: 250.0,
        categoryId: expenseCategories
            .firstWhere((c) => c.name == 'Healthcare')
            .id,
        budgetId: budget.id,
      ),
      AllocationModel.create(
        amount: 200.0,
        categoryId: expenseCategories
            .firstWhere((c) => c.name == 'Fitness')
            .id,
        budgetId: budget.id,
      ),
      AllocationModel.create(
        amount: 150.0,
        categoryId: expenseCategories
            .firstWhere((c) => c.name == 'Subscriptions')
            .id,
        budgetId: budget.id,
      ),
      AllocationModel.create(
        amount: 300.0,
        categoryId: expenseCategories
            .firstWhere((c) => c.name == 'Education')
            .id,
        budgetId: budget.id,
      ),
      AllocationModel.create(
        amount: 200.0,
        categoryId: expenseCategories
            .firstWhere((c) => c.name == 'Pets')
            .id,
        budgetId: budget.id,
      ),
      AllocationModel.create(
        amount: 150.0,
        categoryId: expenseCategories
            .firstWhere((c) => c.name == 'Coffee & Cafes')
            .id,
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
    transactions.add(
      TransactionModel.create(
        name: 'Monthly Salary',
        amount: 4500.0,
        type: TransactionType.credit,
        categoryId: getCat('Income').id,
        budgetId: null, // Income not counted toward budget
        transactionDate: DateTime(now.year, now.month, 1, 9, 0),
        notes: 'Paycheck',
      ),
    );

    // Expense transactions spread throughout the month
    final expenseData = [
      // Day 1-3
      {
        'name': 'Grocery Shopping',
        'amount': 125.50,
        'category': 'Groceries',
        'day': 2,
        'hour': 18,
      },
      {
        'name': 'Morning Coffee',
        'amount': 5.25,
        'category': 'Coffee & Cafes',
        'day': 2,
        'hour': 8,
      },
      {
        'name': 'Gas Station',
        'amount': 55.00,
        'category': 'Transportation',
        'day': 3,
        'hour': 8,
      },
      {
        'name': 'Spotify Premium',
        'amount': 9.99,
        'category': 'Subscriptions',
        'day': 3,
        'hour': 10,
      },
      {
        'name': 'Lunch Out',
        'amount': 18.75,
        'category': 'Dining Out',
        'day': 3,
        'hour': 13,
      },

      // Day 4-6
      {
        'name': 'Movie Tickets',
        'amount': 32.00,
        'category': 'Entertainment',
        'day': 4,
        'hour': 19,
      },
      {
        'name': 'Pharmacy',
        'amount': 45.30,
        'category': 'Healthcare',
        'day': 4,
        'hour': 16,
      },
      {
        'name': 'Coffee Run',
        'amount': 6.50,
        'category': 'Coffee & Cafes',
        'day': 5,
        'hour': 9,
      },
      {
        'name': 'New Shirt',
        'amount': 45.00,
        'category': 'Shopping',
        'day': 5,
        'hour': 16,
      },
      {
        'name': 'Gym Membership',
        'amount': 65.00,
        'category': 'Fitness',
        'day': 6,
        'hour': 7,
      },
      {
        'name': 'Pet Food',
        'amount': 52.00,
        'category': 'Pets',
        'day': 6,
        'hour': 15,
      },

      // Day 7-10
      {
        'name': 'Dinner Date',
        'amount': 85.50,
        'category': 'Dining Out',
        'day': 7,
        'hour': 19,
      },
      {
        'name': 'Netflix',
        'amount': 15.99,
        'category': 'Subscriptions',
        'day': 8,
        'hour': 10,
      },
      {
        'name': 'Lunch at Bistro',
        'amount': 35.20,
        'category': 'Dining Out',
        'day': 8,
        'hour': 13,
      },
      {
        'name': 'Electric Bill',
        'amount': 120.00,
        'category': 'Utilities',
        'day': 9,
        'hour': 15,
      },
      {
        'name': 'Book Store',
        'amount': 42.99,
        'category': 'Education',
        'day': 9,
        'hour': 17,
      },
      {
        'name': 'Grocery Store',
        'amount': 98.30,
        'category': 'Groceries',
        'day': 10,
        'hour': 19,
      },
      {
        'name': 'Starbucks',
        'amount': 7.85,
        'category': 'Coffee & Cafes',
        'day': 10,
        'hour': 8,
      },

      // Day 11-14
      {
        'name': 'Concert Tickets',
        'amount': 120.00,
        'category': 'Entertainment',
        'day': 11,
        'hour': 20,
      },
      {
        'name': 'Yoga Class',
        'amount': 25.00,
        'category': 'Fitness',
        'day': 11,
        'hour': 18,
      },
      {
        'name': 'Uber Ride',
        'amount': 22.50,
        'category': 'Transportation',
        'day': 12,
        'hour': 22,
      },
      {
        'name': 'Doctor Copay',
        'amount': 30.00,
        'category': 'Healthcare',
        'day': 13,
        'hour': 10,
      },
      {
        'name': 'Coffee Shop',
        'amount': 5.50,
        'category': 'Coffee & Cafes',
        'day': 13,
        'hour': 14,
      },
      {
        'name': 'Online Course',
        'amount': 89.00,
        'category': 'Education',
        'day': 14,
        'hour': 20,
      },
      {
        'name': 'Brunch',
        'amount': 42.30,
        'category': 'Dining Out',
        'day': 14,
        'hour': 11,
      },

      // Day 15-18
      {
        'name': 'Apple iCloud',
        'amount': 2.99,
        'category': 'Subscriptions',
        'day': 15,
        'hour': 9,
      },
      {
        'name': 'Vet Checkup',
        'amount': 75.00,
        'category': 'Pets',
        'day': 15,
        'hour': 16,
      },
      {
        'name': 'New Shoes',
        'amount': 89.99,
        'category': 'Shopping',
        'day': 16,
        'hour': 16,
      },
      {
        'name': 'Coffee & Pastry',
        'amount': 9.25,
        'category': 'Coffee & Cafes',
        'day': 16,
        'hour': 8,
      },
      {
        'name': 'Gas Fill-up',
        'amount': 58.00,
        'category': 'Transportation',
        'day': 17,
        'hour': 7,
      },
      {
        'name': 'Dinner Out',
        'amount': 78.50,
        'category': 'Dining Out',
        'day': 17,
        'hour': 19,
      },
      {
        'name': 'Water Bill',
        'amount': 45.00,
        'category': 'Utilities',
        'day': 18,
        'hour': 10,
      },
      {
        'name': 'Personal Trainer',
        'amount': 80.00,
        'category': 'Fitness',
        'day': 18,
        'hour': 18,
      },

      // Day 19-22
      {
        'name': 'Weekly Groceries',
        'amount': 142.80,
        'category': 'Groceries',
        'day': 19,
        'hour': 17,
      },
      {
        'name': 'Streaming Bundle',
        'amount': 19.99,
        'category': 'Subscriptions',
        'day': 19,
        'hour': 11,
      },
      {
        'name': 'Movie Night',
        'amount': 65.00,
        'category': 'Entertainment',
        'day': 20,
        'hour': 19,
      },
      {
        'name': 'Pharmacy Refill',
        'amount': 38.50,
        'category': 'Healthcare',
        'day': 20,
        'hour': 15,
      },
      {
        'name': 'Cafe Latte',
        'amount': 6.00,
        'category': 'Coffee & Cafes',
        'day': 21,
        'hour': 9,
      },
      {
        'name': 'Books for Course',
        'amount': 125.00,
        'category': 'Education',
        'day': 21,
        'hour': 13,
      },
      {
        'name': 'Pet Grooming',
        'amount': 55.00,
        'category': 'Pets',
        'day': 22,
        'hour': 14,
      },
      {
        'name': 'Sushi Dinner',
        'amount': 92.00,
        'category': 'Dining Out',
        'day': 22,
        'hour': 20,
      },

      // Day 23-26
      {
        'name': 'Gas Station',
        'amount': 60.00,
        'category': 'Transportation',
        'day': 23,
        'hour': 9,
      },
      {
        'name': 'New Jacket',
        'amount': 125.00,
        'category': 'Shopping',
        'day': 23,
        'hour': 16,
      },
      {
        'name': 'Morning Coffee',
        'amount': 5.75,
        'category': 'Coffee & Cafes',
        'day': 24,
        'hour': 8,
      },
      {
        'name': 'Fitness Equipment',
        'amount': 45.00,
        'category': 'Fitness',
        'day': 24,
        'hour': 12,
      },
      {
        'name': 'Home Decor',
        'amount': 85.50,
        'category': 'Shopping',
        'day': 25,
        'hour': 15,
      },
      {
        'name': 'Streaming App',
        'amount': 12.99,
        'category': 'Subscriptions',
        'day': 25,
        'hour': 10,
      },
      {
        'name': 'Concert',
        'amount': 95.00,
        'category': 'Entertainment',
        'day': 26,
        'hour': 20,
      },
      {
        'name': 'Brunch with Friends',
        'amount': 48.30,
        'category': 'Dining Out',
        'day': 26,
        'hour': 11,
      },

      // Day 27-30
      {
        'name': 'Grocery Run',
        'amount': 87.25,
        'category': 'Groceries',
        'day': 27,
        'hour': 18,
      },
      {
        'name': 'Dentist Copay',
        'amount': 50.00,
        'category': 'Healthcare',
        'day': 27,
        'hour': 14,
      },

      // Recent transactions (only if we're past day 28)
      if (now.day >= 28) ...{
        {
          'name': 'Internet Bill',
          'amount': 89.99,
          'category': 'Utilities',
          'day': 28,
          'hour': 12,
        },
        {
          'name': 'Coffee Stop',
          'amount': 6.50,
          'category': 'Coffee & Cafes',
          'day': 28,
          'hour': 9,
        },
        {
          'name': 'Rideshare',
          'amount': 18.00,
          'category': 'Transportation',
          'day': 28,
          'hour': 22,
        },
        {
          'name': 'Pet Supplies',
          'amount': 35.00,
          'category': 'Pets',
          'day': 29,
          'hour': 16,
        },
        {
          'name': 'Fresh Groceries',
          'amount': 76.45,
          'category': 'Groceries',
          'day': 29,
          'hour': 18,
        },
        {
          'name': 'Lunch Out',
          'amount': 28.50,
          'category': 'Dining Out',
          'day': 29,
          'hour': 13,
        },
        {
          'name': 'Museum Tickets',
          'amount': 45.00,
          'category': 'Entertainment',
          'day': 30,
          'hour': 15,
        },
        {
          'name': 'Vitamins',
          'amount': 32.99,
          'category': 'Healthcare',
          'day': 30,
          'hour': 10,
        },
      },
    ];

    for (final data in expenseData) {
      final day = data['day'] as int;
      final hour = data['hour'] as int;

      // Only create transactions for dates that have already passed
      if (day <= now.day) {
        transactions.add(
          TransactionModel.create(
            name: data['name'] as String,
            amount: data['amount'] as double,
            type: TransactionType.debit,
            categoryId: getCat(data['category'] as String).id,
            budgetId: budget.id,
            transactionDate: DateTime(now.year, now.month, day, hour, 0),
          ),
        );
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
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }
}
