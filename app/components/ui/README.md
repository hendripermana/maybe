# UI Component Library

A modern, Shadcn-inspired component library built with ViewComponent and CSS variables for consistent theming across light and dark modes.

## Overview

This component library provides a set of reusable UI components that follow modern design principles and accessibility standards. All components are built using CSS variables from the Maybe design system, ensuring consistent theming and easy maintenance.

## Key Features

- **Theme Consistency**: All components use CSS variables for seamless light/dark mode switching
- **Accessibility**: Built with WCAG 2.1 AA compliance in mind
- **Modern Design**: Shadcn-inspired styling with clean, professional aesthetics
- **ViewComponent Architecture**: Leverages Rails ViewComponent for maintainable, testable components
- **Comprehensive Documentation**: Full Lookbook integration with interactive examples

## Available Components

### AlertComponent

Alert component for displaying messages with different variants:

**Variants:**
- `default` - Standard gray alert
- `info` - Blue informational alert
- `success` - Green success alert
- `warning` - Yellow warning alert
- `destructive` - Red error alert

**Sizes:**
- `sm` - Small alert (p-3)
- `md` - Medium alert (p-4) - default
- `lg` - Large alert (p-5)

**Features:**
- Optional title
- Dismissible alerts
- Icon indicators
- Theme-aware styling

**Usage:**
```ruby
# Basic alert
render Ui::AlertComponent.new(variant: :info) { "This is an informational message" }

# Alert with title
render Ui::AlertComponent.new(
  title: "Success!",
  variant: :success
) { "Your changes have been saved." }

# Dismissible alert
render Ui::AlertComponent.new(
  variant: :warning,
  dismissible: true
) { "Please review your information before continuing." }
```

### AccountCardComponent

Component for displaying account information:

**Variants:**
- `default` - Standard card styling
- `primary` - Primary color styling
- `success` - Success color styling
- `warning` - Warning color styling
- `destructive` - Destructive color styling

**Sizes:**
- `sm` - Small card (p-3)
- `md` - Medium card (p-4) - default
- `lg` - Large card (p-5)

**Features:**
- Account type icon
- Institution name
- Balance display
- Available balance (when applicable)
- Action menu
- Theme-aware styling

**Usage:**
```ruby
# Basic account card
render Ui::AccountCardComponent.new(account: @checking_account)

# Account card without balance
render Ui::AccountCardComponent.new(
  account: @investment_account,
  show_balance: false
)

# Account card with custom variant
render Ui::AccountCardComponent.new(
  account: @savings_account,
  variant: :primary
)
```

### AvatarComponent

Component for displaying user or entity images:

**Variants:**
- `default` - Standard avatar styling
- `primary` - Primary color styling
- `success` - Success color styling
- `warning` - Warning color styling
- `destructive` - Destructive color styling

**Sizes:**
- `xs` - Extra small avatar (w-6 h-6)
- `sm` - Small avatar (w-8 h-8)
- `md` - Medium avatar (w-10 h-10) - default
- `lg` - Large avatar (w-12 h-12)
- `xl` - Extra large avatar (w-16 h-16)

**Features:**
- Image display
- Fallback initials
- Theme-aware styling

**Usage:**
```ruby
# Avatar with image
render Ui::AvatarComponent.new(
  src: user.avatar_url,
  alt: user.name
)

# Avatar with initials fallback
render Ui::AvatarComponent.new(
  alt: "John Doe",
  size: :lg
)

# Avatar with custom variant
render Ui::AvatarComponent.new(
  alt: "John Doe",
  variant: :primary
)
```

### BalanceDisplayComponent

Component for displaying financial balances:

**Variants:**
- `default` - Automatic color based on amount (green for positive, red for negative)
- `primary` - Primary color styling
- `success` - Success color styling
- `warning` - Warning color styling
- `destructive` - Destructive color styling

**Sizes:**
- `xs` - Extra small text
- `sm` - Small text
- `md` - Medium text (default)
- `lg` - Large text
- `xl` - Extra large text
- `2xl` - 2XL text
- `3xl` - 3XL text

**Features:**
- Formatted currency display
- Optional sign display
- Optional indicator icon
- Theme-aware styling

**Usage:**
```ruby
# Basic balance display
render Ui::BalanceDisplayComponent.new(amount: 1250.75)

# Negative balance
render Ui::BalanceDisplayComponent.new(amount: -450.25)

# With currency and sign
render Ui::BalanceDisplayComponent.new(
  amount: 1250.75,
  currency: "EUR",
  show_sign: true
)

# With indicator and custom size
render Ui::BalanceDisplayComponent.new(
  amount: 1250.75,
  show_indicator: true,
  size: :xl
)
```

### BadgeComponent

### BaseComponent

The foundation class for all UI components, providing:
- Consistent size and variant handling
- CSS class building utilities
- Data attribute management
- Theme-aware helper methods

### ButtonComponent

Modern button component with multiple variants and states:

**Variants:**
- `primary` - Main action button with primary color
- `secondary` - Secondary action button with muted styling
- `destructive` - Dangerous actions with red styling
- `outline` - Button with border and transparent background
- `ghost` - Minimal button with hover effects
- `link` - Text-only button with underline on hover

**Sizes:**
- `sm` - Small button (h-9)
- `md` - Medium button (h-10) - default
- `lg` - Large button (h-11)
- `xl` - Extra large button (h-12)

**Features:**
- Loading states with spinner
- Icon support (left/right positioning)
- Full width option
- Link functionality
- Disabled states

**Usage:**
```ruby
# Basic button
render Ui::ButtonComponent.new(variant: :primary) { "Click me" }

# Button with icon and loading state
render Ui::ButtonComponent.new(
  variant: :primary,
  icon: "plus",
  loading: true,
  full_width: true
) { "Save Changes" }

# Link button
render Ui::ButtonComponent.new(
  href: "/dashboard",
  variant: :outline
) { "Go to Dashboard" }
```

### CardComponent

Flexible card component for content containers:

**Variants:**
- `default` - Standard card with shadow
- `elevated` - Enhanced shadow for emphasis
- `outlined` - Border instead of shadow
- `ghost` - No background or border
- `interactive` - Hover effects for clickable cards

**Sizes:**
- `sm` - Compact padding (p-4)
- `md` - Standard padding (p-6) - default
- `lg` - Spacious padding (p-8)
- `xl` - Maximum padding (p-10)

**Features:**
- Header, content, and footer sections
- Clickable card support
- Custom content slots
- Theme-aware styling

**Usage:**
```ruby
# Basic card
render Ui::CardComponent.new(
  title: "Card Title",
  description: "Card description text"
)

# Interactive card with footer
render Ui::CardComponent.new(
  variant: :interactive,
  href: "/details"
) do |card|
  card.with_footer do
    render Ui::ButtonComponent.new(variant: :primary) { "Learn More" }
  end
  "Card content goes here"
end
```

### InputComponent

Comprehensive form input component:

**Types:**
- `text` - Standard text input
- `email` - Email input with validation
- `password` - Password input
- `number` - Numeric input
- `date` - Date picker
- `textarea` - Multi-line text input
- `select` - Dropdown selection

**Variants:**
- `default` - Standard input styling
- `outline` - Visible border styling
- `ghost` - Minimal border styling
- `filled` - Background fill styling

**Sizes:**
- `sm` - Compact input (h-8)
- `md` - Standard input (h-10) - default
- `lg` - Large input (h-12)
- `xl` - Extra large input (h-14)

**Features:**
- Label and help text support
- Error state handling
- Required field indicators
- Disabled and readonly states

**Usage:**
```ruby
# Basic input
render Ui::InputComponent.new(
  label: "Email Address",
  type: "email",
  placeholder: "user@example.com",
  required: true
)

# Select input
render Ui::InputComponent.new(
  type: "select",
  label: "Category",
  required: true
) do
  concat content_tag(:option, "Select...", value: "")
  concat content_tag(:option, "Food", value: "food")
  concat content_tag(:option, "Transport", value: "transport")
end

# Input with error
render Ui::InputComponent.new(
  label: "Username",
  value: "invalid-user",
  error: "Username must be at least 3 characters"
)
```

### ModalComponent

Accessible modal dialog component:

**Variants:**
- `default` - Standard modal
- `centered` - Centered modal
- `fullscreen` - Full screen modal

**Sizes:**
- `sm` - Small modal (max-w-md)
- `md` - Medium modal (max-w-lg) - default
- `lg` - Large modal (max-w-2xl)
- `xl` - Extra large modal (max-w-4xl)
- `full` - Full width modal (max-w-7xl)

**Features:**
- Keyboard navigation (ESC to close)
- Backdrop click to close (configurable)
- Header, content, and footer sections
- Focus management
- Stimulus controller integration

**Usage:**
```ruby
# Basic modal
render Ui::ModalComponent.new(
  title: "Confirm Action",
  description: "Are you sure?",
  open: true,
  data: { controller: "ui--modal" }
) do |modal|
  modal.with_footer do
    content_tag(:div, class: "flex space-x-2") do
      concat render(Ui::ButtonComponent.new(variant: :ghost) { "Cancel" })
      concat render(Ui::ButtonComponent.new(variant: :destructive) { "Delete" })
    end
  end
  "This action cannot be undone."
end
```

### SeparatorComponent

Component for visually dividing content:

**Orientations:**
- `horizontal` - Horizontal divider (default)
- `vertical` - Vertical divider

**Variants:**
- `default` - Standard gray separator
- `primary` - Primary color separator
- `success` - Success color separator
- `warning` - Warning color separator
- `destructive` - Destructive color separator

**Features:**
- Decorative or semantic divider
- Theme-aware styling

**Usage:**
```ruby
# Basic horizontal separator
render Ui::SeparatorComponent.new

# Vertical separator
render Ui::SeparatorComponent.new(orientation: :vertical)

# Semantic separator (not decorative)
render Ui::SeparatorComponent.new(decorative: false)

# Custom variant
render Ui::SeparatorComponent.new(variant: :primary)
```

### SkeletonComponent

Component for loading states:

**Variants:**
- `default` - Standard gray skeleton
- `primary` - Primary color skeleton
- `success` - Success color skeleton
- `warning` - Warning color skeleton
- `destructive` - Destructive color skeleton

**Features:**
- Custom width and height
- Rounded corners (optional)
- Animation (optional)
- Theme-aware styling

**Usage:**
```ruby
# Basic skeleton
render Ui::SkeletonComponent.new(width: "100%", height: "20px")

# Multiple skeletons for loading state
content_tag(:div, class: "space-y-2") do
  concat render(Ui::SkeletonComponent.new(width: "70%", height: "24px"))
  concat render(Ui::SkeletonComponent.new(width: "100%", height: "16px"))
  concat render(Ui::SkeletonComponent.new(width: "90%", height: "16px"))
end

# Custom variant without animation
render Ui::SkeletonComponent.new(
  width: "120px",
  height: "32px",
  variant: :primary,
  animate: false
)
```

### TooltipComponent

Component for displaying additional information on hover:

**Positions:**
- `top` - Above the element (default)
- `bottom` - Below the element
- `left` - To the left of the element
- `right` - To the right of the element

**Variants:**
- `default` - Standard dark tooltip
- `primary` - Primary color tooltip
- `success` - Success color tooltip
- `warning` - Warning color tooltip
- `destructive` - Destructive color tooltip

**Features:**
- Customizable delay for show/hide
- Theme-aware styling
- Stimulus controller integration

**Usage:**
```ruby
# Basic tooltip
render Ui::TooltipComponent.new(text: "Additional information") do
  content_tag(:button, "Hover me")
end

# Tooltip with custom position and delay
render Ui::TooltipComponent.new(
  text: "Click to delete",
  position: :right,
  variant: :destructive,
  delay_show: 500
) do
  render Ui::ButtonComponent.new(variant: :ghost, icon: "trash") { "Delete" }
end
```

### TransactionBadgeComponent

Component for displaying transaction types and statuses:

**Transaction Types:**
- `income` - Income transaction
- `expense` - Expense transaction
- `transfer` - Transfer transaction
- `investment` - Investment transaction
- `refund` - Refund transaction
- `adjustment` - Adjustment transaction

**Transaction Statuses:**
- `pending` - Pending transaction
- `cleared` - Cleared transaction
- `reconciled` - Reconciled transaction
- `void` - Void transaction

**Sizes:**
- `sm` - Small badge (default)
- `md` - Medium badge
- `lg` - Large badge

**Features:**
- Icon indicators (optional)
- Custom labels
- Theme-aware styling

**Usage:**
```ruby
# Transaction type badge
render Ui::TransactionBadgeComponent.new(transaction_type: :income)

# Transaction status badge
render Ui::TransactionBadgeComponent.new(transaction_status: :pending)

# Custom badge
render Ui::TransactionBadgeComponent.new(
  custom_label: "Recurring",
  show_icon: false,
  size: :md
)
```

## CSS Variables Integration

All components use CSS variables from the Maybe design system for consistent theming:

```css
/* Primary colors */
--color-primary
--color-primary-foreground
--color-secondary
--color-secondary-foreground

/* Background colors */
--color-background
--color-foreground
--color-card
--color-card-foreground

/* Border and input colors */
--color-border
--color-input
--color-ring

/* Text colors */
--color-muted-foreground
--color-destructive
```

## Accessibility Features

- **Keyboard Navigation**: All interactive components support keyboard navigation
- **Screen Reader Support**: Proper ARIA labels and semantic HTML
- **Focus Management**: Visible focus indicators and logical tab order
- **Color Contrast**: WCAG AA compliant color combinations
- **Reduced Motion**: Respects user motion preferences

## Lookbook Integration

All components include comprehensive Lookbook previews with:
- Interactive parameter controls
- Multiple usage examples
- Theme switching demonstrations
- Accessibility testing scenarios

Access the component library at `/lookbook` in development mode.

## Testing

Components include:
- Unit tests for component logic
- Visual regression tests for theme consistency
- Accessibility tests for compliance
- Integration tests for complex interactions

## Development Guidelines

### Creating New Components

1. Extend `Ui::BaseComponent` for consistent behavior
2. Use CSS variables for all color values
3. Include comprehensive size and variant options
4. Add proper accessibility attributes
5. Create Lookbook previews with examples
6. Write unit tests for component logic

### Styling Guidelines

1. Use CSS variables instead of hardcoded colors
2. Follow Shadcn design patterns for consistency
3. Ensure proper contrast ratios in both themes
4. Use semantic class names
5. Minimize use of `!important` declarations

### Component Structure

```ruby
module Ui
  class NewComponent < BaseComponent
    VARIANTS = {
      default: "default-classes",
      # ... other variants
    }.freeze

    SIZES = {
      sm: "small-classes",
      md: "medium-classes",
      lg: "large-classes"
    }.freeze

    def initialize(variant: :default, size: :md, **options)
      super(variant: variant, size: size, **options)
      # Component-specific initialization
    end

    def call
      # Component rendering logic
    end

    private

    def variant_classes
      VARIANTS[@variant] || VARIANTS[:default]
    end

    def size_classes
      SIZES[@size] || SIZES[:md]
    end
  end
end
```

## Migration from Legacy Components

When migrating from legacy components:

1. Identify equivalent UI component variants
2. Update class names to use CSS variables
3. Test theme switching functionality
4. Verify accessibility compliance
5. Update any custom styling to use design tokens

## Contributing

1. Follow the established patterns and conventions
2. Include comprehensive tests and documentation
3. Ensure accessibility compliance
4. Test in both light and dark themes
5. Add Lookbook previews for new components

## Support

For questions or issues with the component library:
1. Check the Lookbook documentation
2. Review existing component implementations
3. Consult the Maybe design system documentation
4. Create an issue with detailed reproduction steps