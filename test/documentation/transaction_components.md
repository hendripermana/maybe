# Transaction Components Documentation

This document provides an overview of the modern transaction list components implemented as part of the UI/UX modernization project.

## Components Overview

### TransactionItemComponent

A modern, theme-aware component for displaying transaction items in a list.

**Features:**
- Theme-aware styling with proper hover and focus states
- Consistent spacing and alignment
- Proper accessibility attributes
- Support for different view contexts (global, account)
- Visual indicators for special transaction types (one-time, transfers)
- Merchant logo display with fallback icon

**Usage:**
```erb
<%= render TransactionItemComponent.new(
  entry: entry,
  selected: false,
  view_ctx: "global",
  balance_trend: nil
) %>
```

### TransactionItemSkeletonComponent

A loading state component that mimics the structure of TransactionItemComponent.

**Features:**
- Animated pulse effect
- Matches the layout of the actual transaction item
- Theme-aware styling
- Support for different view contexts

**Usage:**
```erb
<%= render TransactionItemSkeletonComponent.new(view_ctx: "global") %>
```

### SearchInputComponent

A modern search input component with theme-aware styling.

**Features:**
- Theme-aware styling with proper focus states
- Search icon
- Support for auto-submit behavior
- Customizable placeholder text

**Usage:**
```erb
<%= render SearchInputComponent.new(
  form: form,
  name: :search,
  placeholder: "Search transactions...",
  value: @q[:search],
  auto_submit: true
) %>
```

### FilterBadgeComponent

A component for displaying active filters with the ability to remove them.

**Features:**
- Theme-aware styling
- Clear button with proper accessibility attributes
- Consistent appearance across filter types

**Usage:**
```erb
<%= render FilterBadgeComponent.new(
  label: "Category: Food",
  param_key: "categories",
  param_value: "Food",
  clear_url: clear_filter_path
) %>
```

### SkeletonComponent

A versatile component for creating loading state placeholders.

**Features:**
- Multiple variants (rectangle, circle, text)
- Customizable dimensions
- Animated pulse effect
- Theme-aware styling

**Usage:**
```erb
<%= render SkeletonComponent.new(
  variant: :text,
  width: "80%",
  height: "24px",
  classes: "my-custom-class"
) %>
```

## Implementation Details

### Theme Consistency

All components use CSS variables and theme-aware classes to ensure proper appearance in both light and dark themes:

- Background colors use `bg-container`, `bg-container-hover`, etc.
- Text colors use `text-primary`, `text-secondary`, etc.
- Data attributes (`[data-theme=dark]`) are used for theme-specific overrides

### Accessibility Features

- Proper focus states with visible outlines
- ARIA labels on interactive elements
- Sufficient color contrast in both themes
- Keyboard navigation support

### Responsive Design

- Grid-based layout that adapts to different screen sizes
- Mobile-specific optimizations
- Proper spacing on all device sizes

### Performance Considerations

- Skeleton loading states to improve perceived performance
- Optimized rendering for large transaction lists
- Stimulus controller for managing loading states

## Testing

All components include comprehensive test coverage:

- Unit tests for component rendering and props
- System tests for interaction and integration
- Visual regression tests for theme switching

## Future Improvements

- Virtual scrolling for very large transaction lists
- Enhanced filter UI with more visual feedback
- Drag and drop reordering of transactions
- Inline editing capabilities