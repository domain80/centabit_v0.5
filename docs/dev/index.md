# Developer Documentation

Welcome to the Centabit v0.5 developer documentation.

## Quick Links

### Getting Started
- [Quick Start](/getting-started/for-developers) - Set up your development environment

### Architecture
- [Overview](/architecture/) - System architecture and design patterns
- [Data Flow](/architecture/data-flow) - How data flows through the app
- [User Filtering](/architecture/user-filtering) - Multi-user support implementation
- [Sync Strategy](/architecture/sync-strategy) - Offline-first sync approach
- [State Management](/architecture/state-management) - Cubit patterns and reactive streams
- [Evolution](/architecture/evolution) - v0.4 to v0.5 migration

### Development
- [Overview](/development/) - Development workflows
- [Adding Features](/development/adding-features) - Feature implementation guide
- [Patterns & Conventions](/development/patterns-and-conventions) - Code standards
- [Database Schema](/development/database-schema) - Drift database schema
- [Dashboard Case Study](/development/dashboard-case-study) - Real-world example

### API Reference
- [Overview](/api-reference/) - API documentation
- [Models](/api-reference/models/transaction-model) - Domain models
- [Repositories](/api-reference/repositories/transaction-repository) - Data repositories
- [Cubits](/api-reference/cubits/dashboard-cubit) - State management

### Contributing
- [Guidelines](/contributing/) - How to contribute
- [Code of Conduct](/contributing/code-of-conduct) - Community guidelines
- [Development Workflow](/contributing/development-workflow) - Git workflow and PR process
- [Design Contributions](/contributing/design-contributions) - UI/UX contributions
- [Testing Guidelines](/contributing/testing-guidelines) - Testing practices
- [Documentation Guide](/contributing/documentation-guide) - Documentation standards

### Roadmap
- [Overview](/roadmap/) - Project roadmap
- [Features](/roadmap/current-features) - Current and future features

## Tech Stack

- **Framework**: Flutter 3.x with Dart
- **State Management**: flutter_bloc (Cubit pattern)
- **Database**: Drift (SQLite)
- **Models**: Freezed (immutable data classes)
- **DI**: get_it
- **Routing**: go_router
- **Charts**: fl_chart
- **Logging**: talker_flutter

## Architecture Highlights

- Feature-first organization
- MVVM architecture pattern
- Repository pattern with broadcast streams
- Offline-first with background sync
- Type-safe everything (Freezed + Drift)
- Multi-user ready with userId filtering

---

**Ready to contribute?** Start with the [Quick Start](/getting-started/for-developers) guide or browse the sidebar for specific topics.
