# Centabit Documentation

This directory contains the source files for the Centabit documentation site, built with VitePress.

**Live site**: [https://domain80.github.io/centabit_v0.5](https://domain80.github.io/centabit_v0.5)

## Local Development

```bash
# Install dependencies (from project root)
npm install

# Start dev server (from project root)
npm run docs:dev
# Opens at http://localhost:5173

# Build for production
npm run docs:build

# Preview production build
npm run docs:preview
```

## Documentation Structure

- `/getting-started/` - Onboarding guides for developers, users, and recruiters
- `/user-guide/` - End-user documentation
- `/architecture/` - System architecture and design patterns
- `/development/` - Development guides and workflows
- `/api-reference/` - API documentation for models, repositories, and cubits
- `/contributing/` - Contribution guidelines
- `/roadmap/` - Product roadmap and changelog

## Adding Documentation

1. Create a new `.md` file in the appropriate directory
2. Add front matter if needed (VitePress uses minimal front matter)
3. Update the sidebar configuration in `.vitepress/config.js`
4. Test locally with `npm run docs:dev`

See the [Documentation Guide](https://domain80.github.io/centabit_v0.5/contributing/documentation-guide.html) for detailed instructions.

## Technology

- **VitePress**: Fast, Vue-powered static site generator
- **Theme**: Default VitePress theme with custom Material 3 colors
- **Deployment**: GitHub Actions → GitHub Pages
- **Build time**: <5 seconds (vs 30+ seconds with Jekyll)
