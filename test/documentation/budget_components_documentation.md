# Budget Components Documentation

This document provides an overview of the modern budget components created as part of the UI/UX modernization project.

## Components Overview

### ProgressBar Component

The `UI::ProgressBarComponent` is a versatile progress indicator that can be used to show budget utilization, allocation progress, or any other percentage-based metric.

#### Features

- **Multiple Variants**: Supports default, success, warning, and danger variants with appropriate colors
- **Size Options**: Available in small, medium, and large sizes
- **Accessibility**: Includes proper ARIA attributes for screen readers
- **Optional Labels**: Can display a label and percentage text
- **Animation**: Smooth transitions when values change
- **Theme Support**: Uses theme-aware colors for all variants

#### Usage

```erb
<%= render UI::ProgressBarComponent.new(
  value: 75,
  max: 100,
  variant: :success,
  size: :md,
  animated: true,
  show_label: true,
  label: "Budget Progress"
) %>
```

### BudgetCard Component

The `UI::BudgetCardComponent` is a comprehensive card for displaying budget category information with visual status indicators.

#### Features

- **Status Indicators**: Color-coded text and progress bars for under budget, on budget, and over budget states
- **Visual Icons**: Displays category icons or generates text-based icons
- **Progress Visualization**: Shows spending progress relative to budget
- **Responsive Design**: Works well on all screen sizes
- **Theme Support**: Uses theme-aware colors for all elements
- **Accessibility**: Proper contrast and semantic HTML structure

#### Usage

```erb
<%= render UI::BudgetCardComponent.new(
  budget_category: budget_category
) %>
```

## Implementation Details

### Theme Integration

Both components use CSS variables and theme-aware color classes to ensure consistent appearance in both light and dark themes:

- Text colors use semantic classes like `text-foreground` and `text-muted-foreground`
- Background colors use `bg-card` and other theme variables
- Status indicators use consistent color coding across the application

### Accessibility Considerations

1. **Color Contrast**: All text meets WCAG AA contrast requirements in both themes
2. **Screen Reader Support**: Progress bars include proper ARIA attributes
3. **Keyboard Navigation**: All interactive elements are keyboard accessible
4. **Status Communication**: Status is conveyed through both color and text

### Responsive Behavior

- Cards maintain readability on all screen sizes
- Touch targets are appropriately sized for mobile use
- Layout adjusts gracefully on smaller screens

## Usage Guidelines

### When to Use ProgressBar

- To show budget utilization percentage
- To display allocation progress during budget setup
- To visualize goal progress
- For any percentage-based metric that needs visual representation

### When to Use BudgetCard

- For displaying budget category information in lists or grids
- When showing budget status with visual indicators is important
- For consistent presentation of budget categories with their spending status

### Best Practices

1. **Consistent Status Indicators**: Use the same color coding throughout the application
2. **Clear Labels**: Always provide clear context for progress bars
3. **Appropriate Variants**: Use success/warning/danger variants appropriately to convey status
4. **Hierarchy**: Use proper visual hierarchy for parent/child budget categories

## Theme Customization

The components use the following CSS variables that can be customized in the theme:

```css
/* Progress Bar Variables */
--color-primary: Used for default progress
--color-green-500: Used for success/under budget
--color-yellow-500: Used for warning/on budget
--color-red-500: Used for danger/over budget
--color-muted: Used for the progress bar background

/* Card Variables */
--color-card: Card background color
--color-border: Card border color
--color-foreground: Main text color
--color-muted-foreground: Secondary text color
```