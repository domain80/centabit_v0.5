# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter mobile/web/desktop application called "centabit" (v0.5). It's currently a minimal Flutter project with a basic "Hello World" implementation.

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
- **Pattern**: Each feature has its own Cubit(s) for state management
- **State Classes**: Define clear state classes (initial, loading, success, error)
- **Dependency Injection**: Use `get_it` for service location and dependency injection

**Example Cubit Structures**:

Simple case - Cubit calls service directly (no repository needed):
```dart
// lib/features/auth/presentation/cubits/login_cubit.dart
class LoginCubit extends Cubit<LoginState> {
  final AuthService _authService;  // Direct service injection

  LoginCubit(this._authService) : super(LoginInitial());

  Future<void> login(String email, String password) async {
    emit(LoginLoading());
    try {
      final user = await _authService.login(email, password);
      emit(LoginSuccess(user));
    } catch (e) {
      emit(LoginError(e.toString()));
    }
  }
}
```

Complex case - Cubit uses repository (when coordinating multiple services):
```dart
// lib/features/transactions/presentation/cubits/sync_cubit.dart
class SyncCubit extends Cubit<SyncState> {
  final TransactionRepository _repository;  // Repository coordinates services

  SyncCubit(this._repository) : super(SyncInitial());

  Future<void> syncTransactions() async {
    emit(SyncLoading());
    try {
      // Repository handles: fetch remote, compare local, merge, save
      await _repository.syncWithRemote();
      emit(SyncSuccess());
    } catch (e) {
      emit(SyncError(e.toString()));
    }
  }
}
```

### Routing/Navigation

- **Package**: `go_router`
- **Location**: `lib/core/router/`
- **Features**:
  - Declarative routing
  - Deep linking support
  - Type-safe navigation
  - Nested navigation support
  - Guard routes for authentication

**Router Configuration**:
```dart
// lib/core/router/app_router.dart
final goRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const DashboardPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    // ... other routes
  ],
);
```

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

### File Naming Conventions

- **Pages**: `[feature_name]_page.dart` (e.g., `login_page.dart`)
- **Widgets**: `[widget_name]_widget.dart` (e.g., `transaction_card_widget.dart`)
- **Cubits**: `[feature_name]_cubit.dart` (e.g., `login_cubit.dart`)
- **States**: `[feature_name]_state.dart` (e.g., `login_state.dart`)
- **Models**: `[model_name]_model.dart` (e.g., `user_model.dart`)
- **Repositories**: `[domain]_repository.dart` (e.g., `auth_repository.dart`)
- **Services**: `[service_name]_service.dart` (e.g., `api_service.dart`)
- **DTOs**: `[entity_name]_dto.dart` (e.g., `user_dto.dart`)

