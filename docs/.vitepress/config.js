import { defineConfig } from 'vitepress'

export default defineConfig({
  // Site metadata
  title: 'Centabit',
  description: 'A budgeting app that gets better with each iteration',
  lang: 'en-US',
  base: '/centabit_v0.5/',

  // Clean URLs
  cleanUrls: true,

  // Head tags
  head: [
    ['link', { rel: 'icon', href: '/centabit_v0.5/logo.svg' }],
    ['meta', { name: 'theme-color', content: '#2D9D8F' }],
    ['meta', { property: 'og:type', content: 'website' }],
    ['meta', { property: 'og:title', content: 'Centabit - Smart Budgeting' }],
    ['meta', { property: 'og:description', content: 'A Flutter budgeting app with BAR metrics, offline-first architecture, and beautiful Material 3 design' }],
  ],

  // Theme configuration
  themeConfig: {
    // Logo in navbar
    logo: '/logo.svg',

    // Site title
    siteTitle: 'Centabit',

    // Top navigation
    nav: [
      { text: 'Home', link: '/' },
      { text: 'User', link: '/user-guide/' },
      { text: 'Dev', link: '/dev/' },
    ],

    // Sidebar navigation
    sidebar: {
      // User section - consistent sidebar for all user guide pages
      '/user-guide/': [
        {
          text: 'User Guide',
          items: [
            { text: 'Getting Started', link: '/user-guide/' },
            { text: 'Creating Budgets', link: '/user-guide/creating-budgets' },
            { text: 'Tracking Transactions', link: '/user-guide/tracking-transactions' },
            { text: 'Understanding BAR', link: '/user-guide/understanding-bar' },
            { text: 'Managing Categories', link: '/user-guide/categories' },
            { text: 'FAQ', link: '/user-guide/faq' },
          ]
        }
      ],

      // Dev section - consistent sidebar for ALL dev-related pages
      // This sidebar shows for /dev/, /getting-started/, /architecture/, /development/,
      // /api-reference/, /contributing/, and /roadmap/ pages
      '/dev/': [
        {
          text: 'Getting Started',
          items: [
            { text: 'Quick Start', link: '/getting-started/for-developers' },
          ]
        },
        {
          text: 'Architecture',
          items: [
            { text: 'Overview', link: '/architecture/' },
            { text: 'Data Flow', link: '/architecture/data-flow' },
            { text: 'User Filtering', link: '/architecture/user-filtering' },
            { text: 'Sync Strategy', link: '/architecture/sync-strategy' },
            { text: 'State Management', link: '/architecture/state-management' },
            { text: 'Evolution', link: '/architecture/evolution' },
          ]
        },
        {
          text: 'Development',
          items: [
            { text: 'Overview', link: '/development/' },
            { text: 'Adding Features', link: '/development/adding-features' },
            { text: 'Patterns & Conventions', link: '/development/patterns-and-conventions' },
            { text: 'Database Schema', link: '/development/database-schema' },
            { text: 'Dashboard Case Study', link: '/development/dashboard-case-study' },
          ]
        },
        {
          text: 'API Reference',
          items: [
            { text: 'Overview', link: '/api-reference/' },
          ]
        },
        {
          text: 'Models',
          collapsed: true,
          items: [
            { text: 'Transaction Model', link: '/api-reference/models/transaction-model' },
            { text: 'Budget Model', link: '/api-reference/models/budget-model' },
            { text: 'Category Model', link: '/api-reference/models/category-model' },
            { text: 'Allocation Model', link: '/api-reference/models/allocation-model' },
          ]
        },
        {
          text: 'Repositories',
          collapsed: true,
          items: [
            { text: 'Transaction Repository', link: '/api-reference/repositories/transaction-repository' },
            { text: 'Budget Repository', link: '/api-reference/repositories/budget-repository' },
            { text: 'Category Repository', link: '/api-reference/repositories/category-repository' },
          ]
        },
        {
          text: 'Cubits',
          collapsed: true,
          items: [
            { text: 'Dashboard Cubit', link: '/api-reference/cubits/dashboard-cubit' },
            { text: 'Transaction List Cubit', link: '/api-reference/cubits/transaction-list-cubit' },
          ]
        },
        {
          text: 'Contributing',
          items: [
            { text: 'Guidelines', link: '/contributing/' },
            { text: 'Code of Conduct', link: '/contributing/code-of-conduct' },
            { text: 'Development Workflow', link: '/contributing/development-workflow' },
            { text: 'Design Contributions', link: '/contributing/design-contributions' },
            { text: 'Testing Guidelines', link: '/contributing/testing-guidelines' },
            { text: 'Documentation Guide', link: '/contributing/documentation-guide' },
          ]
        },
        {
          text: 'Roadmap',
          items: [
            { text: 'Overview', link: '/roadmap/' },
            { text: 'Features', link: '/roadmap/current-features' },
          ]
        }
      ],

      // Map all dev-related paths to use the same /dev/ sidebar
      '/getting-started/': [
        {
          text: 'Getting Started',
          items: [
            { text: 'Quick Start', link: '/getting-started/for-developers' },
          ]
        },
        {
          text: 'Architecture',
          items: [
            { text: 'Overview', link: '/architecture/' },
            { text: 'Data Flow', link: '/architecture/data-flow' },
            { text: 'User Filtering', link: '/architecture/user-filtering' },
            { text: 'Sync Strategy', link: '/architecture/sync-strategy' },
            { text: 'State Management', link: '/architecture/state-management' },
            { text: 'Evolution', link: '/architecture/evolution' },
          ]
        },
        {
          text: 'Development',
          items: [
            { text: 'Overview', link: '/development/' },
            { text: 'Adding Features', link: '/development/adding-features' },
            { text: 'Patterns & Conventions', link: '/development/patterns-and-conventions' },
            { text: 'Database Schema', link: '/development/database-schema' },
            { text: 'Dashboard Case Study', link: '/development/dashboard-case-study' },
          ]
        },
        {
          text: 'API Reference',
          items: [
            { text: 'Overview', link: '/api-reference/' },
          ]
        },
        {
          text: 'Models',
          collapsed: true,
          items: [
            { text: 'Transaction Model', link: '/api-reference/models/transaction-model' },
            { text: 'Budget Model', link: '/api-reference/models/budget-model' },
            { text: 'Category Model', link: '/api-reference/models/category-model' },
            { text: 'Allocation Model', link: '/api-reference/models/allocation-model' },
          ]
        },
        {
          text: 'Repositories',
          collapsed: true,
          items: [
            { text: 'Transaction Repository', link: '/api-reference/repositories/transaction-repository' },
            { text: 'Budget Repository', link: '/api-reference/repositories/budget-repository' },
            { text: 'Category Repository', link: '/api-reference/repositories/category-repository' },
          ]
        },
        {
          text: 'Cubits',
          collapsed: true,
          items: [
            { text: 'Dashboard Cubit', link: '/api-reference/cubits/dashboard-cubit' },
            { text: 'Transaction List Cubit', link: '/api-reference/cubits/transaction-list-cubit' },
          ]
        },
        {
          text: 'Contributing',
          items: [
            { text: 'Guidelines', link: '/contributing/' },
            { text: 'Code of Conduct', link: '/contributing/code-of-conduct' },
            { text: 'Development Workflow', link: '/contributing/development-workflow' },
            { text: 'Design Contributions', link: '/contributing/design-contributions' },
            { text: 'Testing Guidelines', link: '/contributing/testing-guidelines' },
            { text: 'Documentation Guide', link: '/contributing/documentation-guide' },
          ]
        },
        {
          text: 'Roadmap',
          items: [
            { text: 'Overview', link: '/roadmap/' },
            { text: 'Features', link: '/roadmap/current-features' },
          ]
        }
      ],
      '/architecture/': [
        {
          text: 'Getting Started',
          items: [
            { text: 'Quick Start', link: '/getting-started/for-developers' },
          ]
        },
        {
          text: 'Architecture',
          items: [
            { text: 'Overview', link: '/architecture/' },
            { text: 'Data Flow', link: '/architecture/data-flow' },
            { text: 'User Filtering', link: '/architecture/user-filtering' },
            { text: 'Sync Strategy', link: '/architecture/sync-strategy' },
            { text: 'State Management', link: '/architecture/state-management' },
            { text: 'Evolution', link: '/architecture/evolution' },
          ]
        },
        {
          text: 'Development',
          items: [
            { text: 'Overview', link: '/development/' },
            { text: 'Adding Features', link: '/development/adding-features' },
            { text: 'Patterns & Conventions', link: '/development/patterns-and-conventions' },
            { text: 'Database Schema', link: '/development/database-schema' },
            { text: 'Dashboard Case Study', link: '/development/dashboard-case-study' },
          ]
        },
        {
          text: 'API Reference',
          items: [
            { text: 'Overview', link: '/api-reference/' },
          ]
        },
        {
          text: 'Models',
          collapsed: true,
          items: [
            { text: 'Transaction Model', link: '/api-reference/models/transaction-model' },
            { text: 'Budget Model', link: '/api-reference/models/budget-model' },
            { text: 'Category Model', link: '/api-reference/models/category-model' },
            { text: 'Allocation Model', link: '/api-reference/models/allocation-model' },
          ]
        },
        {
          text: 'Repositories',
          collapsed: true,
          items: [
            { text: 'Transaction Repository', link: '/api-reference/repositories/transaction-repository' },
            { text: 'Budget Repository', link: '/api-reference/repositories/budget-repository' },
            { text: 'Category Repository', link: '/api-reference/repositories/category-repository' },
          ]
        },
        {
          text: 'Cubits',
          collapsed: true,
          items: [
            { text: 'Dashboard Cubit', link: '/api-reference/cubits/dashboard-cubit' },
            { text: 'Transaction List Cubit', link: '/api-reference/cubits/transaction-list-cubit' },
          ]
        },
        {
          text: 'Contributing',
          items: [
            { text: 'Guidelines', link: '/contributing/' },
            { text: 'Code of Conduct', link: '/contributing/code-of-conduct' },
            { text: 'Development Workflow', link: '/contributing/development-workflow' },
            { text: 'Design Contributions', link: '/contributing/design-contributions' },
            { text: 'Testing Guidelines', link: '/contributing/testing-guidelines' },
            { text: 'Documentation Guide', link: '/contributing/documentation-guide' },
          ]
        },
        {
          text: 'Roadmap',
          items: [
            { text: 'Overview', link: '/roadmap/' },
            { text: 'Features', link: '/roadmap/current-features' },
          ]
        }
      ],
      '/development/': [
        {
          text: 'Getting Started',
          items: [
            { text: 'Quick Start', link: '/getting-started/for-developers' },
          ]
        },
        {
          text: 'Architecture',
          items: [
            { text: 'Overview', link: '/architecture/' },
            { text: 'Data Flow', link: '/architecture/data-flow' },
            { text: 'User Filtering', link: '/architecture/user-filtering' },
            { text: 'Sync Strategy', link: '/architecture/sync-strategy' },
            { text: 'State Management', link: '/architecture/state-management' },
            { text: 'Evolution', link: '/architecture/evolution' },
          ]
        },
        {
          text: 'Development',
          items: [
            { text: 'Overview', link: '/development/' },
            { text: 'Adding Features', link: '/development/adding-features' },
            { text: 'Patterns & Conventions', link: '/development/patterns-and-conventions' },
            { text: 'Database Schema', link: '/development/database-schema' },
            { text: 'Dashboard Case Study', link: '/development/dashboard-case-study' },
          ]
        },
        {
          text: 'API Reference',
          items: [
            { text: 'Overview', link: '/api-reference/' },
          ]
        },
        {
          text: 'Models',
          collapsed: true,
          items: [
            { text: 'Transaction Model', link: '/api-reference/models/transaction-model' },
            { text: 'Budget Model', link: '/api-reference/models/budget-model' },
            { text: 'Category Model', link: '/api-reference/models/category-model' },
            { text: 'Allocation Model', link: '/api-reference/models/allocation-model' },
          ]
        },
        {
          text: 'Repositories',
          collapsed: true,
          items: [
            { text: 'Transaction Repository', link: '/api-reference/repositories/transaction-repository' },
            { text: 'Budget Repository', link: '/api-reference/repositories/budget-repository' },
            { text: 'Category Repository', link: '/api-reference/repositories/category-repository' },
          ]
        },
        {
          text: 'Cubits',
          collapsed: true,
          items: [
            { text: 'Dashboard Cubit', link: '/api-reference/cubits/dashboard-cubit' },
            { text: 'Transaction List Cubit', link: '/api-reference/cubits/transaction-list-cubit' },
          ]
        },
        {
          text: 'Contributing',
          items: [
            { text: 'Guidelines', link: '/contributing/' },
            { text: 'Code of Conduct', link: '/contributing/code-of-conduct' },
            { text: 'Development Workflow', link: '/contributing/development-workflow' },
            { text: 'Design Contributions', link: '/contributing/design-contributions' },
            { text: 'Testing Guidelines', link: '/contributing/testing-guidelines' },
            { text: 'Documentation Guide', link: '/contributing/documentation-guide' },
          ]
        },
        {
          text: 'Roadmap',
          items: [
            { text: 'Overview', link: '/roadmap/' },
            { text: 'Features', link: '/roadmap/current-features' },
          ]
        }
      ],
      '/api-reference/': [
        {
          text: 'Getting Started',
          items: [
            { text: 'Quick Start', link: '/getting-started/for-developers' },
          ]
        },
        {
          text: 'Architecture',
          items: [
            { text: 'Overview', link: '/architecture/' },
            { text: 'Data Flow', link: '/architecture/data-flow' },
            { text: 'User Filtering', link: '/architecture/user-filtering' },
            { text: 'Sync Strategy', link: '/architecture/sync-strategy' },
            { text: 'State Management', link: '/architecture/state-management' },
            { text: 'Evolution', link: '/architecture/evolution' },
          ]
        },
        {
          text: 'Development',
          items: [
            { text: 'Overview', link: '/development/' },
            { text: 'Adding Features', link: '/development/adding-features' },
            { text: 'Patterns & Conventions', link: '/development/patterns-and-conventions' },
            { text: 'Database Schema', link: '/development/database-schema' },
            { text: 'Dashboard Case Study', link: '/development/dashboard-case-study' },
          ]
        },
        {
          text: 'API Reference',
          items: [
            { text: 'Overview', link: '/api-reference/' },
          ]
        },
        {
          text: 'Models',
          collapsed: true,
          items: [
            { text: 'Transaction Model', link: '/api-reference/models/transaction-model' },
            { text: 'Budget Model', link: '/api-reference/models/budget-model' },
            { text: 'Category Model', link: '/api-reference/models/category-model' },
            { text: 'Allocation Model', link: '/api-reference/models/allocation-model' },
          ]
        },
        {
          text: 'Repositories',
          collapsed: true,
          items: [
            { text: 'Transaction Repository', link: '/api-reference/repositories/transaction-repository' },
            { text: 'Budget Repository', link: '/api-reference/repositories/budget-repository' },
            { text: 'Category Repository', link: '/api-reference/repositories/category-repository' },
          ]
        },
        {
          text: 'Cubits',
          collapsed: true,
          items: [
            { text: 'Dashboard Cubit', link: '/api-reference/cubits/dashboard-cubit' },
            { text: 'Transaction List Cubit', link: '/api-reference/cubits/transaction-list-cubit' },
          ]
        },
        {
          text: 'Contributing',
          items: [
            { text: 'Guidelines', link: '/contributing/' },
            { text: 'Code of Conduct', link: '/contributing/code-of-conduct' },
            { text: 'Development Workflow', link: '/contributing/development-workflow' },
            { text: 'Design Contributions', link: '/contributing/design-contributions' },
            { text: 'Testing Guidelines', link: '/contributing/testing-guidelines' },
            { text: 'Documentation Guide', link: '/contributing/documentation-guide' },
          ]
        },
        {
          text: 'Roadmap',
          items: [
            { text: 'Overview', link: '/roadmap/' },
            { text: 'Features', link: '/roadmap/current-features' },
          ]
        }
      ],
      '/contributing/': [
        {
          text: 'Getting Started',
          items: [
            { text: 'Quick Start', link: '/getting-started/for-developers' },
          ]
        },
        {
          text: 'Architecture',
          items: [
            { text: 'Overview', link: '/architecture/' },
            { text: 'Data Flow', link: '/architecture/data-flow' },
            { text: 'User Filtering', link: '/architecture/user-filtering' },
            { text: 'Sync Strategy', link: '/architecture/sync-strategy' },
            { text: 'State Management', link: '/architecture/state-management' },
            { text: 'Evolution', link: '/architecture/evolution' },
          ]
        },
        {
          text: 'Development',
          items: [
            { text: 'Overview', link: '/development/' },
            { text: 'Adding Features', link: '/development/adding-features' },
            { text: 'Patterns & Conventions', link: '/development/patterns-and-conventions' },
            { text: 'Database Schema', link: '/development/database-schema' },
            { text: 'Dashboard Case Study', link: '/development/dashboard-case-study' },
          ]
        },
        {
          text: 'API Reference',
          items: [
            { text: 'Overview', link: '/api-reference/' },
          ]
        },
        {
          text: 'Models',
          collapsed: true,
          items: [
            { text: 'Transaction Model', link: '/api-reference/models/transaction-model' },
            { text: 'Budget Model', link: '/api-reference/models/budget-model' },
            { text: 'Category Model', link: '/api-reference/models/category-model' },
            { text: 'Allocation Model', link: '/api-reference/models/allocation-model' },
          ]
        },
        {
          text: 'Repositories',
          collapsed: true,
          items: [
            { text: 'Transaction Repository', link: '/api-reference/repositories/transaction-repository' },
            { text: 'Budget Repository', link: '/api-reference/repositories/budget-repository' },
            { text: 'Category Repository', link: '/api-reference/repositories/category-repository' },
          ]
        },
        {
          text: 'Cubits',
          collapsed: true,
          items: [
            { text: 'Dashboard Cubit', link: '/api-reference/cubits/dashboard-cubit' },
            { text: 'Transaction List Cubit', link: '/api-reference/cubits/transaction-list-cubit' },
          ]
        },
        {
          text: 'Contributing',
          items: [
            { text: 'Guidelines', link: '/contributing/' },
            { text: 'Code of Conduct', link: '/contributing/code-of-conduct' },
            { text: 'Development Workflow', link: '/contributing/development-workflow' },
            { text: 'Design Contributions', link: '/contributing/design-contributions' },
            { text: 'Testing Guidelines', link: '/contributing/testing-guidelines' },
            { text: 'Documentation Guide', link: '/contributing/documentation-guide' },
          ]
        },
        {
          text: 'Roadmap',
          items: [
            { text: 'Overview', link: '/roadmap/' },
            { text: 'Features', link: '/roadmap/current-features' },
          ]
        }
      ],
      '/roadmap/': [
        {
          text: 'Getting Started',
          items: [
            { text: 'Quick Start', link: '/getting-started/for-developers' },
          ]
        },
        {
          text: 'Architecture',
          items: [
            { text: 'Overview', link: '/architecture/' },
            { text: 'Data Flow', link: '/architecture/data-flow' },
            { text: 'User Filtering', link: '/architecture/user-filtering' },
            { text: 'Sync Strategy', link: '/architecture/sync-strategy' },
            { text: 'State Management', link: '/architecture/state-management' },
            { text: 'Evolution', link: '/architecture/evolution' },
          ]
        },
        {
          text: 'Development',
          items: [
            { text: 'Overview', link: '/development/' },
            { text: 'Adding Features', link: '/development/adding-features' },
            { text: 'Patterns & Conventions', link: '/development/patterns-and-conventions' },
            { text: 'Database Schema', link: '/development/database-schema' },
            { text: 'Dashboard Case Study', link: '/development/dashboard-case-study' },
          ]
        },
        {
          text: 'API Reference',
          items: [
            { text: 'Overview', link: '/api-reference/' },
          ]
        },
        {
          text: 'Models',
          collapsed: true,
          items: [
            { text: 'Transaction Model', link: '/api-reference/models/transaction-model' },
            { text: 'Budget Model', link: '/api-reference/models/budget-model' },
            { text: 'Category Model', link: '/api-reference/models/category-model' },
            { text: 'Allocation Model', link: '/api-reference/models/allocation-model' },
          ]
        },
        {
          text: 'Repositories',
          collapsed: true,
          items: [
            { text: 'Transaction Repository', link: '/api-reference/repositories/transaction-repository' },
            { text: 'Budget Repository', link: '/api-reference/repositories/budget-repository' },
            { text: 'Category Repository', link: '/api-reference/repositories/category-repository' },
          ]
        },
        {
          text: 'Cubits',
          collapsed: true,
          items: [
            { text: 'Dashboard Cubit', link: '/api-reference/cubits/dashboard-cubit' },
            { text: 'Transaction List Cubit', link: '/api-reference/cubits/transaction-list-cubit' },
          ]
        },
        {
          text: 'Contributing',
          items: [
            { text: 'Guidelines', link: '/contributing/' },
            { text: 'Code of Conduct', link: '/contributing/code-of-conduct' },
            { text: 'Development Workflow', link: '/contributing/development-workflow' },
            { text: 'Design Contributions', link: '/contributing/design-contributions' },
            { text: 'Testing Guidelines', link: '/contributing/testing-guidelines' },
            { text: 'Documentation Guide', link: '/contributing/documentation-guide' },
          ]
        },
        {
          text: 'Roadmap',
          items: [
            { text: 'Overview', link: '/roadmap/' },
            { text: 'Features', link: '/roadmap/current-features' },
          ]
        }
      ],
    },

    // Social links
    socialLinks: [
      { icon: 'github', link: 'https://github.com/domain80/centabit_v0.5' },
    ],

    // Footer
    footer: {
      message: 'Built with Flutter and ❤️',
      copyright: 'Copyright © 2024-present Centabit'
    },

    // Edit link
    editLink: {
      pattern: 'https://github.com/domain80/centabit_v0.5/edit/main/docs/:path',
      text: 'Edit this page on GitHub'
    },

    // Search
    search: {
      provider: 'local',
      options: {
        detailedView: true
      }
    },

    // Last updated
    lastUpdated: {
      text: 'Updated at',
      formatOptions: {
        dateStyle: 'medium',
        timeStyle: 'short'
      }
    }
  },

  // Markdown configuration
  markdown: {
    lineNumbers: true,
    theme: {
      light: 'github-light',
      dark: 'github-dark'
    }
  },

  // Build optimization
  vite: {
    build: {
      chunkSizeWarningLimit: 1000
    }
  }
})
