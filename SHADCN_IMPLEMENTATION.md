# Shadcn UI Implementation in Maybe Dashboard

This document outlines the implementation of shadcn-ui components in the Maybe personal finance application, integrated with the existing design system.

## Overview

The implementation provides shadcn-ui style components that are fully integrated with the existing Maybe design system, maintaining consistency while adding modern UI patterns.

## Components Implemented

### 1. Button Component (`Ui::ShadcnButtonComponent`)
- **Variants**: default, secondary, destructive, outline, ghost, link
- **Sizes**: sm, default, lg, icon
- **Features**: Disabled state, icon support, focus states

### 2. Card Component (`Ui::ShadcnCardComponent`)
- **Slots**: header, content, footer
- **Features**: Flexible layout, consistent spacing

### 3. Input Component (`Ui::ShadcnInputComponent`)
- **Types**: All HTML input types
- **Features**: Focus states, disabled state, placeholder support

### 4. Label Component (`Ui::ShadcnLabelComponent`)
- **Features**: Associated with inputs, proper accessibility

### 5. Badge Component (`Ui::ShadcnBadgeComponent`)
- **Variants**: default, secondary, destructive, outline
- **Features**: Rounded design, color variants

### 6. Alert Component (`Ui::ShadcnAlertComponent`)
- **Variants**: default, destructive
- **Slots**: title, description
- **Features**: Semantic structure, icon support

### 7. Tabs Component (`Ui::ShadcnTabsComponent`)
- **Features**: Interactive tabs with Stimulus controller
- **Accessibility**: Proper ARIA attributes

### 8. Dialog Component (`Ui::ShadcnDialogComponent`)
- **Slots**: trigger, header, content, footer
- **Features**: Modal behavior, backdrop, animations

## Design System Integration

### Color Tokens
The implementation uses semantic color tokens that map to the existing Maybe design system:

```css
--background: var(--color-white);
--foreground: var(--color-black);
--primary: var(--color-blue-600);
--secondary: var(--color-gray-100);
--muted: var(--color-gray-50);
--accent: var(--color-gray-50);
--destructive: var(--color-red-600);
--border: var(--color-gray-200);
--input: var(--color-gray-200);
--ring: var(--color-blue-600);
```

### Dark Mode Support
All components support dark mode through the existing `[data-theme="dark"]` system.

### Animations
Custom animations are included for smooth interactions:
- Fade in/out
- Zoom in/out
- Slide animations
- Consistent timing (150ms) and easing

## Usage Examples

### Basic Button
```erb
<%= render Ui::ShadcnButtonComponent.new do %>
  Click me
<% end %>
```

### Button with Variant and Size
```erb
<%= render Ui::ShadcnButtonComponent.new(variant: :outline, size: :lg) do %>
  Large Outline Button
<% end %>
```

### Card with Header and Footer
```erb
<%= render Ui::ShadcnCardComponent.new do |card| %>
  <% card.header do %>
    <h3>Card Title</h3>
  <% end %>
  <% card.content do %>
    <p>Card content here</p>
  <% end %>
  <% card.footer do %>
    <%= render Ui::ShadcnButtonComponent.new(size: :sm) do %>
      Action
    <% end %>
  <% end %>
<% end %>
```

### Form with Input and Label
```erb
<%= render Ui::ShadcnLabelComponent.new(for_attribute: "email") do %>
  Email Address
<% end %>
<%= render Ui::ShadcnInputComponent.new(
  type: :email,
  placeholder: "Enter your email",
  id: "email"
) %>
```

### Interactive Tabs
```erb
<%= render Ui::ShadcnTabsComponent.new(default_value: "account") do |tabs| %>
  <% tabs.tab(value: "account") do %>
    Account
  <% end %>
  <% tabs.tab(value: "settings") do %>
    Settings
  <% end %>
<% end %>
```

### Modal Dialog
```erb
<%= render Ui::ShadcnDialogComponent.new do |dialog| %>
  <% dialog.trigger do %>
    <%= render Ui::ShadcnButtonComponent.new do %>
      Open Dialog
    <% end %>
  <% end %>
  <% dialog.header do %>
    <h3>Dialog Title</h3>
  <% end %>
  <% dialog.content do %>
    <p>Dialog content here</p>
  <% end %>
  <% dialog.footer do %>
    <div class="flex gap-2">
      <%= render Ui::ShadcnButtonComponent.new(variant: :outline, size: :sm) do %>
        Cancel
      <% end %>
      <%= render Ui::ShadcnButtonComponent.new(size: :sm) do %>
        Confirm
      <% end %>
    </div>
  <% end %>
<% end %>
```

## JavaScript Integration

### Stimulus Controllers
- `shadcn-tabs-controller.js`: Handles tab switching
- `shadcn-dialog-controller.js`: Handles modal behavior

### Utility Functions
- `cn.js`: Class name merging utility using `clsx` and `tailwind-merge`

## Dependencies

The implementation adds the following npm dependencies:
- `@radix-ui/*`: Radix UI primitives for accessibility
- `class-variance-authority`: For component variants
- `clsx`: For conditional class names
- `tailwind-merge`: For merging Tailwind classes
- `lucide-react`: For icons (optional)
- `tailwindcss-animate`: For animations

## Demo Page

A demo page is available at `/shadcn_demo` to showcase all components and their variants.

## Migration Guide

### From Existing Components
The shadcn components are designed to work alongside existing Maybe components. You can gradually migrate:

1. **Buttons**: Replace `ButtonComponent` with `Ui::ShadcnButtonComponent` for new features
2. **Cards**: Use `Ui::ShadcnCardComponent` for new layouts
3. **Forms**: Use shadcn input and label components for new forms

### Best Practices
1. Use semantic color tokens (e.g., `bg-primary` instead of `bg-blue-600`)
2. Leverage the `cn()` utility for conditional classes
3. Follow the existing design system patterns
4. Test components in both light and dark modes

## Future Enhancements

Potential additions to the shadcn implementation:
- Select component with dropdown
- Checkbox and radio components
- Progress bars
- Toast notifications
- Tooltips
- Accordion components
- Data table components

## Contributing

When adding new shadcn components:
1. Follow the existing naming convention (`Ui::Shadcn*Component`)
2. Include proper accessibility attributes
3. Support both light and dark modes
4. Add to the demo page
5. Update this documentation 