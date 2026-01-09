# For Developers

Welcome to Centabit! This guide will help you get up and running with the development environment.

## Prerequisites

Before you begin, ensure you have the following installed:

### Required Software

- **Flutter SDK** (v3.10.0 or later)
  - [Installation Guide](https://docs.flutter.dev/get-started/install)
  - Verify installation: `flutter --version`

- **Dart SDK** (^3.10.4 or later)
  - Comes bundled with Flutter
  - Verify installation: `dart --version`

- **Git**
  - For version control
  - [Installation Guide](https://git-scm.com/downloads)

### Recommended IDE

Choose one of the following:

- **Visual Studio Code** with Flutter extension
  - [Download VS Code](https://code.visualstudio.com/)
  - Install Flutter extension from marketplace

- **Android Studio** with Flutter plugin
  - [Download Android Studio](https://developer.android.com/studio)
  - Install Flutter plugin

- **IntelliJ IDEA** with Flutter plugin
  - [Download IntelliJ IDEA](https://www.jetbrains.com/idea/)
  - Install Flutter plugin

### Platform-Specific Requirements

#### Android Development
- Android SDK (API level 21 or higher)
- Android Studio or Android SDK command-line tools
- Java Development Kit (JDK) 17 or later

#### iOS Development (macOS only)
- Xcode 14 or later
- CocoaPods
- iOS Simulator or physical iOS device

#### Web Development
- Chrome browser for debugging

#### Desktop Development
- **macOS**: Xcode command-line tools
- **Windows**: Visual Studio 2022 with C++ development tools
- **Linux**: Required libraries (see Flutter docs)

## Getting the Code

### 1. Fork the Repository

1. Visit [github.com/domain80/centabit_v0.5](https://github.com/domain80/centabit_v0.5)
2. Click the "Fork" button in the top right
3. This creates your own copy of the repository

### 2. Clone Your Fork

```bash
# Clone your forked repository
git clone https://github.com/YOUR_USERNAME/centabit_v0.5.git

# Navigate to the project directory
cd centabit_v0.5

# Add the original repository as upstream
git remote add upstream https://github.com/domain80/centabit_v0.5.git
```

### 3. Install Dependencies

```bash
# Get all Flutter dependencies
flutter pub get

# Verify everything is working
flutter doctor
```

The `flutter doctor` command will show you if there are any issues with your setup.

## Project Setup

### Code Generation

Centabit uses code generation for:
- **Freezed** - Immutable data classes
- **JSON Serialization** - Model serialization/deserialization
- **Drift** - Type-safe database queries

**Generate code after cloning**:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Important**: Run this command whenever you:
- Create or modify `@freezed` classes
- Add or change `@JsonSerializable` classes
- Update the Drift database schema
- Pull changes that affect generated files

**For active development**, use watch mode:

```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

This automatically regenerates files when you save changes.

## Running the Application

### On Connected Device/Emulator

```bash
# Run in debug mode
flutter run

# Run on specific device
flutter devices                    # List available devices
flutter run -d chrome              # Run on Chrome
flutter run -d macos               # Run on macOS
flutter run -d android             # Run on Android emulator/device
```

### Run Configurations

```bash
# Debug mode (default) - includes debug info, hot reload
flutter run

# Profile mode - performance profiling with some debugging
flutter run --profile

# Release mode - optimized, no debugging
flutter run --release
```

### Hot Reload

While the app is running:
- Press `r` to hot reload (keeps app state)
- Press `R` to hot restart (resets app state)
- Press `q` to quit

**Note**: Database schema changes require a full restart, not just hot reload.

## Development Workflow

### Branch Strategy

```bash
# Create a feature branch
git checkout -b feature/your-feature-name

# Create a bugfix branch
git checkout -b fix/bug-description
```

### Making Changes

1. **Make your changes** in the appropriate feature directory
2. **Run code generation** if you modified models or database schema
3. **Test your changes** manually (automated tests coming soon)
4. **Format your code**:

```bash
flutter format .
```

5. **Analyze code** for issues:

```bash
flutter analyze
```

### Commit Guidelines

Follow conventional commits format:

```bash
# Feature
git commit -m "feat(budgets): add budget deletion functionality"

# Bug fix
git commit -m "fix(transactions): correct date filtering logic"

# Documentation
git commit -m "docs(api): document BudgetRepository methods"

# Refactoring
git commit -m "refactor(dashboard): extract chart widgets"

# Chore (dependencies, config, etc.)
git commit -m "chore(deps): update freezed to v2.4.0"
```

## Project Structure Overview

```
lib/
├── main.dart                    # App entry point
├── core/                        # Shared functionality
│   ├── theme/                   # Material 3 theme
│   ├── router/                  # Go Router navigation
│   ├── widgets/                 # Reusable widgets
│   ├── di/                      # Dependency injection
│   └── logging/                 # Talker logging
│
├── data/                        # Data layer (V5 architecture)
│   ├── models/                  # Domain models (@freezed)
│   ├── local/                   # Drift/SQLite local data
│   ├── repositories/            # Data coordinators
│   └── sync/                    # Background sync (isolates)
│
└── features/                    # Feature modules
    ├── auth/                    # Authentication
    ├── dashboard/               # Dashboard + BAR metrics
    ├── budgets/                 # Budget management
    ├── transactions/            # Transaction tracking
    └── categories/              # Category management
```

Each feature follows MVVM pattern:
```
feature_name/
└── presentation/
    ├── pages/                   # Full screen views
    ├── widgets/                 # Feature-specific widgets
    └── cubits/                  # State management (BLoC/Cubit)
```

For detailed architecture information, see [Architecture Documentation](/architecture/).

## Common Development Tasks

### Adding a New Feature

See the [Adding Features Guide](/development/adding-features.html) for a step-by-step walkthrough.

### Modifying the Database

1. Update table definition in `lib/data/local/database.dart`
2. Run code generation:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
3. Update corresponding LocalSource queries
4. Fully restart the app (hot reload won't work for schema changes)

### Debugging

```bash
# Enable verbose logging
flutter run -v

# Debug on physical device
flutter run --debug

# Profile performance
flutter run --profile

# Analyze app size
flutter build apk --analyze-size
```

### Using Flutter DevTools

```bash
# Run the app in debug or profile mode
flutter run --profile

# Open DevTools (URL will be shown in console)
# Access tools: Inspector, Performance, Network, Logging
```

## Code Quality

### Linting

The project uses `flutter_lints ^6.0.0` with standard Flutter linter rules.

```bash
# Check for linting issues
flutter analyze

# Auto-fix some issues
dart fix --apply
```

### Code Formatting

```bash
# Format all files
flutter format .

# Format specific file
flutter format lib/main.dart

# Check formatting without applying
flutter format --set-exit-if-changed .
```

### Best Practices

1. **Follow MVVM architecture** - Keep UI logic in Cubits, not widgets
2. **Use repositories** - Never call LocalSources directly from Cubits
3. **userId filtering** - All database queries MUST filter by userId
4. **Immutable models** - Use `@freezed` for all models and states
5. **Dependency injection** - Use GetIt service locator
6. **Logging** - Use AppLogger for all logging, not print()
7. **Stream subscriptions** - Always cancel in Cubit.close()

## Troubleshooting

### Build Runner Issues

```bash
# Clean generated files and rebuild
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs
```

### Dependency Conflicts

```bash
# Clean and reinstall dependencies
flutter clean
flutter pub get
```

### iOS-Specific Issues

```bash
# Clean Pods
cd ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter clean
flutter pub get
```

### Android-Specific Issues

```bash
# Clean Android build
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

## Getting Help

- **Issues**: [GitHub Issues](https://github.com/domain80/centabit_v0.5/issues)
- **Discussions**: [GitHub Discussions](https://github.com/domain80/centabit_v0.5/discussions)
- **Documentation**: [Full Documentation](/)
- **Contributing**: [Contributing Guide](/contributing/)

## Next Steps

- Read the [Architecture Overview](/architecture/)
- Explore [Development Patterns](/development/patterns-and-conventions.html)
- Check out [Adding Features](/development/adding-features.html)
- Review [Contributing Guidelines](/contributing/)
- Make your first contribution!

## Quick Reference

```bash
# Common commands
flutter pub get                  # Install dependencies
flutter run                      # Run app
flutter pub run build_runner build --delete-conflicting-outputs  # Generate code
flutter analyze                  # Check for issues
flutter format .                 # Format code
flutter clean                    # Clean build artifacts
```

Happy coding! 🚀
