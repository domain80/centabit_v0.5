# Development Guide

Comprehensive guide for contributing to and extending Centabit v0.5.

## Quick Start

New to Centabit development? Start with the [Developer Quick Start Guide](/getting-started/for-developers.md) for setup instructions and first steps.

## Core Development Topics

### Adding New Features
Learn the step-by-step workflow for implementing new features:
- **[Adding Features](./adding-features.md)** - Complete guide from models to UI

### Code Patterns & Conventions
Understand the established patterns and best practices:
- **[Patterns & Conventions](./patterns-and-conventions.md)** - File naming, state management, repository pattern

### Database Design
Master the Drift database schema and design patterns:
- **[Database Schema](./database-schema.md)** - Tables, relationships, userId filtering, sync metadata

### Real-World Case Study
See how complex features are built end-to-end:
- **[Dashboard Case Study](./dashboard-case-study.md)** - Complete dashboard migration with BAR calculations

## Architecture Context

Development in Centabit follows a local-first, feature-driven architecture:

```
Feature Request
  ↓
1. Define Models (Freezed)
  ↓
2. Add Database Table (Drift)
  ↓
3. Create LocalSource (userId-filtered queries)
  ↓
4. Build Repository (broadcast streams)
  ↓
5. Implement Cubit (state management)
  ↓
6. Create UI (BlocBuilder/BlocListener)
  ↓
7. Register in DI (GetIt)
  ↓
8. Test & Document
```

See the [Architecture Overview](/architecture/) for detailed system design.

## Development Workflow

### Prerequisites
- Flutter SDK 3.10+
- Dart 3.0+
- IDE (VS Code or Android Studio)
- Git for version control

### Common Commands

```bash
# Run app
flutter run

# Code generation (Freezed, Drift, JSON)
flutter pub run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerate)
flutter pub run build_runner watch

# Analyze code
flutter analyze

# Format code
flutter format .
```

### Development Cycle

1. **Create Feature Branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Implement Feature** (see [Adding Features](./adding-features.md))

3. **Run Code Generation**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Test Locally**
   ```bash
   flutter run
   ```

5. **Commit Changes** (see [Contributing Guide](/contributing/development-workflow.md))

6. **Create Pull Request**

## Key Technologies

| Technology | Purpose | Documentation |
|------------|---------|---------------|
| **Flutter** | Cross-platform UI | [flutter.dev](https://flutter.dev) |
| **Drift** | Type-safe SQLite ORM | [drift.simonbinder.eu](https://drift.simonbinder.eu) |
| **flutter_bloc** | State management (Cubit) | [bloclibrary.dev](https://bloclibrary.dev) |
| **Freezed** | Immutable data classes | [pub.dev/packages/freezed](https://pub.dev/packages/freezed) |
| **get_it** | Dependency injection | [pub.dev/packages/get_it](https://pub.dev/packages/get_it) |
| **go_router** | Declarative navigation | [pub.dev/packages/go_router](https://pub.dev/packages/go_router) |

## Need Help?

- **Architecture Questions**: See [Architecture Docs](/architecture/)
- **API Documentation**: Check [API Reference](/api-reference/)
- **Contributing Guidelines**: Read [Contributing Guide](/contributing/)
- **Report Issues**: [GitHub Issues](https://github.com/domain80/centabit_v0.5/issues)
- **Discuss Ideas**: [GitHub Discussions](https://github.com/domain80/centabit_v0.5/discussions)
