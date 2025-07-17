# CSS Variable System Documentation

## Overview

The Maybe Finance application now uses a comprehensive CSS variable system for theme consistency. This system provides semantic color tokens that automatically adapt between light and dark themes, ensuring a consistent user experience across all components.

## Architecture

### Semantic Color Tokens

The system is built around semantic color tokens rather than hardcoded color values:

```css
/* Instead of hardcoded colors */
.old-way {
  background: #ffffff;
  color: #000000;
}

/* Use semantic tokens */
.new-way {
  background: var(--color-background);
  color: var(--color-text-primary);
}
```

### Theme Structure

#### Light Theme (Default)
- Background: White/light grays
- Text: Dark colors for contrast
- Surfaces: Light grays
- Borders: Subtle gray borders

#### Dark Theme
- Background: Dark grays/black
- Text: Light colors for contrast  
- Surfaces: Medium grays
- Borders: Lighter gray borders

## Available CSS Variables

### Background Colors
```css
--color-background      /* Main page background */
--color-surface         /* Card/surface backgrounds */
--color-surface-hover   /* Hover state for surfaces */
--color-surface-inset   /* Inset/recessed surfaces */
--color-container       /* Container backgrounds */
--color-container-hover /* Container hover states */
--color-container-inset /* Inset containers */
```

### Text Colors
```css
--color-text-primary    /* Primary text color */
--color-text-secondary  /* Secondary text color */
--color-text-tertiary   /* Tertiary text color */
--color-text-subdued    /* Subdued/muted text */
--color-text-inverse    /* Inverse text color */
--color-text-link       /* Link text color */
```

### Interactive Colors
```css
--color-primary         /* Primary action color */
--color-primary-hover   /* Primary hover state */
--color-primary-active  /* Primary active state */
--color-primary-foreground /* Text on primary background */

--color-secondary       /* Secondary action color */
--color-secondary-hover /* Secondary hover state */
--color-secondary-active /* Secondary active state */
--color-secondary-foreground /* Text on secondary background */
```

### Status Colors
```css
--color-success         /* Success state color */
--color-warning         /* Warning state color */
--color-destructive     /* Error/destructive color */
--color-info            /* Information color */
```

### Border and Input Colors
```css
--color-border          /* Standard border color */
--color-border-hover    /* Border hover state */
--color-input           /* Input field borders */
--color-ring            /* Focus ring color */
```

### Component Colors
```css
--color-card            /* Card backgrounds */
--color-card-foreground /* Text on cards */
--color-popover         /* Popover backgrounds */
--color-tooltip         /* Tooltip backgrounds */
```

### Shadow System
```css
--shadow-elevated       /* Subtle elevation shadow */
--shadow-floating       /* Medium floating shadow */
--shadow-modal          /* Strong modal shadow */
--shadow-glow           /* Focus glow effect */
```

### Spacing System
```css
--spacing-1 through --spacing-96  /* Consistent spacing scale */
--radius-sm through --radius-full /* Border radius scale */
```

## Usage Examples

### Basic Component Styling
```css
.my-component {
  background: var(--color-card);
  color: var(--color-text-primary);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-lg);
  padding: var(--spacing-4);
  box-shadow: var(--shadow-elevated);
}

.my-component:hover {
  background: var(--color-surface-hover);
  box-shadow: var(--shadow-floating);
}
```

### Button Components
```css
.btn-primary {
  background: var(--color-primary);
  color: var(--color-primary-foreground);
  border: none;
  border-radius: var(--radius-lg);
  padding: var(--spacing-2) var(--spacing-4);
}

.btn-primary:hover {
  background: var(--color-primary-hover);
}

.btn-primary:active {
  background: var(--color-primary-active);
}
```

### Form Elements
```css
.input-field {
  background: var(--color-container);
  color: var(--color-text-primary);
  border: 1px solid var(--color-border);
  border-radius: var(--radius-md);
  padding: var(--spacing-2) var(--spacing-3);
}

.input-field:focus {
  border-color: var(--color-ring);
  box-shadow: 0 0 0 2px var(--color-ring);
}

.input-field::placeholder {
  color: var(--color-text-subdued);
}
```

## Theme Switching

### JavaScript API
```javascript
// Toggle theme
document.documentElement.setAttribute('data-theme', 'dark');
document.documentElement.setAttribute('data-theme', 'light');

// Listen for theme changes
document.addEventListener('theme:changed', (event) => {
  console.log('Theme changed to:', event.detail.theme);
});
```

### Stimulus Controller
```html
<div data-controller="theme" data-theme-user-preference-value="system">
  <button data-action="click->theme#toggle">Toggle Theme</button>
</div>
```

## Migration Guide

### From Hardcoded Colors
```css
/* Before */
.old-component {
  background: #ffffff;
  color: #000000;
  border: 1px solid #e5e5e5;
}

[data-theme="dark"] .old-component {
  background: #1a1a1a !important;
  color: #ffffff !important;
  border-color: #374151 !important;
}

/* After */
.new-component {
  background: var(--color-card);
  color: var(--color-text-primary);
  border: 1px solid var(--color-border);
}
```

### From Tailwind Classes
```html
<!-- Before -->
<div class="bg-white text-gray-900 border-gray-200">
  Content
</div>

<!-- After -->
<div class="bg-container text-primary border-secondary">
  Content
</div>
```

## Best Practices

### 1. Use Semantic Tokens
Always use semantic color tokens instead of specific color values:
```css
/* Good */
color: var(--color-text-primary);

/* Avoid */
color: var(--color-gray-900);
```

### 2. Avoid !important
The CSS variable system eliminates the need for `!important` declarations:
```css
/* Good */
.component {
  background: var(--color-card);
}

/* Avoid */
.component {
  background: #ffffff !important;
}
```

### 3. Use Consistent Spacing
Use the spacing scale for consistent layouts:
```css
/* Good */
padding: var(--spacing-4) var(--spacing-6);
margin-bottom: var(--spacing-8);

/* Avoid */
padding: 16px 24px;
margin-bottom: 32px;
```

### 4. Leverage Shadow System
Use the predefined shadow system for consistent elevation:
```css
/* Good */
box-shadow: var(--shadow-elevated);

/* Avoid */
box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
```

## Testing

### Manual Testing
1. Visit `/theme-test.html` to test the theme system
2. Toggle between light and dark themes
3. Verify all components adapt correctly

### Automated Testing
```ruby
# System test example
test "theme switching works correctly" do
  visit "/dashboard"
  
  # Test light theme
  assert_selector "html[data-theme='light']"
  
  # Toggle to dark theme
  click_button "Toggle theme"
  assert_selector "html[data-theme='dark']"
  
  # Verify components adapt
  assert_no_selector ".bg-white", visible: true
end
```

## Troubleshooting

### Common Issues

1. **Colors not changing**: Ensure you're using CSS variables, not hardcoded values
2. **Flashing during theme switch**: Add transition classes for smooth switching
3. **Inconsistent shadows**: Use the predefined shadow variables
4. **Missing hover states**: Implement hover variants using CSS variables

### Debug Tools
```javascript
// Check current theme
console.log(document.documentElement.getAttribute('data-theme'));

// Check CSS variable value
console.log(getComputedStyle(document.documentElement).getPropertyValue('--color-primary'));

// List all CSS variables
const styles = getComputedStyle(document.documentElement);
const cssVars = Array.from(styles).filter(prop => prop.startsWith('--'));
console.log(cssVars);
```

## Performance

The CSS variable system provides:
- **Faster theme switching**: No need to reload stylesheets
- **Smaller bundle size**: Eliminates duplicate theme-specific CSS
- **Better maintainability**: Single source of truth for colors
- **Smooth transitions**: Built-in transition support

## Browser Support

CSS variables are supported in all modern browsers:
- Chrome 49+
- Firefox 31+
- Safari 9.1+
- Edge 16+

For older browsers, fallback values are provided where necessary.