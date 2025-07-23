# Navigation Components Documentation

## Overview

This document describes the modernized navigation components implemented as part of the UI/UX modernization project. These components provide consistent navigation experience across all pages of the application, with proper active state indicators and accessibility support.

## Components

### 1. Navigation Component (`Ui::NavigationComponent`)

The main navigation component that provides a consistent navigation experience across the application. It supports three variants:

- **Desktop**: Vertical sidebar navigation with icon-based navigation items
- **Mobile**: Top navigation bar and bottom tab bar for mobile devices
- **Sidebar**: Horizontal navigation items for use in sidebars

#### Usage

```erb
<%= render Ui::NavigationComponent.new(
  current_path: request.path,
  variant: :desktop
) %>
```

#### Properties

- `current_path`: The current path to determine active navigation items
- `variant`: The navigation variant to render (`:desktop`, `:mobile`, or `:sidebar`)

### 2. Navigation Item Component (`Ui::NavigationItemComponent`)

Individual navigation item with consistent styling and active state indicators.

#### Usage

```erb
<%= render Ui::NavigationItemComponent.new(
  name: "Home",
  path: root_path,
  icon: "home",
  icon_custom: false,
  active: page_active?(root_path),
  color_classes: color_classes_for_item
) %>
```

#### Properties

- `name`: The display name of the navigation item
- `path`: The URL path for the navigation item
- `icon`: The icon name to display
- `icon_custom`: Whether the icon is a custom icon
- `active`: Whether the navigation item is active
- `color_classes`: The color classes for the navigation item
- `variant`: The variant of the navigation item (default or sidebar)

### 3. Breadcrumbs Component (`Ui::BreadcrumbsComponent`)

Displays a breadcrumb trail showing the current page location in the application hierarchy.

#### Usage

```erb
<%= render Ui::BreadcrumbsComponent.new(
  breadcrumbs: [
    ["Home", root_path],
    ["Transactions", transactions_path],
    ["Details", nil]
  ]
) %>
```

#### Properties

- `breadcrumbs`: An array of name/path pairs representing the breadcrumb trail

## Accessibility Features

The navigation components include the following accessibility features:

1. **ARIA Attributes**:
   - `aria-current="page"` for active navigation items
   - `aria-label` for navigation sections
   - `role="menubar"` and `role="menuitem"` for navigation lists and items

2. **Keyboard Navigation**:
   - Tab navigation to focus on navigation items
   - Arrow key navigation between items
   - Enter/Space to activate navigation items

3. **Screen Reader Support**:
   - Proper labeling of navigation sections
   - Hidden elements marked with `aria-hidden="true"`
   - Semantic HTML structure with proper roles

4. **Focus Management**:
   - Visible focus indicators for keyboard navigation
   - Consistent focus styles across themes

## Theme Support

The navigation components fully support both light and dark themes:

1. **Color Variables**:
   - All colors use CSS variables or theme-aware Tailwind classes
   - No hardcoded colors that would break in different themes

2. **Active State Indicators**:
   - Theme-aware active state indicators
   - Proper contrast in both light and dark modes

3. **Hover States**:
   - Consistent hover states across themes
   - Theme-specific hover colors for better visibility

## Responsive Behavior

The navigation components adapt to different screen sizes:

1. **Desktop**:
   - Vertical sidebar navigation
   - Icon-based navigation items with labels
   - Collapsible sidebar support

2. **Mobile**:
   - Top navigation bar with logo and menu
   - Bottom tab bar for primary navigation
   - Touch-friendly tap targets

## Testing

The navigation components include comprehensive tests:

1. **System Tests**:
   - Tests for correct active states
   - Tests for navigation between pages
   - Tests for keyboard navigation

2. **Component Tests**:
   - Tests for proper rendering of variants
   - Tests for accessibility compliance
   - Tests for theme switching

## Integration with Existing Code

The navigation components integrate with the existing application:

1. **ViewComponent Architecture**:
   - Follows the existing ViewComponent pattern
   - Compatible with the existing component library

2. **Stimulus Controllers**:
   - Uses Stimulus for interactive behavior
   - Integrates with existing JavaScript architecture

3. **Tailwind CSS**:
   - Uses Tailwind utility classes for styling
   - Compatible with the existing design system