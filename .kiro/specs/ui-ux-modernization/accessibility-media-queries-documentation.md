# Accessibility Media Queries Documentation

## Overview

This document outlines the accessibility-focused media queries implemented in the Maybe finance application. These media queries ensure that the application respects user preferences for reduced motion, contrast, and other accessibility features.

## Media Query Implementation

### Reduced Motion

The `prefers-reduced-motion` media query is used to detect if the user has requested minimized motion effects. When this preference is detected, animations and transitions are either disabled or significantly reduced.

```css
/* Base animation */
.animate-fade {
  transition: opacity 0.3s ease;
}

/* Respect reduced motion preference */
@media (prefers-reduced-motion: reduce) {
  .animate-fade {
    transition: none;
  }
}
```

#### Implementation Details

- **CSS Variables**: A `--motion-reduce` CSS variable is set to either `reduce` or `no-preference` based on the user's system preference
- **Class Toggle**: A `reduce-motion` class is added to the body element when reduced motion is preferred
- **JavaScript Detection**: The application detects the preference using `window.matchMedia('(prefers-reduced-motion: reduce)').matches`
- **User Override**: Users can override their system preference in the accessibility settings

#### Affected Elements

- Chart animations
- Page transitions
- Hover effects
- Loading indicators
- Modal dialogs
- Dropdown menus

### High Contrast Mode

The `prefers-contrast: more` media query is used to detect if the user has requested higher contrast. When this preference is detected, contrast ratios are increased for better readability.

```css
/* Base styling */
.card {
  background-color: var(--color-card);
  border: 1px solid var(--color-border);
}

/* High contrast mode */
@media (prefers-contrast: more) {
  .card {
    background-color: var(--color-card-high-contrast);
    border: 2px solid var(--color-border-high-contrast);
  }
}
```

#### Implementation Details

- **CSS Variables**: Additional high-contrast color variables are defined with stronger contrast ratios
- **Class Toggle**: A `high-contrast` class is added to the body element when high contrast is preferred
- **JavaScript Detection**: The application detects the preference using `window.matchMedia('(prefers-contrast: more)').matches`
- **User Override**: Users can override their system preference in the accessibility settings

#### Affected Elements

- Text and background colors
- Border colors and widths
- Button styles
- Form controls
- Charts and visualizations
- Icons and decorative elements

### Print Styles

Print-specific styles are implemented to ensure that printed content is optimized for readability and ink usage.

```css
/* Print styles */
@media print {
  .print-hidden {
    display: none !important;
  }
  
  .print-expanded {
    display: block !important;
  }
  
  body {
    background-color: white !important;
    color: black !important;
  }
}
```

#### Implementation Details

- **Print-Only Classes**: Classes like `print:hidden` and `print:block` control visibility in print mode
- **Color Optimization**: Colors are simplified to optimize for black and white printing
- **Layout Adjustments**: Page layouts are adjusted to be more suitable for printed media
- **Font Adjustments**: Font sizes and styles are optimized for print readability

#### Affected Elements

- Financial reports
- Transaction lists
- Budget summaries
- Charts and graphs (simplified versions)
- Navigation and UI controls (hidden in print)

### Color Scheme Preference

The `prefers-color-scheme` media query is used to detect the user's preferred color scheme (light or dark) at the system level.

```css
/* Default light theme */
:root {
  --background: 0 0% 100%;
  --foreground: 222.2 84% 4.9%;
}

/* Dark theme based on system preference */
@media (prefers-color-scheme: dark) {
  :root[data-theme="system"] {
    --background: 222.2 84% 4.9%;
    --foreground: 210 40% 98%;
  }
}
```

#### Implementation Details

- **Theme System Integration**: The system preference is used when the user selects the "System" theme option
- **JavaScript Detection**: The application detects the preference using `window.matchMedia('(prefers-color-scheme: dark)').matches`
- **Real-Time Updates**: The application listens for changes to the system preference and updates accordingly
- **User Override**: Users can override their system preference by explicitly selecting light or dark theme

## Testing Accessibility Media Queries

### Manual Testing

1. **Reduced Motion**: Enable "Reduce motion" in your operating system accessibility settings and verify that animations are reduced or eliminated
2. **High Contrast**: Enable "Increase contrast" in your operating system accessibility settings and verify that contrast is improved
3. **Print Preview**: Use browser print preview to verify that print styles are applied correctly
4. **Color Scheme**: Switch between light and dark mode in your operating system and verify that the application respects this preference when set to "System" theme

### Automated Testing

The application includes automated tests for accessibility media queries:

1. **Simulation Tests**: Tests that simulate media query matches using JavaScript
2. **Class Application Tests**: Tests that verify the correct classes are applied based on media queries
3. **Visual Regression Tests**: Tests that capture screenshots with different media query settings
4. **CSS Variable Tests**: Tests that verify CSS variables are updated correctly based on media queries

## Best Practices for Developers

When working with accessibility media queries, follow these best practices:

1. **Always provide non-animated alternatives** for motion effects
2. **Test with actual assistive technologies** whenever possible
3. **Use CSS variables** to manage theme and contrast variations
4. **Avoid hard-coded colors** that might override user preferences
5. **Test print styles** with different types of content
6. **Respect user preferences** but provide options to override them
7. **Combine media queries with feature detection** for the best compatibility

## Browser Support

| Browser | prefers-reduced-motion | prefers-contrast | prefers-color-scheme | print |
|---------|------------------------|------------------|----------------------|-------|
| Chrome  | ✅ 74+                 | ✅ 96+           | ✅ 76+               | ✅ All |
| Firefox | ✅ 63+                 | ✅ 101+          | ✅ 67+               | ✅ All |
| Safari  | ✅ 10.1+               | ✅ 15.4+         | ✅ 12.1+             | ✅ All |
| Edge    | ✅ 79+                 | ✅ 96+           | ✅ 79+               | ✅ All |

For browsers that don't support certain media queries, the application provides JavaScript-based fallbacks and user preference settings.

## Conclusion

By implementing and properly testing these accessibility media queries, the Maybe finance application ensures a better experience for all users, including those with specific accessibility needs. These implementations help the application meet WCAG 2.1 AA standards and provide a more inclusive user experience.