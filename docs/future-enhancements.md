# Future Enhancements for Centabit v0.5+

This document outlines planned features and improvements for upcoming versions of Centabit.

## Navigation & Search Features

### Search History

**Description**: Store and display recent search queries for quick access.

**Implementation Details**:
- Store recent search queries locally (SharedPreferences or SQLite)
- Display recent searches as chips/pills when search is activated
- Ability to clear individual search history items
- Ability to clear all search history at once
- Limit history to last 10-20 searches
- Persist history across app sessions
- Organize history by date (Today, Yesterday, This Week, etc.)

**UI/UX Considerations**:
- Show history suggestions below search input when field is focused
- Highlight currently selected search item
- Add animation when adding/removing history items
- Show "Clear all" button only when history exists

### Search Suggestions (Auto-complete)

**Description**: Provide intelligent suggestions based on existing data.

**Implementation Details**:
- Extract unique values from indexed fields (descriptions, categories, amounts)
- Implement fuzzy matching for typo tolerance
- Show suggestions dropdown below search input
- Highlight matching text in suggestions
- Sort suggestions by relevance and frequency
- Support for both exact and partial matches
- Debounce search input (300-500ms) before querying

**Page-Specific Suggestions**:
- **Transactions**: Transaction descriptions, category names, amount ranges
- **Dashboard**: Common search terms, time periods (this month, last quarter, etc.)
- **Budgets**: Budget names, category names

### Advanced Search

**Description**: Support complex search queries with multiple filters.

**Implementation Details**:
- Date range filtering (from, to dates)
- Amount range filtering (min, max amounts)
- Category multi-select filtering
- Transaction type filtering (income, expense, transfer)
- Boolean operators: AND, OR, NOT
- Saved search filters/templates
- Search query builder UI

**Example Queries**:
- "expense last month category:groceries"
- "amount:100-500 type:expense"
- "transfer AND (from:account1 OR to:account1)"

## Navigation Enhancements

### Auto-hide Navigation

**Description**: Hide nav bar on scroll for more content space.

**Implementation Details**:
- Detect scroll direction (up/down)
- Animate nav bar slide out on scroll down
- Animate nav bar slide in on scroll up
- Maintain current tab selection
- Respect user gesture intent
- Add 500ms delay before hiding (prevent jitter on small scrolls)

**Configuration Options**:
- Enable/disable per page
- Customize hide threshold (scroll distance)
- Customize animation duration
- Enable/disable for searchable pages only

### Swipe Navigation

**Description**: Navigate between tabs using swipe gestures.

**Implementation Details**:
- Detect horizontal swipe gestures
- Swipe right to go to previous tab
- Swipe left to go to next tab
- Visual feedback during swipe (highlight next tab)
- Support configurable swipe velocity threshold
- Disable during search mode

**UX Details**:
- Show visual indicator (border/highlight) for next tab during swipe
- Smooth transition animation
- Respect platform swipe conventions (RTL languages)

### Long-press Navigation

**Description**: Quick actions via long-press on nav icons.

**Implementation Details**:
- Long-press on tab icon shows context menu
- Different actions per tab:
  - Dashboard: "Go to settings", "View summary"
  - Transactions: "View filters", "Create report"
  - Budgets: "Edit budgets", "View alerts"
- 500ms press duration before triggering
- Visual haptic feedback

### Pull-to-Refresh

**Description**: Refresh page content via pull gesture.

**Implementation Details**:
- Add refresh indicator at top of scrollable content
- Pull down to trigger refresh
- Show loading indicator during refresh
- Automatic scroll-to-top after refresh
- Customizable refresh animation duration

**Implementation Approach**:
- Use `RefreshIndicator` widget from Flutter
- Integrate with existing page cubits
- Add refresh methods to relevant cubits

## Search Performance

### Debouncing

**Description**: Prevent excessive queries during rapid typing.

**Current**: Not implemented (planned)
**Implementation**:
- Debounce search input with 300-500ms delay
- Cancel previous search requests if new query arrives
- Show loading indicator during debounce wait
- Update placeholder text: "Searching..."

### Caching

**Description**: Cache search results for repeated queries.

**Implementation Details**:
- Cache recent search results (10-20 most recent)
- Time-based cache expiration (5-15 minutes)
- Invalidate cache on page data changes
- Display cache age indicator to user

### Indexing

**Description**: Pre-index common search fields for faster queries.

**Implementation Details**:
- Create searchable indexes for transaction descriptions
- Create searchable indexes for category names
- Update indexes on data changes
- Support incremental index updates

## Data Management

### Search Filters

**Description**: Persistent search filter presets.

**Implementation Details**:
- Save/name custom search filters
- Apply filters with single tap
- Edit filter criteria
- Delete filters
- Reorder filters
- Export/import filter sets

### Search Reports

**Description**: Generate reports from search results.

**Implementation Details**:
- PDF export of filtered results
- CSV export for spreadsheet analysis
- Chart visualization of results (pie, bar, line)
- Custom date range selection
- Include summary statistics

## Accessibility

### Search Accessibility

**Description**: Improve search experience for accessibility needs.

**Implementation Details**:
- Screen reader support for search suggestions
- Keyboard navigation through suggestions
- Clear focus indicators
- ARIA labels for screen readers
- Support for voice input
- High contrast mode support

## Analytics & Insights

### Search Analytics

**Description**: Track and analyze user search behavior.

**Implementation Details**:
- Track popular search queries
- Track failed searches (no results)
- Track search-to-action conversion (search → detail view)
- Analytics dashboard for trends
- Use insights to improve search ranking

## Performance Targets

- **Search Input Response**: < 100ms between keystroke and UI update
- **Suggestion Rendering**: < 200ms for 20 suggestions
- **Query Execution**: < 500ms for full dataset scan
- **Cache Hit Rate**: > 70% for repeated queries
- **Memory Usage**: < 50MB for search cache

## Migration Path

### v0.6
- [ ] Search history
- [ ] Search suggestions (fuzzy matching)

### v0.7
- [ ] Auto-hide navigation
- [ ] Swipe navigation gestures
- [ ] Search debouncing

### v0.8
- [ ] Advanced search with filters
- [ ] Long-press navigation actions
- [ ] Pull-to-refresh

### v0.9+
- [ ] Search caching & indexing
- [ ] Saved filter presets
- [ ] Search reports & export
- [ ] Voice search input

## Notes

- All search features should maintain current haptic feedback
- Ensure proper keyboard handling (dismiss on done/back)
- Test on low-end devices for performance
- Consider data privacy for search history
- Allow user control over data collection
