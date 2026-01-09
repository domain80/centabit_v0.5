# API Reference

Complete API documentation for Centabit v0.5 core classes and components.

## Models

Domain models representing core business entities:

- **[Transaction Model](./models/transaction-model.md)** - Individual financial transactions
- **[Budget Model](./models/budget-model.md)** - Budget definitions and periods
- **[Category Model](./models/category-model.md)** - Spending categories
- **[Allocation Model](./models/allocation-model.md)** - Budget-category allocations

## Repositories

Data access layer with reactive streams:

- **[Transaction Repository](./repositories/transaction-repository.md)** - Transaction CRUD and queries
- **[Budget Repository](./repositories/budget-repository.md)** - Budget management
- **[Category Repository](./repositories/category-repository.md)** - Category operations

## Cubits (State Management)

Presentation layer state management with BLoC pattern:

- **[Dashboard Cubit](./cubits/dashboard-cubit.md)** - Dashboard state with BAR calculations
- **[Transaction List Cubit](./cubits/transaction-list-cubit.md)** - Transaction list filtering and search

## Architecture Patterns

All API components follow these patterns:

- **Freezed Models**: Immutable data classes with union types
- **Repository Pattern**: Broadcast streams for reactive updates
- **userId Filtering**: All queries filtered by current user
- **Local-First**: SQLite as single source of truth

For detailed architecture information, see the [Architecture Guide](/architecture/).

## Usage Examples

Most features follow this pattern:

```dart
// 1. Register in dependency injection
getIt.registerLazySingleton<TransactionRepository>(
  () => TransactionRepository(getIt<TransactionLocalSource>()),
);

// 2. Inject into Cubit
class DashboardCubit extends Cubit<DashboardState> {
  final TransactionRepository _repository;

  DashboardCubit(this._repository) : super(const DashboardState.initial()) {
    _repository.transactionsStream.listen(_handleTransactions);
  }
}

// 3. Use in widget
BlocProvider(
  create: (_) => getIt<DashboardCubit>(),
  child: DashboardPage(),
)
```

## Contributing

Found an issue in the API docs? [Report it on GitHub](https://github.com/domain80/centabit_v0.5/issues) or check our [Contributing Guide](/contributing/).
