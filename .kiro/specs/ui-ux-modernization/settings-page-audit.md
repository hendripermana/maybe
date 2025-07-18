# Settings Page Audit

## Current Structure

### Layout
- Uses a dedicated `settings.html.erb` layout
- Two-column design with navigation sidebar on the left and content on the right
- Responsive design with different layouts for mobile and desktop
- Navigation footer with previous/next links for easy movement between settings pages

### Navigation
- Organized into sections (General, Transactions, Other)
- Uses a consistent navigation component (`_settings_nav.html.erb`)
- Includes navigation between settings pages with previous/next links
- Mobile-specific navigation with collapsible sections
- Active state highlighting for current page

### Content Structure
- Each settings page uses a consistent section component (`_section.html.erb`)
- Sections include title, optional subtitle, and content
- Form-heavy interfaces with various input types
- Consistent card-like containers for settings sections

### Settings Pages
- Profile settings (user information, household management)
- Preferences (language, currency, theme, etc.)
- Security settings
- API key management
- Self-hosting settings
- Billing settings
- And links to other sections (Accounts, Imports, Tags, Categories, etc.)

## Components Needing Modernization

### Form Components
- Currently using `styled_form_with` helper which is not using the modern Shadcn-inspired components
- Form inputs (text fields, selects, checkboxes) need to be replaced with modern alternatives
- Auto-submit forms need proper validation and error handling
- Form field spacing and alignment needs to be standardized
- Input labels need consistent styling and positioning

### Navigation Components
- Navigation items need consistent styling and hover/active states
- Mobile navigation needs better touch interactions
- Section headers could benefit from more modern styling
- Navigation icons need consistent sizing and alignment

### Layout Components
- The two-column layout could be improved for better responsiveness
- Spacing and alignment could be more consistent
- Card components for settings sections should use the modern Card component
- Mobile layout needs better use of available space

### Theme Controls
- Theme switcher needs to be updated to use the modern toggle component
- Theme previews could be enhanced with better visual feedback
- Theme selection needs better visual indication of current selection

### Button Components
- Various buttons (save, delete, etc.) should use the modern Button component
- Destructive actions need proper styling and confirmation dialogs
- Button sizing and spacing needs to be consistent

## Accessibility Issues

### Keyboard Navigation
- Need to ensure proper tab order and focus management
- Keyboard shortcuts need proper visual indicators
- Focus states need to be more visible and consistent

### Screen Reader Support
- Need to ensure proper ARIA attributes for navigation and form elements
- Form labels and error messages need to be properly associated with inputs
- Section headings need proper heading levels

### Color Contrast
- Need to ensure proper color contrast for text and UI elements
- Theme-aware styling needs to work correctly in both light and dark modes
- Status indicators need sufficient contrast in both themes

## Settings-Specific UI Patterns

### User Avatar Management
- Avatar upload and preview needs modernization
- Default avatar placeholder needs consistent styling

### Household Management
- User list needs consistent styling and better mobile layout
- Invitation management needs better visual hierarchy
- Role indicators need consistent styling

### Theme Selection
- Theme preview cards need consistent sizing and styling
- Selection indicators need to be more prominent

### Danger Zone Actions
- Destructive actions need clear visual separation
- Confirmation dialogs need better content and styling

## Recommendations

1. Replace all form inputs with modern Shadcn-inspired components
2. Implement consistent spacing and alignment throughout settings pages
3. Update navigation components with better hover and active states
4. Improve mobile layout for better touch interactions
5. Enhance theme switcher with better visual feedback
6. Standardize button styling and confirmation dialogs
7. Improve accessibility with proper ARIA attributes and focus management
8. Ensure consistent color contrast in both light and dark themes