# Centabit v0.5 Documentation

## Project Overview

Centabit is a Flutter budgeting application that helps users track expenses, manage budgets, and monitor financial health through the Budget Adherence Ratio (BAR) metric.

### Key Features

- **Budget Management**: Create and track monthly/periodic budgets with category allocations
- **Transaction Tracking**: Record income and expenses with category tagging and date filtering
- **Budget Adherence Ratio (BAR)**: Financial health metric comparing spending rate vs time progression
- **Interactive Charts**: Visualize budget allocations vs actual spending by category
- **Offline-First**: Works fully offline with local SQLite database and background sync
- **Material 3 Design**: Modern UI with custom theme, glassmorphic navigation, and smooth animations

### Project Synopsis

Centabit v0.5 represents a complete architectural evolution from in-memory data management to a production-ready **local-first architecture**. The app is built with Flutter using the MVVM pattern and implements an offline-first approach where all data is stored locally in a SQLite database (via Drift) and synchronized to a backend API in the background using isolates.

**Architecture Highlights**:
- **Offline-First**: Local database is the single source of truth
- **Reactive Streams**: Automatic UI updates via BLoC pattern and Drift's reactive queries
- **Multi-User Ready**: All database queries filter by userId for future OAuth integration
- **Background Sync**: Non-blocking sync operations run in isolates
- **Type-Safe Database**: Drift provides compile-time query validation
- **Optimistic Updates**: Changes appear immediately, sync happens asynchronously

### Project Structure

```
centabit_v0.5/
├── lib/
│   ├── main.dart                   # App entry point
│   ├── core/                       # Shared functionality
│   │   ├── auth/                   # Authentication (anonymous + OAuth prep)
│   │   ├── di/                     # Dependency injection (GetIt)
│   │   ├── router/                 # Navigation (GoRouter)
│   │   ├── theme/                  # Material 3 theme system
│   │   └── utils/                  # Helpers and utilities
│   │
│   ├── data/                       # Data layer (v5 local-first)
│   │   ├── models/                 # Domain models (Freezed)
│   │   ├── local/                  # Drift database & LocalSources
│   │   ├── repositories/           # Repository layer
│   │   └── sync/                   # Background sync manager
│   │
│   ├── features/                   # Feature modules (MVVM)
│   │   ├── auth/                   # Login/authentication
│   │   ├── dashboard/              # Budget reports & BAR
│   │   ├── transactions/           # Transaction list & management
│   │   ├── budgets/                # Budget creation & editing
│   │   └── categories/             # Category management
│   │
│   └── shared/                     # Shared UI components
│       └── widgets/                # Reusable widgets
│
├── docs/                           # Architecture documentation
│   ├── README.md                   # This file
│   ├── architecture.md             # System architecture overview
│   ├── data-flow.md                # Data flow patterns
│   ├── user-filtering.md           # Multi-user userId pattern
│   └── sync-strategy.md            # Background sync with isolates
│
└── test/                           # Tests (not yet implemented)
```

## Documentation Index

This documentation is organized into focused topics, each starting with diagrams followed by explanations:

1. **[Architecture Overview](./architecture.md)** - High-level system architecture, layers, and components
2. **[Data Flow](./data-flow.md)** - How data moves through the system from UI to database
3. **[User Filtering](./user-filtering.md)** - Multi-user support with userId filtering pattern
4. **[Sync Strategy](./sync-strategy.md)** - Background synchronization using isolates

## Quick Start

For development commands and setup instructions, see the main [CLAUDE.md](../CLAUDE.md) file.

## Architecture Quick Reference

```
Presentation Layer (Cubits)
        ↓ (stream subscriptions)
Repository Layer (coordinate local + future remote)
        ↓
LocalSource Layer (userId-filtered Drift queries)
        ↓
Drift Database (SQLite with reactive queries)
        ↓
SyncManager (isolate-based background sync)
```

**Key Principle**: Data flows down through layers, changes bubble up through reactive streams.
