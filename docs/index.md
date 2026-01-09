---
layout: home

hero:
  name: Centabit
  text: Smart Budgeting
  tagline: A budgeting app that gets better with each iteration. Track expenses, manage budgets, and monitor your financial health.
  image:
    src: /logo.svg
    alt: Centabit Logo
  actions:
    - theme: brand
      text: Get Started
      link: /getting-started/
    - theme: alt
      text: Join FREE Waitlist
      link: https://tally.so/r/eqQo4k
    - theme: alt
      text: View on GitHub
      link: https://github.com/domain80/centabit_v0.5

features:
  - icon: 📊
    title: BAR Metrics
    details: Budget Adherence Ratio compares spending rate vs time progression to keep you on track with your financial goals.

  - icon: 💾
    title: Offline-First
    details: Works fully offline with local SQLite database and background sync. Your data is always available, even without internet.

  - icon: 📱
    title: Material 3 Design
    details: Beautiful glassmorphic navigation, smooth animations, and modern design system that adapts to light and dark modes.

  - icon: 🔒
    title: Multi-User Ready
    details: userId filtering on all queries with anonymous tokens now, OAuth ready for the future. Secure data isolation built-in.

  - icon: 🏗️
    title: Clean Architecture
    details: MVVM pattern with Cubit state management, repository pattern, and feature-first organization for maintainability.

  - icon: ⚡
    title: Background Sync
    details: Non-blocking isolate-based sync keeps UI smooth while syncing in the background. No jank, no delays.
---

<div class="sticky-layout">
  <div class="sticky-video-column">
    <div class="video-container-sticky">
      <video controls poster="/demo-poster.jpg">
        <source src="/demo.mp4" type="video/mp4">
        Your browser doesn't support video playback.
      </video>
      <p style="text-align: center; margin-top: 1rem; font-size: 0.9em; color: var(--vp-c-text-2);">
        📹 Watch the full demo (3 minutes)
      </p>
    </div>
  </div>

  <div class="scrollable-content-column">

## Why Centabit?

Centabit v0.5 is a complete architectural evolution designed for production. Unlike v0.4's prototype architecture, v0.5 implements:

- **Local-First Architecture**: SQLite is the single source of truth
- **Reactive Streams**: Automatic UI updates via BLoC pattern and Drift's reactive queries
- **Type-Safe Database**: Drift provides compile-time query validation
- **Isolate-Based Sync**: Background sync without blocking the UI
- **Feature-First Organization**: All related code lives together

    <div class="waitlist-cta">
      <h3 style="margin: 0 0 0.5rem 0;">Ready to Take Control of Your Budget?</h3>
      <p style="margin: 0 0 1rem 0; color: var(--vp-c-text-2);">Be the first to know when Centabit launches!</p>
      <a href="https://tally.so/r/eqQo4k" class="VPButton brand" style="text-decoration: none;">
        🚀 Join the FREE Waitlist
      </a>
    </div>

## Technology Stack

Built with modern Flutter tools and best practices:

<table>
      <thead>
        <tr>
          <th>Technology</th>
          <th>Purpose</th>
        </tr>
      </thead>
      <tbody>
        <tr>
          <td><strong>Flutter</strong></td>
          <td>Cross-platform UI framework</td>
        </tr>
        <tr>
          <td><strong>flutter_bloc</strong> (Cubit)</td>
          <td>Reactive state management</td>
        </tr>
        <tr>
          <td><strong>Drift</strong></td>
          <td>Type-safe SQLite ORM</td>
        </tr>
        <tr>
          <td><strong>Freezed</strong></td>
          <td>Immutable data classes</td>
        </tr>
        <tr>
          <td><strong>go_router</strong></td>
          <td>Declarative navigation</td>
        </tr>
        <tr>
          <td><strong>get_it</strong></td>
          <td>Dependency injection</td>
        </tr>
        <tr>
          <td><strong>Dart Isolates</strong></td>
          <td>Background sync</td>
        </tr>
        <tr>
          <td><strong>Material 3</strong></td>
          <td>Modern design system</td>
        </tr>
      </tbody>
</table>

[Explore the full tech stack →](/architecture/)

## Architecture at a Glance

```
┌─────────────────────────────────────────┐
│  Presentation Layer (Cubits + Freezed)  │
│  - Feature-specific Cubits              │
│  - Immutable states with union types    │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│  Repository Layer (Clean Architecture)  │
│  - Single Responsibility repos          │
│  - Broadcast streams for reactivity     │
│  - Transform DB ↔ Domain models         │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│  LocalSources (userId-filtered)         │
│  - Automatic userId injection           │
│  - Secure multi-user data isolation     │
└──────────────┬──────────────────────────┘
               │
┌──────────────▼──────────────────────────┐
│  Database (Drift) + Isolate-Based Sync  │
│  - Reactive queries                     │
│  - Background sync (off main thread)    │
└─────────────────────────────────────────┘
```

[Learn more about the architecture →](/architecture/)

## Key Features

- Budget management with category allocations
- Transaction tracking with search and filtering
- Budget Adherence Ratio (BAR) metric
- Offline-first with local SQLite storage
- Multi-user support with userId filtering
- Interactive charts (bar and pie)
- Material 3 design with dark mode
- Background sync infrastructure

[Explore all features →](/roadmap/current-features)

## What's Different in v0.5?

Complete architectural rewrite from v0.4:

- Feature-first organization
- Better state management (Cubit pattern)
- Type-safe everything (Freezed + Drift)
- True offline support
- Multi-user ready

[Read the full evolution story →](/architecture/evolution)

## Development Approach

Centabit evolves based on **real user needs**, not rigid timelines. Features are prioritized from waitlist feedback and actual user requests. [Join the free waitlist](https://tally.so/r/eqQo4k) to influence what gets built next!

  </div>
</div>
