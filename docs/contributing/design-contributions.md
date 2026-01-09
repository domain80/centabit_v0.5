# Design Contributions

Welcome, designers! We're thrilled to have you contribute to Centabit v0.5. **You don't need to know Flutter or write code to make valuable design contributions.** Your expertise in UI/UX, visual design, and user experience is incredibly valuable to this project.

## Why Design Matters

Good design is essential for a budgeting app:
- **Clarity**: Users need to understand their finances at a glance
- **Trust**: Professional design builds confidence in the app
- **Accessibility**: Everyone should be able to use financial tools
- **Delight**: Small touches make budgeting less stressful

## Ways to Contribute

### UI/UX Design

**User Flows**: Design or improve user journeys
- Creating a new budget
- Adding a transaction
- Viewing spending insights
- Editing categories

**Wireframes & Mockups**: Visualize new features
- Sketch ideas on paper or in Figma/Sketch
- Create high-fidelity mockups
- Design interactive prototypes
- Explore different layout options

**Information Architecture**: Organize content
- Navigation structure improvements
- Data hierarchy and grouping
- Screen flow optimization
- Feature discoverability

### Visual Design

**Icons**: Custom iconography
- Category icons (groceries, entertainment, etc.)
- Action icons (add, edit, delete)
- Status indicators
- Navigation icons

**Illustrations**: Add personality
- Empty state illustrations
- Onboarding graphics
- Error state visuals
- Success confirmations

**Color Palette**: Enhance the design system
- Suggest new color tokens
- Semantic color usage
- Dark mode refinements
- Accessibility improvements

**Typography**: Improve text hierarchy
- Font size adjustments
- Weight and style usage
- Reading experience
- Information density

### Motion Design

**Animations**: Smooth transitions
- Page transitions
- Modal animations
- Loading states
- Micro-interactions

**Gestures**: Intuitive interactions
- Swipe actions
- Pull-to-refresh
- Drag and drop
- Long press menus

### Accessibility

**Inclusive Design**: Make Centabit accessible to everyone
- Color contrast improvements (WCAG compliance)
- Touch target sizing (minimum 44x44 points)
- Screen reader compatibility
- Keyboard navigation
- Reduced motion alternatives

## Current Design System

Centabit uses **Material Design 3** as its foundation. Here's what you need to know:

### Design System Overview

**Material 3 Resources**:
- [Material Design Guidelines](https://m3.material.io/)
- [Color System](https://m3.material.io/styles/color/overview)
- [Typography](https://m3.material.io/styles/typography/overview)
- [Components](https://m3.material.io/components)

### Color Palette

Centabit's color scheme (defined in `/lib/core/theme/color_schemes.dart`):

#### Light Mode

**Primary Colors**:
- Primary: `#6750A4` (Purple)
- On Primary: `#FFFFFF` (White)
- Primary Container: `#EADDFF`
- On Primary Container: `#21005D`

**Secondary Colors**:
- Secondary: `#625B71`
- On Secondary: `#FFFFFF`
- Secondary Container: `#E8DEF8`
- On Secondary Container: `#1D192B`

**Tertiary Colors**:
- Tertiary: `#7D5260`
- On Tertiary: `#FFFFFF`
- Tertiary Container: `#FFD8E4`
- On Tertiary Container: `#31111D`

**Surface Colors**:
- Surface: `#FEF7FF`
- On Surface: `#1D1B20`
- Surface Variant: `#E7E0EC`
- On Surface Variant: `#49454F`

**Utility Colors**:
- Error: `#BA1A1A`
- Success: Custom green (from AppCustomColors)
- Warning: Custom amber (from AppCustomColors)

#### Dark Mode

**Primary Colors**:
- Primary: `#D0BCFF`
- On Primary: `#381E72`
- Primary Container: `#4F378B`
- On Primary Container: `#EADDFF`

**Surface Colors**:
- Surface: `#1D1B20`
- On Surface: `#E6E0E9`
- Surface Variant: `#49454F`
- On Surface Variant: `#CAC4D0`

### Custom Extensions

Beyond Material 3, we have custom theme extensions:

**AppCustomColors** (`/lib/core/theme/theme_extensions.dart`):
- Gradient colors for visual depth
- Success, warning, info colors
- Shimmer loading colors
- Custom surface variations

**AppSpacing**:
- xs: 4px
- sm: 8px
- md: 16px
- lg: 24px
- xl: 32px
- xxl: 48px

**AppRadius**:
- xs: 4px
- sm: 8px
- md: 12px
- lg: 16px
- xl: 20px
- pill: 28px (used for buttons)

### Typography

Material 3 typography scale:
- **Display**: Large, high-impact text (e.g., dashboard totals)
- **Headline**: Section headers
- **Title**: Card titles, page titles
- **Body**: Main content text
- **Label**: Button text, form labels

Font: **Roboto** (default Material font)

### Component Styling

**Buttons**:
- Pill-shaped (28px border radius)
- Filled, outlined, and text variants
- Consistent padding and sizing

**Cards**:
- Rounded corners (12px)
- Subtle shadows (elevation)
- Surface color backgrounds

**Input Fields**:
- Outlined style
- Floating labels
- Helper text and error states

**Bottom Sheets**:
- Rounded top corners
- Drag handle
- Modal and persistent variants

## How to Submit Design Contributions

### 1. Identify What to Design

**Browse existing issues**: Look for issues tagged with `design` or `UI/UX`

**Create a new issue**: Propose your own design improvements
```markdown
Title: [Design] Improve transaction list readability

Description:
The current transaction list is cluttered and hard to scan. I'd like to
propose a redesigned layout with better visual hierarchy and grouping.

I'll provide:
- Wireframes showing the new layout
- Mockups in light and dark mode
- Rationale for design decisions
```

### 2. Create Your Designs

Use any tool you're comfortable with:
- **Figma** (recommended for collaboration)
- **Sketch**
- **Adobe XD**
- **Pen and paper** (seriously!)
- **Any other design tool**

#### Design Checklist

When creating mockups, consider:

- [ ] Light AND dark mode versions
- [ ] Different screen sizes (mobile, tablet)
- [ ] Empty states (no data)
- [ ] Error states (something went wrong)
- [ ] Loading states (data fetching)
- [ ] Accessibility (contrast, touch targets)
- [ ] Material 3 guidelines
- [ ] Existing design patterns

### 3. Export and Document

**Export formats**:
- PNG or JPG for mockups (2x resolution)
- SVG for icons and illustrations
- PDF for multi-page designs

**Include annotations**:
- Explain your design decisions
- Note spacing and sizing
- Highlight interactive elements
- Describe animations or transitions
- Call out accessibility considerations

#### Example Design Documentation

```markdown
## Transaction List Redesign

### Goals
- Improve scannability with better visual hierarchy
- Group transactions by date more clearly
- Make transaction amounts more prominent

### Changes
1. **Date Headers**: Sticky headers with stronger visual weight
2. **Transaction Cards**: More padding, clearer separation
3. **Amount Typography**: Larger, bolder numbers
4. **Category Icons**: More prominent with color coding

### Spacing
- Card padding: 16px (AppSpacing.md)
- Card margin: 8px (AppSpacing.sm)
- Amount font size: 20px (titleLarge)

### Colors
- Date header background: Surface variant
- Transaction cards: Surface
- Positive amounts: Success color
- Negative amounts: Error color

### Accessibility
- Contrast ratio: 4.5:1 (WCAG AA)
- Touch targets: 48x48px minimum
- Screen reader: Amount includes "spent" or "received"
```

### 4. Share Your Design

**Option A: GitHub Issue**
1. Create or comment on an issue
2. Upload images or attach files
3. Add your documentation
4. Invite feedback

**Option B: External Link**
1. Share Figma/Sketch link (make sure it's publicly accessible)
2. Create a GitHub issue with the link
3. Add context and documentation

**Option C: Pull Request** (for asset files)
If you're comfortable with Git:
1. Fork the repository
2. Add assets to `/assets/` directory
3. Create a pull request
4. Reference the design issue

## Design Guidelines

### 1. Follow Material Design 3

Centabit uses Material Design 3 as its foundation. Your designs should:
- Use Material 3 components when possible
- Follow Material color system
- Respect Material spacing and sizing
- Apply Material elevation and depth

**Reference**: [Material Design 3 Guidelines](https://m3.material.io/)

### 2. Maintain Consistency

- **Visual Language**: Maintain consistent style across screens
- **Component Reuse**: Use existing components before designing new ones
- **Spacing System**: Use AppSpacing tokens (xs, sm, md, lg, xl, xxl)
- **Border Radius**: Use AppRadius tokens (especially pill: 28px for buttons)

### 3. Design for Both Modes

Always provide light and dark mode versions:
- **Light Mode**: Clean, bright, spacious feel
- **Dark Mode**: True blacks for OLED, reduced eye strain
- **Surface Colors**: Use Material's surface and surface-variant
- **Text Colors**: Use on-surface colors for proper contrast

### 4. Consider Accessibility

**Color Contrast**: Minimum 4.5:1 for text, 3:1 for UI components
- Test with tools like [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)

**Touch Targets**: Minimum 44x44 points (iOS) or 48x48dp (Android)
- Buttons, icons, and interactive elements need adequate size
- Add invisible padding if visual design requires smaller elements

**Text Sizing**: Support dynamic type
- Don't design layouts that break with larger text
- Ensure critical info is visible at 200% zoom

**Screen Readers**: Consider non-visual experience
- Meaningful labels for icons
- Clear button purposes
- Logical reading order

### 5. Mobile-First Thinking

Centabit is primarily a mobile app:
- **Thumb Zones**: Place primary actions in easy-to-reach areas
- **One-Handed Use**: Critical functions accessible with thumb
- **Portrait Orientation**: Design for vertical layout first
- **Scroll vs. Multiple Screens**: Embrace scrolling over pagination

### 6. Financial App Considerations

**Clarity**: Money matters need to be crystal clear
- Large, readable numbers
- Clear currency formatting
- Obvious positive/negative values
- Unambiguous action buttons

**Trust**: Professional appearance builds confidence
- Clean, organized layouts
- Consistent styling
- No "toy-like" designs
- Serious but approachable tone

**Privacy**: Respect sensitive financial data
- Consider "privacy mode" designs
- Don't make balances TOO prominent in screenshots
- Quick exit/hide features for public settings

## Design Inspiration

Looking for inspiration? Check out these examples:

**Financial Apps**:
- YNAB (You Need A Budget)
- Mint
- PocketGuard
- Wallet by BudgetBakers

**Material Design 3 Apps**:
- Google Keep
- Google Calendar
- Gmail (Material You redesign)

**Design Systems**:
- [Material Design 3](https://m3.material.io/)
- [Apple Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [IBM Carbon Design System](https://carbondesignsystem.com/)

## Resources for Designers

### Design Tools

**Free Tools**:
- [Figma](https://figma.com) - Collaborative design (free tier available)
- [Material Theme Builder](https://m3.material.io/theme-builder) - Generate Material 3 themes
- [Material Icons](https://fonts.google.com/icons) - Free icon library
- [Unsplash](https://unsplash.com/) - Free images for mockups

**Color Tools**:
- [Coolors](https://coolors.co/) - Color palette generator
- [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/) - Accessibility testing
- [Material Color Tool](https://material.io/resources/color/) - Material palette generator

**Prototyping**:
- [Figma](https://figma.com) - Interactive prototypes
- [Principle](https://principleformac.com/) - Animation design
- [ProtoPie](https://www.protopie.io/) - Advanced interactions

### Learning Resources

**Material Design**:
- [Material Design 3 Documentation](https://m3.material.io/)
- [Material Design YouTube Channel](https://www.youtube.com/c/MaterialDesign)
- [Material Design Blog](https://material.io/blog)

**Accessibility**:
- [WebAIM](https://webaim.org/) - Web accessibility resources
- [A11y Project](https://www.a11yproject.com/) - Accessibility checklist
- [Inclusive Design Principles](https://inclusivedesignprinciples.org/)

**UI/UX Best Practices**:
- [Laws of UX](https://lawsofux.com/) - Psychology principles
- [Nielsen Norman Group](https://www.nngroup.com/) - UX research and articles
- [Refactoring UI](https://www.refactoringui.com/) - Practical design tips

## Working with Developers

### Effective Handoff

Make implementation easier for developers:

**Provide Specs**:
- Exact spacing values (use AppSpacing tokens)
- Color hex codes (reference theme colors)
- Font sizes and weights (use Material typography scale)
- Border radius values (use AppRadius tokens)

**Interactive Prototypes**:
- Show animations and transitions
- Demonstrate gesture interactions
- Clarify state changes

**Edge Cases**:
- What happens with long text?
- How does it look with no data?
- What about error states?
- How does scrolling work?

### Communication Tips

- **Be specific**: "Increase padding to 16px" vs. "Make it bigger"
- **Use examples**: Reference existing screens or components
- **Ask questions**: Not sure how something works? Just ask!
- **Be open to feedback**: Technical constraints may require adjustments
- **Iterate together**: Collaboration makes better products

## Common Design Tasks

### Designing a New Feature Screen

1. **Understand requirements**: What problem does this solve?
2. **Research**: Look at similar features in other apps
3. **Sketch**: Quick paper sketches of layout options
4. **Wireframe**: Low-fidelity digital wireframes
5. **Mockup**: High-fidelity designs with real content
6. **Prototype**: Show interactions and animations
7. **Document**: Write specs and rationale
8. **Share**: Post in GitHub issue for feedback

### Improving an Existing Screen

1. **Identify problems**: What's not working?
2. **Gather feedback**: Check issues, user comments
3. **Analyze**: Why is it problematic?
4. **Iterate**: Try multiple solutions
5. **Compare**: Show before and after
6. **Justify**: Explain why your solution is better
7. **Share**: Create GitHub issue with comparison

### Creating Icon Assets

1. **Design**: Create vector icon in SVG
2. **Size**: Design at 24x24dp base size
3. **Style**: Match Material icon style (rounded, outlined, sharp)
4. **Export**: Provide SVG and PNG (1x, 2x, 3x)
5. **Name**: Use clear, descriptive names (e.g., `ic_category_groceries.svg`)
6. **Document**: Explain usage and context

## Examples of Past Design Contributions

Here are examples of the types of design contributions we value:

### Example 1: Transaction Tile Redesign
**Problem**: Transaction list items were hard to scan
**Solution**: Redesigned with clearer hierarchy and better spacing
**Impact**: Improved readability and user satisfaction

### Example 2: Dark Mode Color Refinement
**Problem**: Dark mode felt too gray, lacked contrast
**Solution**: Adjusted surface colors, increased contrast
**Impact**: Better dark mode experience, reduced eye strain

### Example 3: Empty State Illustrations
**Problem**: Empty screens felt cold and unhelpful
**Solution**: Added friendly illustrations and helpful copy
**Impact**: Better first-time user experience

## Getting Feedback

Want feedback on your designs before formally submitting?

1. **Create a draft issue**: Share work-in-progress
2. **Ask specific questions**: "Does this hierarchy work?" vs. "What do you think?"
3. **Invite critique**: Welcome suggestions and alternatives
4. **Iterate**: Design is iterative—embrace multiple rounds

## Recognition

Design contributions are valued just as much as code contributions:
- Listed in contributors page
- Credited in release notes
- Acknowledged in design system documentation

## Questions?

- **Not sure where to start?** Look for issues tagged `good first issue` + `design`
- **Need clarification?** Comment on issues or create a new one
- **Want to chat?** Open a GitHub discussion

---

**Ready to contribute?** Browse [design issues](https://github.com/domain80/centabit_v0.5/issues?q=is%3Aissue+is%3Aopen+label%3Adesign) or create your own!

Thank you for helping make Centabit more beautiful and usable!
