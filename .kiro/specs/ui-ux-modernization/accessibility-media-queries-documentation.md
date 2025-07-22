# Accessibility Media Queries Implementation

This document outlines the implementation of print styles and special media queries for the Maybe Finance application as part of the UI/UX modernization project.

## Overview

We've implemented the following accessibility features:

1. **Print Styles**: Optimized styles for printing financial reports and pages
2. **Reduced Motion Preferences**: Support for users who prefer reduced motion
3. **High Contrast Mode**: Enhanced visibility for users who need higher contrast
4. **Screen Reader Support**: Improved accessibility for screen reader users

## Implementation Details

### 1. Print Styles

Print styles have been implemented to ensure that when users print pages from the application, they receive well-formatted, readable output that focuses on the essential content.

Key features:
- Removal of non-essential UI elements (navigation, buttons, etc.)
- Optimized layout for paper format
- Proper page breaks to avoid splitting important content
- Enhanced readability with appropriate font sizes and contrast
- Special formatting for financial data and tables
- URL display for relevant links

**Usage Example:**
```css
@media print {
  /* Hide non-essential elements */
  header, footer, nav, .no-print {
    display: none !important;
  }
  
  /* Ensure page breaks don't happen inside elements */
  .transaction-item, .budget-card {
    page-break-inside: avoid;
  }
}
```

### 2. Reduced Motion Preferences

Support for the `prefers-reduced-motion` media query has been implemented to accommodate users who experience motion sickness or are distracted by animations.

Key features:
- Disabled or significantly reduced animations
- Eliminated transitions that could cause discomfort
- Static alternatives for animated components
- Preserved functionality without motion effects

**Usage Example:**
```css
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.001ms !important;
    transition-duration: 0.001ms !important;
    scroll-behavior: auto !important;
  }
  
  .chart-animation, .shimmer {
    animation: none !important;
  }
}
```

### 3. High Contrast Mode

Support for the `prefers-contrast: more` media query has been implemented to improve visibility for users with visual impairments.

Key features:
- Enhanced contrast between text and background
- Stronger borders and visual indicators
- Clear focus states
- Improved color differentiation for charts and data visualizations

**Usage Example:**
```css
@media (prefers-contrast: more) {
  body {
    color: black !important;
    background-color: white !important;
  }
  
  [data-theme="dark"] body {
    color: white !important;
    background-color: black !important;
  }
  
  button, input, .card {
    border: 1px solid currentColor !important;
  }
}
```

### 4. Screen Reader Support

Improvements for screen reader users have been implemented to ensure the application is accessible to users with visual impairments.

Key features:
- Skip-to-content link for keyboard navigation
- Proper ARIA attributes for interactive elements
- Screen reader only text for visual elements
- Focus management for modals and dialogs

**Usage Example:**
```css
.sr-only {
  position: absolute !important;
  width: 1px !important;
  height: 1px !important;
  padding: 0 !important;
  margin: -1px !important;
  overflow: hidden !important;
  clip: rect(0, 0, 0, 0) !important;
  white-space: nowrap !important;
  border-width: 0 !important;
}

.skip-to-content {
  position: absolute;
  top: -40px;
  left: 0;
  background: var(--color-primary);
  color: var(--color-primary-foreground);
  padding: 8px;
  z-index: 100;
  transition: top 0.2s;
}

.skip-to-content:focus {
  top: 0;
}
```

## Testing

The implementation includes comprehensive testing to ensure accessibility features work correctly:

1. **Automated Tests**: Unit tests for media query functionality
2. **Manual Testing**: Visual verification of print styles and media query effects
3. **Screen Reader Testing**: Verification with popular screen readers (NVDA, VoiceOver)
4. **Browser Compatibility**: Testing across Chrome, Firefox, Safari, and Edge

## Usage Guidelines

### For Developers

When developing new components or pages:

1. **Print Styles**: 
   - Use the `no-print` class to hide non-essential elements
   - Use the `print-only` class for elements that should only appear when printing
   - Test print output using browser print preview

2. **Motion Sensitivity**:
   - Avoid adding unnecessary animations
   - Ensure all animations respect the reduced motion preference
   - Test with the reduced motion setting enabled

3. **High Contrast**:
   - Avoid relying solely on color to convey information
   - Test components in high contrast mode
   - Ensure sufficient contrast ratios for text and UI elements

4. **Screen Readers**:
   - Use semantic HTML elements
   - Add appropriate ARIA attributes
   - Include screen reader text for visual elements using the `sr-only` class
   - Test with a screen reader

### For Users

Users can benefit from these accessibility features in the following ways:

1. **Printing**: Use the browser's print function to generate clean, readable printouts of financial reports
2. **Motion Sensitivity**: Enable reduced motion in your operating system settings
3. **High Contrast**: Enable high contrast mode in your operating system settings
4. **Screen Readers**: Use the skip-to-content link to bypass navigation and go directly to the main content

## Future Enhancements

Potential future improvements to accessibility features:

1. **Print Templates**: Dedicated print templates for financial reports and statements
2. **Custom Motion Settings**: In-app controls for animation speed and effects
3. **Theme Customization**: Additional contrast and color options beyond light/dark
4. **Keyboard Navigation**: Enhanced keyboard shortcuts and navigation patterns