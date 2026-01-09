# Contributing to Centabit

Welcome! We're excited that you're interested in contributing to Centabit v0.5. Whether you're a developer, designer, technical writer, or user with feedback, there's a place for you in our community.

## Why Contribute?

Centabit is an open-source budgeting app built with modern Flutter architecture. By contributing, you'll:

- **Learn Modern Flutter**: Work with Cubit, Drift, Freezed, and clean architecture patterns
- **Build Your Portfolio**: Make meaningful contributions to a real-world production app
- **Help Others**: Your work helps people manage their finances better
- **Join a Community**: Connect with other developers and designers passionate about Flutter

## Ways to Contribute

### For Developers

- **Fix Bugs**: Browse [open issues](https://github.com/domain80/centabit_v0.5/issues) labeled `bug`
- **Add Features**: Check the [roadmap](/roadmap/current-features) for potential features
- **Improve Performance**: Optimize queries, reduce build times, enhance UX
- **Write Tests**: Help us reach better test coverage (we're just getting started!)
- **Review Pull Requests**: Share your expertise by reviewing others' code

[Start here: Development Workflow →](./development-workflow)

### For Designers

We welcome designers of all skill levels! You don't need to know Flutter to contribute.

- **UI/UX Improvements**: Suggest better user flows or interface designs
- **Design System**: Help expand our Material 3 design tokens
- **Icon Design**: Create custom icons for categories or features
- **Motion Design**: Design smooth animations and transitions
- **Accessibility**: Improve color contrast, touch targets, screen reader support

[Start here: Design Contributions →](./design-contributions)

### For Technical Writers

- **Improve Documentation**: Fix typos, clarify explanations, add examples
- **Write Tutorials**: Create step-by-step guides for common tasks
- **Translate**: Help make Centabit accessible in other languages (future)
- **API Documentation**: Document classes, methods, and parameters

[Start here: Documentation Guide →](./documentation-guide)

### For Users

- **Report Bugs**: Found something broken? [Open an issue](https://github.com/domain80/centabit_v0.5/issues/new)
- **Request Features**: Share ideas for improvements
- **Provide Feedback**: Tell us what works and what doesn't
- **Test Beta Features**: Help test new features before they're released

## Quick Start

### 1. Read the Code of Conduct

Please review our [Code of Conduct](./code-of-conduct) before contributing. We're committed to fostering an inclusive, welcoming community.

### 2. Set Up Your Environment

Follow our [development setup guide](/getting-started/for-developers) to get Centabit running locally.

### 3. Find an Issue

Browse [good first issues](https://github.com/domain80/centabit_v0.5/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22) if you're new to the project.

### 4. Make Your Changes

Follow our [development workflow](./development-workflow) for branching, commits, and pull requests.

### 5. Submit a Pull Request

Open a PR with a clear description of your changes. Our team will review and provide feedback.

## Contribution Guidelines

### Code Quality

- **Follow existing patterns**: Use the same architectural patterns as the rest of the codebase
- **Format your code**: Run `flutter format .` before committing
- **Pass linter checks**: Ensure `flutter analyze` has no errors
- **Add tests**: Include unit or widget tests for new features (we're building this out!)
- **Update docs**: Document new features or API changes

### Communication

- **Be respectful**: Treat everyone with kindness and respect
- **Be clear**: Provide context and details in issues and PRs
- **Be patient**: Reviews take time—we appreciate your understanding
- **Ask questions**: Not sure about something? Just ask!

## Recognition

We value every contribution, big or small. Contributors will be:

- Listed in our [Contributors](#) page (coming soon)
- Credited in release notes
- Welcomed into our community with gratitude

## Resources

### Documentation
- [Architecture Overview](/architecture/) - Understand how Centabit is built
- [Development Guide](/development/) - Set up your dev environment
- [API Reference](/api-reference/) - Explore the codebase
- [Patterns & Conventions](/development/patterns-and-conventions) - Coding standards

### Community
- **GitHub Discussions**: Ask questions, share ideas (coming soon)
- **Issues**: Track bugs and feature requests
- **Pull Requests**: Review and contribute code

## Getting Help

Stuck? Have questions? Here's how to get help:

1. **Check the docs**: Most common questions are answered in our [documentation](/getting-started/)
2. **Search issues**: Someone may have already asked your question
3. **Open an issue**: Create a new issue with the `question` label
4. **Review existing code**: The codebase has many examples to learn from

## Project Structure

Understanding the codebase structure will help you navigate and contribute more effectively:

```
lib/
├── core/                    # Shared functionality
│   ├── theme/              # Material 3 theming
│   ├── widgets/            # Reusable components
│   └── router/             # Navigation setup
├── data/                   # Data layer
│   ├── models/             # Domain models
│   ├── local/              # Drift database
│   └── repositories/       # Repository pattern
└── features/               # Feature modules
    ├── budgets/
    ├── transactions/
    ├── categories/
    └── dashboard/
```

[Learn more about the architecture →](/architecture/)

## What We're Looking For

We're especially interested in contributions that:

- **Improve user experience**: Better flows, clearer UI, smoother interactions
- **Enhance performance**: Faster queries, reduced jank, optimized builds
- **Increase accessibility**: Better keyboard navigation, screen reader support, color contrast
- **Add tests**: Unit tests, widget tests, integration tests
- **Expand features**: Implement items from our [roadmap](/roadmap/current-features)

## Code of Conduct

This project adheres to a [Code of Conduct](./code-of-conduct) to ensure a welcoming environment for all contributors. By participating, you agree to uphold this code.

## License

By contributing to Centabit, you agree that your contributions will be licensed under the MIT License.

---

**Ready to contribute?** Pick a guide below and get started:

<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1rem; margin: 2rem 0;">
  <a href="./development-workflow" style="padding: 1rem; border: 1px solid var(--vp-c-divider); border-radius: 8px; text-decoration: none; background: var(--vp-c-bg-soft);">
    <strong>Development Workflow</strong><br>
    <small>For code contributors</small>
  </a>
  <a href="./design-contributions" style="padding: 1rem; border: 1px solid var(--vp-c-divider); border-radius: 8px; text-decoration: none; background: var(--vp-c-bg-soft);">
    <strong>Design Guide</strong><br>
    <small>For designers & UI/UX</small>
  </a>
  <a href="./testing-guidelines" style="padding: 1rem; border: 1px solid var(--vp-c-divider); border-radius: 8px; text-decoration: none; background: var(--vp-c-bg-soft);">
    <strong>Testing Guidelines</strong><br>
    <small>Write and run tests</small>
  </a>
  <a href="./documentation-guide" style="padding: 1rem; border: 1px solid var(--vp-c-divider); border-radius: 8px; text-decoration: none; background: var(--vp-c-bg-soft);">
    <strong>Documentation Guide</strong><br>
    <small>Improve docs</small>
  </a>
</div>

**Questions?** Open an issue with the `question` label or check our [FAQ](/user-guide/faq).

Thank you for contributing to Centabit!
