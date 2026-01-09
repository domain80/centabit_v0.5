# Testing Guidelines

Testing is crucial for maintaining code quality and preventing regressions in Centabit v0.5. This guide covers how to write and run tests for the project.

## Current Test Status

::: warning Work in Progress
Centabit's test framework is currently being established. We're actively working on:
- Setting up comprehensive test infrastructure
- Writing unit tests for core functionality
- Creating widget tests for UI components
- Establishing integration test patterns

**Your contributions to testing are especially valuable right now!**
:::

## Why Testing Matters

Good tests provide:
- **Confidence**: Know that changes don't break existing functionality
- **Documentation**: Tests show how code is intended to work
- **Faster Development**: Catch bugs early, before they reach users
- **Refactoring Safety**: Change code with confidence
- **Quality Assurance**: Maintain high code standards

## Test Types

Centabit uses three types of tests:

### 1. Unit Tests
Test individual functions, classes, and methods in isolation.

**What to test**:
- Repository methods
- Cubit state transitions
- Data model transformations
- Utility functions
- Business logic calculations (e.g., BAR calculation)

**Example**: Testing a repository method
```dart
// test/data/repositories/transaction_repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:centabit/data/repositories/transaction_repository.dart';

void main() {
  group('TransactionRepository', () {
    late TransactionRepository repository;
    late MockTransactionLocalSource mockLocalSource;

    setUp(() {
      mockLocalSource = MockTransactionLocalSource();
      repository = TransactionRepository(mockLocalSource);
    });

    test('should fetch all transactions', () async {
      // Arrange
      final expectedTransactions = [
        TransactionModel(id: '1', amount: 50.0, /* ... */),
        TransactionModel(id: '2', amount: 75.0, /* ... */),
      ];
      when(mockLocalSource.watchAllTransactions())
          .thenAnswer((_) => Stream.value(expectedTransactions));

      // Act
      final result = await repository.transactionsStream.first;

      // Assert
      expect(result.length, 2);
      expect(result.first.amount, 50.0);
    });

    test('should create transaction with userId', () async {
      // Arrange
      final newTransaction = TransactionModel.create(
        amount: 100.0,
        categoryId: 'cat-1',
        /* ... */
      );

      // Act
      await repository.createTransaction(newTransaction);

      // Assert
      verify(mockLocalSource.createTransaction(any)).called(1);
    });
  });
}
```

### 2. Widget Tests
Test individual widgets and their interactions.

**What to test**:
- Widget rendering
- User interactions (taps, swipes, input)
- State changes
- Navigation
- Form validation

**Example**: Testing a button widget
```dart
// test/features/budgets/presentation/widgets/budget_card_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:centabit/features/budgets/presentation/widgets/budget_card.dart';

void main() {
  testWidgets('BudgetCard displays budget information', (tester) async {
    // Arrange
    final budget = BudgetModel(
      id: '1',
      name: 'Monthly Budget',
      amount: 1000.0,
      /* ... */
    );

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BudgetCard(budget: budget),
        ),
      ),
    );

    // Assert
    expect(find.text('Monthly Budget'), findsOneWidget);
    expect(find.text('\$1,000.00'), findsOneWidget);
  });

  testWidgets('BudgetCard calls onTap when tapped', (tester) async {
    // Arrange
    bool wasTapped = false;
    final budget = BudgetModel(/* ... */);

    // Act
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: BudgetCard(
            budget: budget,
            onTap: () => wasTapped = true,
          ),
        ),
      ),
    );

    await tester.tap(find.byType(BudgetCard));
    await tester.pump();

    // Assert
    expect(wasTapped, true);
  });
}
```

### 3. Integration Tests
Test complete user flows across multiple screens.

**What to test**:
- End-to-end user journeys
- Multi-screen workflows
- Real device behavior
- Performance characteristics

**Example**: Testing transaction creation flow
```dart
// integration_test/create_transaction_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:centabit/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Create transaction end-to-end', (tester) async {
    // Launch app
    app.main();
    await tester.pumpAndSettle();

    // Navigate to transactions page
    await tester.tap(find.text('Transactions'));
    await tester.pumpAndSettle();

    // Tap add button
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    // Fill form
    await tester.enterText(find.byKey(Key('amount-field')), '50.00');
    await tester.tap(find.text('Groceries'));
    await tester.pumpAndSettle();

    // Submit
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    // Verify transaction appears
    expect(find.text('\$50.00'), findsOneWidget);
    expect(find.text('Groceries'), findsOneWidget);
  });
}
```

## Running Tests

### Run All Tests
```bash
flutter test
```

### Run Specific Test File
```bash
flutter test test/data/repositories/transaction_repository_test.dart
```

### Run Tests with Coverage
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Run Integration Tests
```bash
flutter test integration_test
```

### Run Tests on Device
```bash
flutter test --device-id <device-id>
```

## Writing Good Tests

### Test Structure: Arrange-Act-Assert

Follow the AAA pattern for clear, readable tests:

```dart
test('should calculate BAR correctly', () {
  // Arrange - Set up test data and dependencies
  final budget = BudgetModel(amount: 1000.0, /* ... */);
  final spent = 400.0;
  final daysTotal = 30;
  final daysRemaining = 15;

  // Act - Execute the function being tested
  final bar = calculateBAR(
    budgetTotal: budget.amount,
    spent: spent,
    daysTotal: daysTotal,
    daysRemaining: daysRemaining,
  );

  // Assert - Verify the result
  expect(bar, closeTo(1.25, 0.01));
});
```

### Test Naming Conventions

Use descriptive test names that explain:
- What is being tested
- Under what conditions
- What the expected outcome is

**Good test names**:
```dart
test('should return empty list when no transactions exist', () { /* ... */ });
test('should throw exception when amount is negative', () { /* ... */ });
test('should emit loading state before fetching data', () { /* ... */ });
```

**Poor test names**:
```dart
test('test1', () { /* ... */ });
test('it works', () { /* ... */ });
test('transactions', () { /* ... */ });
```

### Use `group()` to Organize Tests

```dart
void main() {
  group('TransactionRepository', () {
    group('createTransaction', () {
      test('should save transaction to database', () { /* ... */ });
      test('should include userId in transaction', () { /* ... */ });
      test('should emit to transaction stream', () { /* ... */ });
    });

    group('deleteTransaction', () {
      test('should mark transaction as deleted', () { /* ... */ });
      test('should not actually remove from database', () { /* ... */ });
    });
  });
}
```

### Test Edge Cases

Don't just test the happy path:

```dart
group('Budget validation', () {
  test('should accept valid positive amount', () { /* ... */ });
  test('should reject negative amount', () { /* ... */ });
  test('should reject zero amount', () { /* ... */ });
  test('should reject null amount', () { /* ... */ });
  test('should reject extremely large amounts', () { /* ... */ });
  test('should handle decimal precision correctly', () { /* ... */ });
});
```

### Use Setup and Teardown

```dart
void main() {
  late TransactionRepository repository;
  late MockTransactionLocalSource mockLocalSource;

  setUp(() {
    // Runs before each test
    mockLocalSource = MockTransactionLocalSource();
    repository = TransactionRepository(mockLocalSource);
  });

  tearDown(() {
    // Runs after each test
    repository.dispose();
  });

  test('example test', () { /* ... */ });
}
```

## Mocking Dependencies

Use `mockito` to create mock objects for testing:

### Generate Mocks

```dart
// test/mocks/mocks.dart
import 'package:mockito/annotations.dart';
import 'package:centabit/data/local/transaction_local_source.dart';
import 'package:centabit/data/repositories/transaction_repository.dart';

@GenerateMocks([
  TransactionLocalSource,
  TransactionRepository,
  BudgetRepository,
])
void main() {}
```

Generate mock classes:
```bash
flutter pub run build_runner build
```

### Use Mocks in Tests

```dart
import 'mocks/mocks.mocks.dart';

void main() {
  late MockTransactionRepository mockRepository;

  setUp(() {
    mockRepository = MockTransactionRepository();
  });

  test('should load transactions on init', () async {
    // Arrange
    when(mockRepository.transactions).thenReturn([]);
    when(mockRepository.transactionsStream).thenAnswer(
      (_) => Stream.value([]),
    );

    // Act
    final cubit = TransactionListCubit(mockRepository);
    await Future.delayed(Duration.zero);

    // Assert
    verify(mockRepository.transactions).called(1);
  });
}
```

## Testing Cubits

### Test State Transitions

```dart
import 'package:bloc_test/bloc_test.dart';

void main() {
  group('DashboardCubit', () {
    late MockBudgetRepository mockBudgetRepo;
    late MockTransactionRepository mockTransactionRepo;

    setUp(() {
      mockBudgetRepo = MockBudgetRepository();
      mockTransactionRepo = MockTransactionRepository();
    });

    blocTest<DashboardCubit, DashboardState>(
      'emits loading then success when data loads',
      build: () {
        when(mockBudgetRepo.budgetsStream).thenAnswer(
          (_) => Stream.value([]),
        );
        when(mockTransactionRepo.transactionsStream).thenAnswer(
          (_) => Stream.value([]),
        );
        return DashboardCubit(mockBudgetRepo, mockTransactionRepo);
      },
      act: (cubit) => cubit.loadData(),
      expect: () => [
        const DashboardState.loading(),
        isA<DashboardState>().having(
          (s) => s.maybeWhen(success: (_) => true, orElse: () => false),
          'is success state',
          true,
        ),
      ],
    );

    blocTest<DashboardCubit, DashboardState>(
      'emits error state when loading fails',
      build: () {
        when(mockBudgetRepo.budgetsStream).thenAnswer(
          (_) => Stream.error('Network error'),
        );
        return DashboardCubit(mockBudgetRepo, mockTransactionRepo);
      },
      act: (cubit) => cubit.loadData(),
      expect: () => [
        const DashboardState.loading(),
        isA<DashboardState>().having(
          (s) => s.maybeWhen(error: (_) => true, orElse: () => false),
          'is error state',
          true,
        ),
      ],
    );
  });
}
```

## Testing Best Practices

### 1. Test Behavior, Not Implementation

**Good** - Test what the code does:
```dart
test('should filter transactions by category', () {
  // Test that filtering returns correct transactions
});
```

**Bad** - Test how the code does it:
```dart
test('should call where() method on list', () {
  // Testing internal implementation detail
});
```

### 2. Keep Tests Simple and Focused

Each test should verify one thing:

```dart
// Good - One test per behavior
test('should create budget with valid data', () { /* ... */ });
test('should validate budget name is not empty', () { /* ... */ });
test('should validate budget amount is positive', () { /* ... */ });

// Bad - Testing multiple things
test('should create budget and validate all fields', () { /* ... */ });
```

### 3. Use Test Data Builders

Create helper functions for test data:

```dart
// test/helpers/test_data_builders.dart
class TestDataBuilders {
  static BudgetModel createBudget({
    String? id,
    String name = 'Test Budget',
    double amount = 1000.0,
  }) {
    return BudgetModel(
      id: id ?? 'test-budget-1',
      name: name,
      amount: amount,
      startDate: DateTime.now(),
      endDate: DateTime.now().add(Duration(days: 30)),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  static TransactionModel createTransaction({
    String? id,
    double amount = 50.0,
    String categoryId = 'test-category-1',
  }) {
    return TransactionModel(
      id: id ?? 'test-transaction-1',
      amount: amount,
      categoryId: categoryId,
      date: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}
```

Use in tests:
```dart
test('example test', () {
  final budget = TestDataBuilders.createBudget(amount: 500.0);
  final transaction = TestDataBuilders.createTransaction(amount: 25.0);
  // ...
});
```

### 4. Avoid Test Interdependence

Tests should not depend on each other:

```dart
// Bad - Tests depend on execution order
var sharedData;

test('test 1', () {
  sharedData = createData();
});

test('test 2', () {
  // Depends on test 1 running first
  expect(sharedData, isNotNull);
});

// Good - Each test is independent
test('test 1', () {
  final data = createData();
  // Test uses its own data
});

test('test 2', () {
  final data = createData();
  // This test creates its own data
});
```

### 5. Test Async Code Properly

```dart
test('should load data asynchronously', () async {
  // Use async/await
  final result = await repository.fetchData();
  expect(result, isNotEmpty);
});

test('should handle stream emissions', () async {
  // Use expectLater for streams
  await expectLater(
    repository.dataStream,
    emitsInOrder([
      isEmpty,
      isNotEmpty,
    ]),
  );
});
```

## Widget Testing Tips

### Pump and Settle

```dart
// pump() - Triggers a single frame
await tester.pump();

// pumpAndSettle() - Triggers frames until animations complete
await tester.pumpAndSettle();

// pump(duration) - Advance time by duration
await tester.pump(Duration(seconds: 1));
```

### Finding Widgets

```dart
// Find by text
find.text('Submit')

// Find by type
find.byType(ElevatedButton)

// Find by key
find.byKey(Key('submit-button'))

// Find by icon
find.byIcon(Icons.add)

// Find by widget instance
find.byWidget(myWidget)

// Combine finders
find.descendant(
  of: find.byType(Card),
  matching: find.text('Title'),
)
```

### Interacting with Widgets

```dart
// Tap
await tester.tap(find.byType(ElevatedButton));

// Long press
await tester.longPress(find.text('Item'));

// Enter text
await tester.enterText(find.byType(TextField), 'Hello');

// Drag/scroll
await tester.drag(find.byType(ListView), Offset(0, -200));
await tester.fling(find.byType(ListView), Offset(0, -200), 1000);
```

### Testing BLoC in Widgets

```dart
testWidgets('should display loading indicator', (tester) async {
  final mockCubit = MockDashboardCubit();

  whenListen(
    mockCubit,
    Stream.fromIterable([
      const DashboardState.loading(),
    ]),
    initialState: const DashboardState.initial(),
  );

  await tester.pumpWidget(
    MaterialApp(
      home: BlocProvider<DashboardCubit>.value(
        value: mockCubit,
        child: DashboardPage(),
      ),
    ),
  );

  expect(find.byType(CircularProgressIndicator), findsOneWidget);
});
```

## Test Coverage Goals

We aim for:
- **Unit Test Coverage**: 80%+ for business logic
- **Widget Test Coverage**: 70%+ for UI components
- **Integration Tests**: Critical user flows

### Check Coverage

```bash
# Generate coverage report
flutter test --coverage

# View HTML report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### Focus on High-Value Tests

Priority areas for testing:
1. **Business Logic**: Calculations, validations, data transformations
2. **Repository Layer**: Data access and manipulation
3. **Cubit Logic**: State management and transitions
4. **Critical UI**: Forms, navigation, data display
5. **Edge Cases**: Error handling, empty states, boundary conditions

## Contributing Tests

### Finding What Needs Tests

1. Check coverage report for untested code
2. Look for issues tagged `testing` or `needs-tests`
3. Add tests when fixing bugs
4. Include tests with new features

### Test Contribution Checklist

- [ ] Tests are in appropriate directory (`test/` or `integration_test/`)
- [ ] Test file mirrors source file structure
  - Source: `lib/data/repositories/transaction_repository.dart`
  - Test: `test/data/repositories/transaction_repository_test.dart`
- [ ] Tests follow AAA pattern (Arrange-Act-Assert)
- [ ] Tests have descriptive names
- [ ] Tests are independent (no shared state)
- [ ] Tests use mocks for dependencies
- [ ] Tests cover happy path and edge cases
- [ ] Tests pass locally (`flutter test`)
- [ ] Code coverage increases (not decreases)

## Common Testing Pitfalls

### 1. Testing Too Much Implementation

```dart
// Bad - Testing internal method calls
test('should call _internalMethod', () {
  verify(mock._internalMethod()).called(1);
});

// Good - Testing observable behavior
test('should return correct result', () {
  expect(repository.getData(), expectedData);
});
```

### 2. Flaky Tests

```dart
// Bad - Time-dependent test
test('flaky test', () async {
  startAsyncOperation();
  await Future.delayed(Duration(milliseconds: 100));
  expect(result, expectedValue); // May fail if operation takes longer
});

// Good - Wait for actual completion
test('reliable test', () async {
  final future = startAsyncOperation();
  await expectLater(future, completion(expectedValue));
});
```

### 3. Over-Mocking

```dart
// Bad - Mocking simple data classes
final mockBudget = MockBudgetModel();
when(mockBudget.amount).thenReturn(1000.0);

// Good - Use real data objects
final budget = BudgetModel(amount: 1000.0, /* ... */);
```

## Resources

### Flutter Testing Documentation
- [Official Testing Guide](https://docs.flutter.dev/testing)
- [Widget Testing](https://docs.flutter.dev/cookbook/testing/widget/introduction)
- [Integration Testing](https://docs.flutter.dev/testing/integration-tests)

### Packages
- [`flutter_test`](https://api.flutter.dev/flutter/flutter_test/flutter_test-library.html) - Core testing framework
- [`mockito`](https://pub.dev/packages/mockito) - Mocking library
- [`bloc_test`](https://pub.dev/packages/bloc_test) - Testing BLoC/Cubit
- [`integration_test`](https://pub.dev/packages/integration_test) - Integration testing

### Testing Best Practices
- [Effective Dart: Testing](https://dart.dev/guides/language/effective-dart/testing)
- [Flutter Testing Best Practices](https://flutter.dev/docs/testing/best-practices)

## Getting Help

- **Stuck on a test?** Open an issue with `question` label
- **Want test review?** Tag maintainers in your PR
- **Found a bug?** Write a failing test, then fix it!

---

**Ready to contribute tests?** Pick an untested file and start writing! Every test makes Centabit more reliable.

Thank you for helping us build a robust, well-tested application!
