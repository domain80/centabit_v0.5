# Adding Features

Step-by-step guide for adding new features to Centabit.

## Overview

Centabit follows MVVM architecture with a feature-first organization. This guide walks you through adding a complete feature.

## Steps

### 1. Define the Data Model

Create a Freezed model in `lib/data/models/`:

```dart
@freezed
class YourModel with _$YourModel {
  const factory YourModel({
    required String id,
    required String name,
    required DateTime createdAt,
  }) = _YourModel;

  factory YourModel.fromJson(Map<String, dynamic> json) =>
      _$YourModelFromJson(json);
}
```

### 2. Add Database Table

Update `lib/data/local/database.dart`:

```dart
class YourTable extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
```

Run code generation:
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. Create LocalSource

Create `lib/data/local/your_local_source.dart`:

```dart
class YourLocalSource {
  final AppDatabase _db;
  final String userId;

  YourLocalSource(this._db, this.userId);

  Stream<List<YourTableData>> watchAll() {
    return (_db.select(_db.yourTable)
          ..where((t) => t.userId.equals(userId)))
        .watch();
  }

  Future<void> create(YourModel model) async {
    await _db.into(_db.yourTable).insert(/* ... */);
  }
}
```

### 4. Create Repository

Create `lib/data/repositories/your_repository.dart`:

```dart
class YourRepository with RepositoryLogger {
  final YourLocalSource _localSource;
  final _controller = StreamController<List<YourModel>>.broadcast();

  YourRepository(this._localSource) {
    _localSource.watchAll().listen((data) {
      final models = data.map(_toModel).toList();
      _controller.add(models);
    });
  }

  Stream<List<YourModel>> get stream => _controller.stream;

  Future<void> create(YourModel model) => trackRepositoryOperation(
        operation: 'create',
        execute: () => _localSource.create(model),
      );
}
```

### 5. Define Cubit State

Create `lib/features/your_feature/presentation/cubits/your_state.dart`:

```dart
@freezed
class YourState with _$YourState {
  const factory YourState.initial() = _Initial;
  const factory YourState.loading() = _Loading;
  const factory YourState.success(List<YourModel> items) = _Success;
  const factory YourState.error(String message) = _Error;
}
```

### 6. Create Cubit

Create `lib/features/your_feature/presentation/cubits/your_cubit.dart`:

```dart
class YourCubit extends Cubit<YourState> {
  final YourRepository _repository;
  StreamSubscription? _subscription;

  YourCubit(this._repository) : super(const YourState.initial()) {
    _subscription = _repository.stream.listen((_) => _load());
    _load();
  }

  Future<void> _load() async {
    emit(const YourState.loading());
    try {
      final items = await _repository.getAll();
      emit(YourState.success(items));
    } catch (e) {
      emit(YourState.error(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
```

### 7. Register in DI

Update `lib/core/di/injection.dart`:

```dart
// Repository (singleton)
getIt.registerLazySingleton<YourRepository>(
  () => YourRepository(getIt()),
);

// Cubit (factory)
getIt.registerFactory<YourCubit>(
  () => YourCubit(getIt()),
);
```

### 8. Create UI

Create `lib/features/your_feature/presentation/pages/your_page.dart`:

```dart
class YourPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<YourCubit>(),
      child: BlocBuilder<YourCubit, YourState>(
        builder: (context, state) => state.when(
          initial: () => const SizedBox.shrink(),
          loading: () => const CircularProgressIndicator(),
          success: (items) => YourListView(items: items),
          error: (msg) => Text('Error: $msg'),
        ),
      ),
    );
  }
}
```

### 9. Add Route

Update `lib/core/router/app_router.dart`:

```dart
GoRoute(
  path: '/your-feature',
  builder: (context, state) => const YourPage(),
),
```

### 10. Run Code Generation

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## Next Steps

- [Patterns & Conventions](./patterns-and-conventions.html)
- [API Reference](/api-reference/)
