# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Centabit v0.5 is a Flutter budgeting application with comprehensive budget tracking, transaction management, and financial analytics. The app features:
- **Budget Reports**: BAR (Budget Adherence Ratio) metrics with interactive charts
- **Transaction Management**: Date-filtered transaction lists with search
- **Category-based Budgeting**: Allocations across multiple spending categories
- **Material 3 Design**: Custom theme with glassmorphic navigation and animations
- **Local-First Architecture**: Offline-first with Drift/SQLite database and isolate-based sync
- **Multi-User Ready**: userId filtering on all queries for future OAuth integration

## Development Commands

### Run the Application
```bash
# Run on connected device/emulator
flutter run

# Run in release mode
flutter run --release

# Run on specific platform
flutter run -d chrome        # Web
flutter run -d macos          # macOS
flutter run -d windows        # Windows
flutter run -d linux          # Linux
```

### Code Generation (Freezed, JSON, Drift)
```bash
# Generate code for @freezed models, JSON serialization, and Drift database
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate on file changes)
flutter pub run build_runner watch --delete-conflicting-outputs

# Clean generated files
flutter pub run build_runner clean
```

**Important**: Run build_runner after creating or modifying:
- `@freezed` classes (models, states)
- `@JsonSerializable` classes
- Drift database schema (`lib/data/local/database.dart`)
- Files ending in `.freezed.dart`, `.g.dart` are auto-generated - never edit them manually

### Testing
No tests are currently configured in this project. To add tests:
- Create `test/` directory with test files
- Run tests: `flutter test`
- Run specific test: `flutter test test/path/to/test_file.dart`

### Code Quality
```bash
# Analyze code
flutter analyze

# Format code
flutter format .

# Format specific file
flutter format lib/main.dart
```

### Build
```bash
# Build for Android
flutter build apk
flutter build appbundle

# Build for iOS
flutter build ios

# Build for Web
flutter build web

# Build for Desktop
flutter build macos
flutter build windows
flutter build linux
```

### Dependencies
```bash
# Install dependencies
flutter pub get

# Upgrade dependencies
flutter pub upgrade

# Check for outdated packages
flutter pub outdated
```

## Project Structure

The application follows the MVVM (Model-View-ViewModel) architecture as recommended by the Flutter team, with a feature-first organization pattern.

```
lib/
├── main.dart                    # Application entry point
├── core/                        # Shared core functionality
│   ├── theme/                   # Theme configuration (Material 3)
│   │   ├── app_theme.dart      # Main theme orchestrator
│   │   ├── color_schemes.dart  # Light/dark color schemes
│   │   ├── text_theme.dart     # Typography configuration
│   │   ├── theme_extensions.dart  # Custom colors, spacing, radius
│   │   └── component_themes/   # Individual component themes
│   │       ├── button_theme.dart
│   │       ├── input_decoration_theme.dart
│   │       ├── card_theme.dart
│   │       └── app_bar_theme.dart
│   ├── widgets/                 # Reusable UI components
│   ├── utils/                   # Helper functions and constants
│   └── router/                  # Go Router configuration
│
├── data/                        # Data layer (v5 local-first architecture)
│   ├── models/                  # Domain models (business entities)
│   ├── local/                   # Local data sources (Drift/SQLite)
│   │   ├── database.dart        # Drift database schema with userId filtering
│   │   ├── database.g.dart      # Generated Drift code (DO NOT EDIT)
│   │   ├── transaction_local_source.dart
│   │   ├── category_local_source.dart
│   │   ├── budget_local_source.dart
│   │   └── allocation_local_source.dart
│   ├── repositories/            # Repository layer (coordinates local + future remote)
│   │   ├── transaction_repository.dart
│   │   ├── category_repository.dart
│   │   ├── budget_repository.dart
│   │   └── allocation_repository.dart
│   └── sync/                    # Sync management (isolate-based)
│       ├── sync_manager.dart    # Background sync orchestrator
│       └── sync_status.dart     # Sync status state (freezed)
│
└── features/                    # Feature modules (feature-first organization)
    ├── auth/                    # Authentication feature
    │   └── presentation/        # UI layer
    │       ├── pages/           # Full screens
    │       ├── widgets/         # Feature-specific widgets
    │       └── cubits/          # State management (Cubit/Bloc)
    │
    ├── dashboard/               # Dashboard feature
    │   └── presentation/
    │       ├── pages/
    │       ├── widgets/
    │       └── cubits/
    │
    ├── budgets/                 # Budget management feature
    │   ├── presentation/
    │   │   ├── pages/
    │   │   ├── widgets/
    │   │   └── cubits/
    │   └── domain/              # OPTIONAL: Complex budget calculation logic
    │       └── use_cases/
    │
    ├── transactions/            # Transaction tracking feature
    │   └── presentation/
    │       ├── pages/
    │       ├── widgets/
    │       └── cubits/
    │
    └── categories/              # Category management feature
        └── presentation/
            ├── pages/
            ├── widgets/
            └── cubits/
```

## Code Configuration

- **SDK Version**: Dart SDK ^3.10.4
- **Linting**: Uses `flutter_lints ^6.0.0` with default Flutter linter rules
- **Platforms**: Supports Android, iOS, Web, macOS, Windows, Linux
- **Theme**: Material 3 design system with custom light/dark themes
- **Key Dependencies**:
  - `flutter_bloc` - State management
  - `drift` - Type-safe SQLite database
  - `freezed` - Immutable data classes
  - `get_it` - Dependency injection
  - `go_router` - Declarative routing
  - `fl_chart` - Chart visualizations
  - `talker_flutter` - Logging

## Common Development Workflows

### Adding a New Feature

1. **Create feature directory** in `lib/features/[feature_name]/`
2. **Define data models** in `lib/data/models/` using `@freezed`
3. **Add database table** in `lib/data/local/database.dart` (run build_runner after)
4. **Create LocalSource** in `lib/data/local/[entity]_local_source.dart` with userId filtering
5. **Create Repository** in `lib/data/repositories/[entity]_repository.dart` with broadcast streams
6. **Define state** in `lib/features/[feature]/presentation/cubits/[feature]_state.dart` using `@freezed`
7. **Create cubit** in `lib/features/[feature]/presentation/cubits/[feature]_cubit.dart`
8. **Register in DI** in `lib/core/di/injection.dart` (repositories as singletons, cubits as factories)
9. **Build UI** in `lib/features/[feature]/presentation/pages/` and `widgets/`
10. **Add routes** in `lib/core/router/app_router.dart`
11. **Run code generation**: `flutter pub run build_runner build --delete-conflicting-outputs`

### Modifying Database Schema

1. Update table definition in `lib/data/local/database.dart`
2. Run: `flutter pub run build_runner build --delete-conflicting-outputs`
3. Update corresponding LocalSource queries if needed
4. Test with hot restart (not hot reload - database changes require full restart)

### Adding Modal Forms

Pattern used in BudgetFormModal, TransactionFormModal:
- Use `showModalBottomSheetUtil()` helper
- Provide BlocProvider scoped to modal lifecycle
- Use FormBuilder for form state
- BlocListener for navigation (close on success) and error display
- Separate content widget for cleaner code organization

## Architecture Notes

### V5 Local-First Architecture (Current)

The app uses a **local-first repository pattern** with offline capabilities and background sync:

```
Presentation (Cubits)
    ↓ (stream subscriptions)
Repositories (coordinate local + future remote)
    ↓
LocalSources (userId-filtered Drift queries)
    ↓
Drift Database (SQLite)
    ↓
SyncManager (isolate-based background sync)
```

**Key Components**:

1. **Drift Database** (`lib/data/local/database.dart`):
   - Type-safe SQLite with reactive queries
   - All tables have `userId` column for multi-user support
   - Sync metadata: `isSynced`, `isDeleted`, `lastSyncedAt`
   - Soft delete pattern (marks as deleted, doesn't remove)

2. **LocalSources** (`lib/data/local/*_local_source.dart`):
   - userId-filtered data access (security + multi-user)
   - Reactive streams via Drift's `watch()` API
   - CRUD operations with automatic userId injection
   - Pattern: All queries filter by `userId.equals(userId)`

3. **Repositories** (`lib/data/repositories/*_repository.dart`):
   - Broadcast streams (like v0.5 services)
   - Transform Drift entities ↔ Domain models
   - Coordinate local (and future remote) sources
   - Sync stubs ready for API integration
   - Synchronous getters for immediate access
   - Logging mixin for operation tracking and debugging

4. **SyncManager** (`lib/data/sync/sync_manager.dart`):
   - Isolate-based background sync (non-blocking)
   - Periodic sync timer (default: 5 minutes)
   - SendPort/ReceivePort communication pattern
   - Status streaming (idle, syncing, synced, failed, offline)

5. **AuthManager** (`lib/core/auth/auth_manager.dart`):
   - Anonymous token: `anon_{uuid}`
   - Persisted in SharedPreferences
   - Future OAuth preparation (Google Sign-In)
   - Used to filter all database queries

**Data Flow (Repository Pattern)**:
```
User Action
  ↓
Cubit calls Repository method
  ↓
Repository calls LocalSource (with userId)
  ↓
LocalSource executes Drift query (userId filtered)
  ↓
Drift emits change via watch() stream
  ↓
Repository receives update, transforms to domain models
  ↓
Repository emits to broadcast stream
  ↓
Cubit's stream subscription triggers reload
  ↓
UI updates
```

**Critical Pattern - userId Filtering**:
Every database query MUST filter by userId for security and multi-user support:

```dart
// LocalSource example
Future<List<Transaction>> watchAllTransactions() {
  return (_db.select(_db.transactions)
        ..where((t) =>
            t.userId.equals(userId) &  // CRITICAL: Always filter by userId
            t.isDeleted.equals(false))
        ..orderBy([(t) => OrderingTerm.desc(t.transactionDate)]))
      .watch();
}
```

**Sync Stubs (Ready for API)**:
All repositories have TODO comments for future API integration:
```dart
Future<void> createTransaction(TransactionModel model) async {
  await _localSource.createTransaction(/* ... */);
  // TODO: When API is ready, trigger background sync in isolate
}
```

### MVVM Architecture

The application follows the **Model-View-ViewModel (MVVM)** pattern as recommended by the Flutter team:

**Model (Data Layer)**
- Located in `lib/data/`
- **V5 uses repositories** for all data access (local-first pattern)
- Repositories coordinate LocalSources (Drift) and future RemoteSources (API)
- Domain models are separate from Drift entities (transformation happens in repositories)
- All data access must go through repositories (cubits never call LocalSources directly)

**View (Presentation Layer)**
- Located in `lib/features/[feature]/presentation/pages/` and `widgets/`
- Pure UI widgets that display data and capture user input
- Should be as "dumb" as possible - no business logic
- Responds to state changes from ViewModels (Cubits)
- Uses `BlocBuilder`, `BlocListener`, and `BlocConsumer` to react to state

**ViewModel (State Management)**
- Located in `lib/features/[feature]/presentation/cubits/`
- Implemented using **Cubit** from the `bloc` package
- Manages UI state and business logic for views
- **Always uses repositories** (never accesses LocalSources directly)
- Subscribes to repository streams for reactive updates
- Emits states that views listen to
- Contains presentation logic (validation, formatting, etc.)

### Key Architectural Principles

1. **Feature-First Organization**: Code is organized by feature (auth, dashboard, budgets) rather than layer (views, models, controllers)

2. **Separation of Concerns**: Each layer has a single responsibility:
   - Data layer handles data operations
   - Domain layer contains business logic (optional, can be in Cubits for simpler apps)
   - Presentation layer handles UI and user interaction

3. **Dependency Rule**: Dependencies flow inward:
   - Views depend on ViewModels (Cubits)
   - ViewModels (Cubits) depend on Repositories
   - Repositories depend on LocalSources (and future RemoteSources)
   - LocalSources depend on Drift Database
   - Inner layers don't know about outer layers

4. **Immutability**: Use immutable state classes for Cubit states

5. **Single Source of Truth**: Each piece of state has one authoritative source

6. **Offline-First**: Local database is the single source of truth
   - All writes go to local database first (optimistic updates)
   - Background sync to API happens asynchronously in isolates
   - App works fully offline, syncs when online

### State Management

- **Package**: `flutter_bloc` (Cubit pattern)
- **Location**: `lib/features/[feature]/presentation/cubits/`
- **Pattern**: Stream-based reactive cubits that subscribe to repository streams
- **State Classes**: Use `@freezed` with union types (initial, loading, success, error)
- **Dependency Injection**: `get_it` service locator (configured in `lib/core/di/injection.dart`)

**Key Pattern - Reactive Cubits with Stream Subscriptions**:

This app uses a stream-based reactive pattern where cubits subscribe to repository streams and automatically reload data when repositories emit changes:

```dart
class DashboardCubit extends Cubit<DashboardState> {
  final BudgetRepository _budgetRepository;
  final TransactionRepository _transactionRepository;

  StreamSubscription? _budgetSubscription;
  StreamSubscription? _transactionSubscription;

  DashboardCubit(this._budgetRepository, this._transactionRepository)
      : super(const DashboardState.initial()) {
    // Subscribe to repository streams for reactive updates
    _budgetSubscription = _budgetRepository.budgetsStream.listen((_) => _loadData());
    _transactionSubscription = _transactionRepository.transactionsStream.listen((_) => _loadData());
    _loadData(); // Initial load
  }

  Future<void> _loadData() async {
    emit(const DashboardState.loading());
    try {
      final budgets = _budgetRepository.getActiveBudgets();
      final transactions = _transactionRepository.transactions;
      // ... build view models, calculate metrics
      emit(DashboardState.success(data));
    } catch (e) {
      emit(DashboardState.error(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _budgetSubscription?.cancel();
    _transactionSubscription?.cancel();
    return super.close();
  }
}
```

**Cubit Registration** (`lib/core/di/injection.dart`):
- **Repositories**: `registerLazySingleton` (single instance, created on first access)
- **Cubits**: `registerFactory` (new instance per request)

```dart
// Repositories (singletons with broadcast streams)
getIt.registerLazySingleton<BudgetRepository>(() => BudgetRepository(getIt()));
getIt.registerLazySingleton<TransactionRepository>(() => TransactionRepository(getIt()));

// Cubits (factories - new instance per widget)
getIt.registerFactory<DashboardCubit>(() => DashboardCubit(
  getIt<BudgetRepository>(),
  getIt<TransactionRepository>(),
));
```

**Usage in Widgets**:
```dart
BlocProvider(
  create: (_) => getIt<DashboardCubit>(),
  child: BlocBuilder<DashboardCubit, DashboardState>(
    builder: (context, state) => state.when(
      initial: () => const SizedBox.shrink(),
      loading: () => const CircularProgressIndicator(),
      success: (data) => YourWidget(data: data),
      error: (msg) => Text('Error: $msg'),
    ),
  ),
)
```

### Routing/Navigation

- **Package**: `go_router`
- **Location**: `lib/core/router/`
- **Pattern**: StatefulShellRoute with bottom navigation
- **Navigation State**: Managed by `NavCubit` (handles tab selection, search mode, nav bar visibility)

**Current Routes** (`AppRouter`):
- `/login` - Login page (unauthenticated)
- `/` - Dashboard (authenticated, nav index 0)
  - `/monthly-overview` - Monthly spending detail page (sub-route)
- `/transactions` - Transactions list (authenticated, nav index 1, search-enabled)
- `/budgets` - Budget management (authenticated, nav index 2)
  - `/budgets/:id` - Budget detail page with allocations and charts

**Navigation Features**:
- **StatefulShellRoute**: Maintains state across tab switches with indexed stack
- **Swipe Navigation**: Horizontal swipes between tabs (300px velocity threshold)
- **Auto-Hide Nav Bar**: Hides on scroll down, shows on scroll up (using `NavScrollWrapper`)
- **Search Mode**: Animated search bar that scales up from minimized state (300ms transitions)
- **Searchable Tabs**: Transaction page has integrated search capability
- **Filter Action Widgets**: Pages can register custom widgets (icons, date pickers, etc.) in the search bar

**Key Files**:
- `app_router.dart` - Route definitions with StatefulShellRoute
- `nav_cubit.dart` - Navigation state (selected tab, search mode, nav visibility, filter actions)
- `app_nav_shell.dart` - Main shell with swipe handling and animated nav bar
- `searchable_nav_container.dart` - Dual-state nav (normal vs search mode)
- `nav_scroll_behavior.dart` - Scroll detection for auto-hide behavior

**Filter Action Widget Pattern**:

Pages can register custom filter widgets in the navigation search bar using the NavCubit event bus pattern:

```dart
// In page initState - register filter widget
WidgetsBinding.instance.addPostFrameCallback((_) {
  if (mounted) {
    context.read<NavCubit>().setFilterAction(
      CustomDatePickerIcon(
        currentDate: DateTime.now(),
        onDateChanged: (date) {
          context.read<TransactionListCubit>().setSelectedDate(date);
        },
      ),
    );
  }
});

// In page dispose - clean up filter widget
@override
void dispose() {
  context.read<NavCubit>().setFilterAction(null);
  super.dispose();
}
```

**How it works**:
1. NavCubit stores a `filterActionWidget` in its state
2. Pages register widgets via `setFilterAction(Widget?)`
3. NavSearchBar conditionally renders the widget from NavCubit state
4. Widgets handle their own interactions (modals, callbacks, etc.)
5. Auto-cleanup: Filter widgets cleared on tab switch or page disposal

This pattern maintains clean separation between shell layer (NavSearchBar) and page layer (feature pages) while allowing flexible UI customization.

### Theme System

- **Design System**: Material 3
- **Location**: `lib/core/theme/`
- **Features**:
  - Light and dark mode support
  - Custom color extensions for gradients and semantic colors
  - Consistent spacing and border radius tokens
  - Rounded pill-shaped buttons (28px radius)
  - Comprehensive component theming

**Theme Access**:
```dart
// Access standard theme
final theme = Theme.of(context);
final colorScheme = theme.colorScheme;

// Access custom extensions
final customColors = theme.extension<AppCustomColors>()!;
final spacing = theme.extension<AppSpacing>()!;
final radius = theme.extension<AppRadius>()!;

// Use gradient colors
Container(
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [customColors.gradientStart, customColors.gradientEnd],
    ),
  ),
)
```

### Repository Pattern (V5)

All data access goes through repositories with broadcast streams for reactive updates:

```dart
class TransactionRepository {
  final TransactionLocalSource _localSource;
  final _transactionsController = StreamController<List<TransactionModel>>.broadcast();

  StreamSubscription? _dbSubscription;
  List<TransactionModel> _latestTransactions = [];

  TransactionRepository(this._localSource) {
    // Subscribe to Drift's reactive watch() streams
    _dbSubscription = _localSource.watchAllTransactions().listen((dbTransactions) {
      final models = dbTransactions.map(_mapToModel).toList();
      _latestTransactions = models;  // Cache for synchronous access
      _transactionsController.add(models);  // Emit to cubits
    });
  }

  // Public API for cubits
  Stream<List<TransactionModel>> get transactionsStream => _transactionsController.stream;
  List<TransactionModel> get transactions => _latestTransactions;

  Future<void> createTransaction(TransactionModel model) async {
    await _localSource.createTransaction(/* ... with userId */);
    // TODO: Trigger background sync in isolate when API ready
  }
}
```

**Current Repositories**:
- `TransactionRepository` - Transaction CRUD with userId filtering
- `CategoryRepository` - Category CRUD with userId filtering
- `BudgetRepository` - Budget CRUD with userId filtering
- `AllocationRepository` - Allocation CRUD with userId filtering

### Freezed Models

All data models and cubit states use `@freezed` for immutability:

```dart
@freezed
class BudgetModel with _$BudgetModel {
  const factory BudgetModel({
    required String id,
    required String name,
    required double amount,
    required DateTime startDate,
    required DateTime endDate,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _BudgetModel;

  // Factory constructor for creating new instances
  factory BudgetModel.create({
    required String name,
    required double amount,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    final now = DateTime.now();
    return BudgetModel(
      id: const Uuid().v4(),
      name: name,
      amount: amount,
      startDate: startDate,
      endDate: endDate,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory BudgetModel.fromJson(Map<String, dynamic> json) =>
      _$BudgetModelFromJson(json);
}
```

**State Union Types**:
```dart
@freezed
class DashboardState with _$DashboardState {
  const factory DashboardState.initial() = _Initial;
  const factory DashboardState.loading() = _Loading;
  const factory DashboardState.success({
    required List<BudgetPageModel> budgetPages,
  }) = _Success;
  const factory DashboardState.error(String message) = _Error;
}
```

### File Naming Conventions

- **Pages**: `[feature_name]_page.dart` (e.g., `login_page.dart`)
- **Widgets**: `[widget_name].dart` or `[widget_name]_widget.dart` (e.g., `transaction_tile.dart`)
- **Cubits**: `[feature_name]_cubit.dart` (e.g., `login_cubit.dart`)
- **States**: `[feature_name]_state.dart` (e.g., `login_state.dart`)
- **Models**: `[model_name]_model.dart` (e.g., `user_model.dart`)
- **Repositories**: `[entity_name]_repository.dart` (e.g., `transaction_repository.dart`)
- **LocalSources**: `[entity_name]_local_source.dart` (e.g., `transaction_local_source.dart`)
- **View Models** (non-freezed): `[entity]_chart_data.dart` (e.g., `transactions_chart_data.dart`)

### Logging Infrastructure

- **Package**: `talker_flutter` (comprehensive logging solution)
- **Location**: `lib/core/logging/`
- **Singleton**: `AppLogger.instance` for centralized logging
- **Features**:
  - Environment-aware log levels (verbose in debug, error in release)
  - In-app log viewer support (TalkerScreen)
  - Automatic BLoC event/state logging via observer
  - Repository operation tracking with metadata
  - No ANSI colors for cleaner Flutter console output

**Key Components**:

1. **AppLogger** (`lib/core/logging/app_logger.dart`):
   - Singleton wrapper around Talker
   - Methods: `verbose`, `debug`, `info`, `warning`, `error`, `critical`
   - Context logging: `logWithContext()` for structured metadata
   - History: Stores up to 1000 log entries

2. **CubitLogger** (`lib/core/logging/interceptors/cubit_logger.dart`):
   - BlocObserver implementation
   - Automatically logs all cubit events, state changes, errors
   - Integrated in `main.dart` via `Bloc.observer = CubitLogger()`

3. **RepositoryLogger** (`lib/core/logging/interceptors/repository_logger.dart`):
   - Mixin for repository operation tracking
   - Pattern: `trackRepositoryOperation(operation: 'createTransaction', execute: () async { ... })`
   - Logs operation start, success, duration, and errors with metadata

**Usage Patterns**:
```dart
// Basic logging
final logger = AppLogger.instance;
logger.info('User logged in');
logger.error('Failed to save', error: e, stackTrace: st);

// Structured context logging
logger.logWithContext(
  message: 'Transaction created',
  context: {'id': '123', 'amount': 50.00},
  level: LogLevel.info,
);

// Repository operation tracking (via mixin)
class TransactionRepository with RepositoryLogger {
  @override
  String get repositoryName => 'TransactionRepository';

  Future<void> createTransaction(TransactionModel model) async {
    return trackRepositoryOperation(
      operation: 'createTransaction',
      execute: () async { /* ... */ },
      metadata: {'transactionId': model.id},
    );
  }
}
```

### Critical Patterns for State Management

**Preventing setState-During-Build Errors**:

When cubit methods emit states that trigger UI rebuilds, use `scheduleMicrotask()` to defer emissions:

```dart
void updateAllocation(String id, String categoryId, double amount) {
  _allocations = _allocations.map((alloc) {
    if (alloc.id == id) {
      return AllocationEditModel(/* ... */);
    }
    return alloc;
  }).toList();

  // Defer state emission to avoid setState-during-build errors
  scheduleMicrotask(() {
    _rebuildCounter++;
    emit(BudgetFormState.initial(rebuildCounter: _rebuildCounter));
  });
}
```

**Critical**: This pattern is required when:
- Cubit methods are called from widget callbacks (onTap, onChange)
- Those callbacks might fire during widget build phase
- The state emission triggers BlocBuilder rebuilds

**Inline Form Editing Pattern**:

For inline editable fields (like AllocationTile amount editing):
- Use `StatefulWidget` with `TextEditingController`
- Implement debouncing (500ms) to prevent excessive cubit calls
- Use `didUpdateWidget` to sync controller with external changes
- Always dispose controller and cancel timers

```dart
class _AllocationTileState extends State<AllocationTile> {
  late TextEditingController _amountController;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.allocation.amount.toStringAsFixed(2),
    );
  }

  @override
  void didUpdateWidget(AllocationTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update if amount changed externally (prevents cursor jumping)
    if (widget.allocation.amount != oldWidget.allocation.amount &&
        _amountController.text != widget.allocation.amount.toStringAsFixed(2)) {
      _amountController.text = widget.allocation.amount.toStringAsFixed(2);
    }
  }

  void _handleAmountChange(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      final amount = double.tryParse(value);
      if (amount != null && amount >= 0) {
        widget.onAmountChanged(amount);
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _amountController.dispose();
    super.dispose();
  }
}
```

### Key App-Specific Concepts

**BAR (Budget Adherence Ratio)**:
- Financial metric comparing spending rate vs time progression
- Formula: `(daysRemaining / totalDays) / (budgetRemaining / totalBudget)`
- Displayed on dashboard with color-coded progress bar
- Values > 1.0 indicate overspending (shown in error color)
- Calculated in `DashboardCubit._calculateBAR()`

**Data Denormalization**:
- Transactions store only `categoryId` in database, not full category object
- Cubits denormalize data by joining repository data into view models
- Pattern: `TransactionVModel` includes full category data for display
- Benefit: Database stays normalized, UI gets rich data

**Budget Allocations**:
- Each budget has multiple allocations (one per category)
- Tracks planned spending per category
- Compared against actual transactions in charts
- Managed by `AllocationRepository` with userId filtering
- **Budget Deallocation**: Transactions can have `budgetId = null` to exclude from budget tracking
- Explicit deallocation is different from "no budget assigned" - it's intentional exclusion

**Transaction-Budget Relationship**:
- Transactions link to budgets via `budgetId` (nullable)
- `budgetId != null`: Transaction counts toward that budget's spending
- `budgetId == null`: Unassigned/deallocated transaction (not counted in any budget)
- Budget filtering uses strict `budgetId.equals(budgetId)` matching (no category fallback)
- Auto-select first active budget for new transactions for better UX

**Custom Date Pickers**:
- `CustomDatePicker` (text-based): Uses `CupertinoCalendarPickerButton` for text display with calendar picker
- `CustomDatePickerIcon` (icon-based): Uses `showCupertinoCalendarPicker()` function with custom IconButton
- Both widgets maintain same styling and date range constraints
- Icon-based version used in navigation filter actions for compact UI
- Text-based version used in content areas where date context is helpful
