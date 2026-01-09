# Patterns and Conventions

Code patterns and naming conventions used in Centabit.

## File Naming

- **Pages**: `feature_name_page.dart`
- **Widgets**: `widget_name.dart`
- **Cubits**: `feature_name_cubit.dart`
- **States**: `feature_name_state.dart`
- **Models**: `model_name_model.dart`
- **Repositories**: `entity_name_repository.dart`
- **LocalSources**: `entity_name_local_source.dart`

## Critical Patterns

### userId Filtering

**All database queries MUST filter by userId**:

```dart
Stream<List<Transaction>> watchAll() {
  return (_db.select(_db.transactions)
        ..where((t) => t.userId.equals(userId))) // REQUIRED
      .watch();
}
```

### Stream Subscription Management

**Always cancel subscriptions in cubit close()**:

```dart
@override
Future<void> close() {
  _subscription?.cancel();
  return super.close();
}
```

### Cubit State Pattern

Use Freezed union types:

```dart
@freezed
class MyState with _$MyState {
  const factory MyState.initial() = _Initial;
  const factory MyState.loading() = _Loading;
  const factory MyState.success(Data data) = _Success;
  const factory MyState.error(String message) = _Error;
}
```

### Repository Pattern

```dart
class MyRepository with RepositoryLogger {
  final MyLocalSource _localSource;
  final _controller = StreamController<List<Model>>.broadcast();

  MyRepository(this._localSource) {
    _localSource.watchAll().listen((data) {
      _controller.add(data.map(_toModel).toList());
    });
  }

  Stream<List<Model>> get stream => _controller.stream;
}
```

### Dependency Injection

```dart
// Repositories: singletons
getIt.registerLazySingleton<MyRepository>(
  () => MyRepository(getIt()),
);

// Cubits: factories
getIt.registerFactory<MyCubit>(
  () => MyCubit(getIt()),
);
```

## Best Practices

1. **Use repositories** - Never call LocalSources from Cubits
2. **Filter by userId** - Every query must include userId check
3. **Dispose resources** - Cancel subscriptions, dispose controllers
4. **Use Freezed** - All models and states
5. **Log operations** - Use RepositoryLogger mixin
6. **Validate input** - Check for null, validate formats
7. **Handle errors** - Try-catch with meaningful messages

## Code Style

- Use `flutter format .` before committing
- Follow `flutter_lints` rules
- Write descriptive variable names
- Add comments for complex logic only
- Keep functions small (< 50 lines)

## Next Steps

- [Adding Features](./adding-features.html)
- [Database Schema](./database-schema.html)
