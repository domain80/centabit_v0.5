# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Centabit v0.5 is a Flutter budgeting application with comprehensive budget tracking, transaction management, and financial analytics. The app features:
- **Budget Reports**: BAR (Budget Available Ratio) metrics with interactive charts
- **Transaction Management**: Date-filtered transaction lists with search
- **Category-based Budgeting**: Allocations across multiple spending categories
- **Material 3 Design**: Custom theme with glassmorphic navigation and animations

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

### Code Generation (Freezed & JSON)
```bash
# Generate code for @freezed models and JSON serialization
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate on file changes)
flutter pub run build_runner watch --delete-conflicting-outputs

# Clean generated files
flutter pub run build_runner clean
```

**Important**: Run build_runner after creating or modifying:
- `@freezed` classes (models, states)
- `@JsonSerializable` classes
- Files ending in `.freezed.dart` or `.g.dart` are auto-generated - never edit them manually

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
├── data/                        # Data layer
│   ├── models/                  # Domain models (business entities)
│   ├── repositories/            # Repository implementations
│   └── services/                # Data services
│       ├── local/               # Local data sources (SharedPreferences, SQLite)
│       │   └── dtos/            # Local data transfer objects
│       └── remote/              # Remote data sources (APIs)
│           └── dtos/            # Remote data transfer objects
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

## Architecture Notes

### MVVM Architecture

The application follows the **Model-View-ViewModel (MVVM)** pattern as recommended by the Flutter team:

**Model (Data Layer)**
- Located in `lib/data/`
- Contains domain models, repositories (when needed), and data services
- Handles data operations (API calls, local storage)
- DTOs (Data Transfer Objects) for API and local storage communication
- **Important**: Repositories are optional - only create them when:
  - You need to combine multiple services (e.g., sync local + remote data)
  - You need to cache or transform data from multiple sources
  - You have complex data orchestration logic
- For simple cases, Cubits can call services directly
- Models and DTOs can be the same class when there's no transformation needed

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
- Can interact with repositories OR services directly (depending on complexity)
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
   - ViewModels depend on Repositories OR Services (use what makes sense)
   - Repositories depend on Services (only when needed)
   - Inner layers don't know about outer layers

4. **Immutability**: Use immutable state classes for Cubit states

5. **Single Source of Truth**: Each piece of state has one authoritative source

6. **Pragmatic Layering**: Don't add layers that don't provide value
   - Skip repositories if they would just pass through to services
   - Skip domain layer if business logic fits cleanly in Cubits
   - Models and DTOs can be the same when no transformation is needed

### State Management

- **Package**: `flutter_bloc` (Cubit pattern)
- **Location**: `lib/features/[feature]/presentation/cubits/`
- **Pattern**: Stream-based reactive cubits that subscribe to service changes
- **State Classes**: Use `@freezed` with union types (initial, loading, success, error)
- **Dependency Injection**: `get_it` service locator (configured in `lib/core/di/injection.dart`)

**Key Pattern - Reactive Cubits with Stream Subscriptions**:

This app uses a stream-based reactive pattern where cubits subscribe to service streams and automatically reload data when services emit changes:

```dart
class DashboardCubit extends Cubit<DashboardState> {
  final BudgetService _budgetService;
  final TransactionService _transactionService;

  StreamSubscription? _budgetSubscription;
  StreamSubscription? _transactionSubscription;

  DashboardCubit(this._budgetService, this._transactionService)
      : super(const DashboardState.initial()) {
    // Subscribe to service streams for reactive updates
    _budgetSubscription = _budgetService.budgetsStream.listen((_) => _loadData());
    _transactionSubscription = _transactionService.transactionsStream.listen((_) => _loadData());
    _loadData(); // Initial load
  }

  Future<void> _loadData() async {
    emit(const DashboardState.loading());
    try {
      final budgets = _budgetService.getActiveBudgets();
      final transactions = _transactionService.transactions;
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
- **Services**: `registerLazySingleton` (single instance, created on first access)
- **Cubits**: `registerFactory` (new instance per request)

```dart
// Services (singletons with broadcast streams)
getIt.registerLazySingleton<BudgetService>(() => BudgetService());
getIt.registerLazySingleton<TransactionService>(() => TransactionService(getIt()));

// Cubits (factories - new instance per widget)
getIt.registerFactory<DashboardCubit>(() => DashboardCubit(
  getIt<BudgetService>(),
  getIt<TransactionService>(),
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
- `/transactions` - Transactions list (authenticated, nav index 1, search-enabled)
- `/budgets` - Budget management (authenticated, nav index 2)

**Navigation Features**:
- **StatefulShellRoute**: Maintains state across tab switches with indexed stack
- **Swipe Navigation**: Horizontal swipes between tabs (300px velocity threshold)
- **Auto-Hide Nav Bar**: Hides on scroll down, shows on scroll up (using `NavScrollWrapper`)
- **Search Mode**: Animated search bar that scales up from minimized state (300ms transitions)
- **Searchable Tabs**: Transaction page has integrated search capability

**Key Files**:
- `app_router.dart` - Route definitions with StatefulShellRoute
- `nav_cubit.dart` - Navigation state (selected tab, search mode, nav visibility)
- `app_nav_shell.dart` - Main shell with swipe handling and animated nav bar
- `searchable_nav_container.dart` - Dual-state nav (normal vs search mode)
- `nav_scroll_behavior.dart` - Scroll detection for auto-hide behavior

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

### Data Flow

**Simple Flow (no repository)**:
1. **User Interaction** → View captures input
2. **View** → Calls ViewModel (Cubit) method
3. **ViewModel** → Calls Service directly
4. **Service** → Returns data/DTO or error
5. **ViewModel** → Transforms DTO to Model (if needed) and emits new state
6. **View** → Rebuilds with new state

**Complex Flow (with repository)**:
1. **User Interaction** → View captures input
2. **View** → Calls ViewModel (Cubit) method
3. **ViewModel** → Calls Repository method
4. **Repository** → Coordinates multiple Services (local + remote, caching, etc.)
5. **Services** → Return data/DTOs or errors
6. **Repository** → Transforms DTOs to Models, handles caching/merging
7. **ViewModel** → Emits new state
8. **View** → Rebuilds with new state

### When to Use Repositories vs Direct Service Calls

**Use Repository when**:
- Combining local and remote data sources (offline-first, sync)
- Implementing caching strategy
- Complex data transformation from multiple DTOs to domain model
- Need to coordinate multiple services for a single operation
- Example: `TransactionRepository` syncs remote API + local SQLite

**Call Service Directly when**:
- Simple CRUD operations to a single data source
- No caching or coordination needed
- DTO and Model are the same (or minimal transformation)
- Example: `AuthService.login()` just calls API and returns user

### Models vs DTOs

**Use Same Class (Model = DTO) when**:
- API response structure matches your domain needs
- No complex transformation required
- Simple data structures
- Example: `UserModel` can be used for both API and domain if fields align

**Use Separate Classes when**:
- API structure differs significantly from domain model
- Need to combine multiple API responses into one model
- Converting between different data representations
- Example: API returns `user_name` but domain uses `username`

### Data Services Pattern

All services follow a consistent broadcast stream pattern for reactive updates:

```dart
class BudgetService {
  final List<BudgetModel> _budgets = [];
  final _budgetsController = StreamController<List<BudgetModel>>.broadcast();

  Stream<List<BudgetModel>> get budgetsStream => _budgetsController.stream;
  List<BudgetModel> get budgets => List.unmodifiable(_budgets);

  BudgetService() {
    _initializeDefaults(); // Load sample data
  }

  Future<void> createBudget(BudgetModel budget) async {
    _budgets.add(budget);
    _budgetsController.add(_budgets); // Emit change
  }

  List<BudgetModel> getActiveBudgets() {
    final now = DateTime.now();
    return _budgets.where((b) =>
      now.isAfter(b.startDate) && now.isBefore(b.endDate)
    ).toList();
  }
}
```

**Service Dependencies**: Services can depend on other services (constructor injection)
```dart
class TransactionService {
  final CategoryService _categoryService;
  TransactionService(this._categoryService) { /* ... */ }
}
```

**Current Services**:
- `CategoryService` - Spending categories (no dependencies)
- `BudgetService` - Budget periods (no dependencies)
- `TransactionService` - Transactions (depends on CategoryService)
- `AllocationService` - Budget allocations (depends on Category + Budget)

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
- **Services**: `[service_name]_service.dart` (e.g., `budget_service.dart`)
- **View Models** (non-freezed): `[entity]_chart_data.dart` (e.g., `transactions_chart_data.dart`)

### Key App-Specific Concepts

**BAR (Budget Available Ratio)**:
- Financial metric comparing spending rate vs time progression
- Formula: `(daysRemaining / totalDays) / (budgetRemaining / totalBudget)`
- Displayed on dashboard with color-coded progress bar
- Values > 1.0 indicate overspending (shown in error color)
- Calculated in `DashboardCubit._calculateBAR()`

**Data Denormalization**:
- Transactions store only `categoryId`, not full category object
- Cubits denormalize data by joining service data into view models
- Pattern: `TransactionVModel` includes full category data for display
- Benefit: Services stay simple, UI gets rich data

**Budget Allocations**:
- Each budget has multiple allocations (one per category)
- Tracks planned spending per category
- Compared against actual transactions in charts
- Managed by `AllocationService` with Category + Budget dependencies

