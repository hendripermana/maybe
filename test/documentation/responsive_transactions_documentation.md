# Responsive Transactions Documentation

This document provides comprehensive documentation for the responsive transaction components, including responsive design patterns, touch interactions, and accessibility features.

## Responsive Design Patterns

The responsive transaction components use the following design patterns to ensure proper display across all device sizes:

### 1. Mobile-First Approach

All components are designed with a mobile-first approach, starting with the smallest viewport and progressively enhancing for larger screens:

```css
/* Base styles for mobile */
.responsive-transaction-item {
  padding: 1rem;
}

/* Tablet styles */
@media (min-width: 641px) {
  .responsive-transaction-item {
    padding: 0.75rem 1rem;
  }
}

/* Desktop styles */
@media (min-width: 1025px) {
  .responsive-transaction-item {
    padding: 0.5rem 1rem;
  }
}
```

### 2. Column Prioritization

The transaction list uses column prioritization to show the most important information on small screens:

| Column | Mobile | Tablet | Desktop |
|--------|--------|--------|---------|
| Transaction Name | ✓ | ✓ | ✓ |
| Account Name | ✓ (small) | ✓ | ✓ |
| Category | ✓ (below name) | ✓ | ✓ |
| Amount | ✓ | ✓ | ✓ |
| Balance | ✗ | ✗ | ✓ |

### 3. Responsive Grid System

The transaction list uses a 12-column grid system that adapts to different screen sizes:

```html
<div class="grid grid-cols-12">
  <!-- Mobile: 8 columns, Tablet: 6 columns, Desktop: 8 columns -->
  <div class="col-span-8 md:col-span-6 lg:col-span-8">
    <!-- Transaction name and details -->
  </div>
  
  <!-- Hidden on mobile, 2 columns on tablet and desktop -->
  <div class="hidden md:flex col-span-2">
    <!-- Category -->
  </div>
  
  <!-- Mobile: 4 columns, Tablet: 4 columns, Desktop: 2 columns -->
  <div class="col-span-4 md:col-span-4 lg:col-span-2">
    <!-- Amount -->
  </div>
  
  <!-- Hidden on mobile and tablet, 2 columns on desktop -->
  <div class="hidden lg:block col-span-2">
    <!-- Balance -->
  </div>
</div>
```

### 4. Stacked Layout on Mobile

On mobile devices, the transaction filters and pagination controls use a stacked layout to ensure adequate touch targets:

```html
<div class="flex flex-col sm:flex-row">
  <!-- Search input - Full width on mobile -->
  <div class="w-full sm:max-w-xs">
    <!-- Search input -->
  </div>
  
  <!-- Filter controls - Row on mobile, flex end on larger screens -->
  <div class="flex items-center justify-between sm:justify-end">
    <!-- Filter controls -->
  </div>
</div>
```

### 5. Simplified Controls on Mobile

The pagination component shows simplified prev/next controls on mobile and full page numbers on larger screens:

```html
<!-- Mobile pagination - Simple prev/next -->
<div class="flex flex-1 justify-between sm:hidden">
  <!-- Previous/Next buttons -->
</div>

<!-- Desktop pagination - Full page numbers -->
<div class="hidden sm:flex sm:flex-1 sm:items-center sm:justify-between">
  <!-- Page numbers -->
</div>
```

## Touch-Friendly Interactions

The responsive transaction components include several features to improve touch interactions on mobile devices:

### 1. Adequate Touch Targets

All interactive elements have a minimum touch target size of 44x44 pixels on mobile devices:

```css
/* Improved touch targets */
.responsive-transaction-item button,
.responsive-transaction-item a,
.responsive-transaction-item input[type="checkbox"] {
  min-height: 44px;
}
```

### 2. Touch Action Manipulation

The `touch-action: manipulation` CSS property is used to improve touch responsiveness and prevent delays:

```css
.touch-manipulation {
  touch-action: manipulation;
}
```

### 3. Swipe Gestures

The responsive transaction controller supports swipe gestures for common actions:

```javascript
// Handle touch move for swipe gestures
containerTarget.addEventListener('touchmove', (event) => {
  if (!this.touchStartX || !this.touchStartY) return
  
  const touchEndX = event.touches[0].clientX
  const touchEndY = event.touches[0].clientY
  
  const xDiff = this.touchStartX - touchEndX
  const yDiff = this.touchStartY - touchEndY
  
  // Horizontal swipe detection
  if (Math.abs(xDiff) > Math.abs(yDiff) && Math.abs(xDiff) > 50) {
    // Prevent default only if we're handling the swipe
    event.preventDefault()
    
    if (xDiff > 0) {
      // Swipe left - could show action buttons
      this.handleSwipeLeft()
    } else {
      // Swipe right - could show different action
      this.handleSwipeRight()
    }
  }
})
```

### 4. Tap to Expand

On mobile devices, tapping a transaction item can expand it to show additional details:

```javascript
// Toggle transaction details on mobile (tap to expand)
toggleDetails(event) {
  // Only handle on mobile
  if (window.innerWidth >= 640) return
  
  // Don't toggle if clicking on interactive elements
  if (event.target.closest('a, button, input, select')) return
  
  if (this.hasDetailsTarget) {
    this.detailsTarget.classList.toggle('hidden')
  }
}
```

### 5. Scrollable Filter Tags

On mobile devices, filter tags are horizontally scrollable to accommodate many active filters:

```css
/* Scrollable filters on mobile */
.scrollbar-thin {
  scrollbar-width: thin;
  -ms-overflow-style: none;
  overflow-x: auto;
}
```

## Accessibility Features

The responsive transaction components include several accessibility features:

### 1. Keyboard Navigation

All interactive elements are keyboard navigable with visible focus indicators:

```css
/* Focus styles */
.responsive-transaction-item a:focus-visible,
.responsive-transaction-item button:focus-visible,
.responsive-transaction-item input:focus-visible {
  outline: 2px solid var(--color-ring);
  outline-offset: 2px;
}
```

### 2. Screen Reader Support

All components include proper ARIA attributes for screen reader compatibility:

```html
<!-- Pagination with ARIA labels -->
<nav class="flex items-center justify-between" aria-label="Pagination">
  <!-- Previous page link with screen reader text -->
  <a href="#" aria-label="Previous page">
    <span class="sr-only">Previous</span>
    <!-- Icon -->
  </a>
</nav>
```

### 3. Reduced Motion Support

The components respect the user's reduced motion preference:

```css
@media (prefers-reduced-motion: reduce) {
  .responsive-transaction-item {
    transition: none !important;
  }
}
```

### 4. High Contrast Mode Support

The components include support for high contrast mode:

```css
@media (forced-colors: active) {
  .responsive-transaction-item {
    border: 1px solid CanvasText;
  }
  
  .responsive-transaction-item:focus-within {
    outline: 2px solid Highlight;
  }
}
```

### 5. Proper Heading Structure

The transaction list uses proper heading structure for screen readers:

```html
<!-- Empty state with proper heading structure -->
<div class="flex flex-col items-center justify-center p-8 text-center">
  <h3 class="text-lg font-medium">No transactions found</h3>
  <p class="text-sm text-muted-foreground mt-2">Try adjusting your filters or create a new transaction.</p>
</div>
```

## Responsive Testing

The responsive transaction components are tested across multiple viewport sizes and devices:

### Viewport Sizes

| Name | Width | Height | Description |
|------|-------|--------|-------------|
| Mobile | 375px | 667px | iPhone SE/8 |
| Tablet | 768px | 1024px | iPad |
| Desktop | 1280px | 800px | Standard desktop |
| Large Desktop | 1920px | 1080px | Large desktop |

### Browser Testing

The components are tested in the following browsers:

- Chrome (latest)
- Firefox (latest)
- Safari (latest)
- Edge (latest)

### Device Testing

The components are tested on the following devices:

- iOS (iPhone, iPad)
- Android (various screen sizes)
- Desktop (Windows, macOS)

## Implementation Guidelines

When implementing the responsive transaction components, follow these guidelines:

### 1. Mobile-First Approach

Always start with mobile styles and progressively enhance for larger screens:

```css
/* Base styles for all screen sizes */
.component {
  /* Mobile styles */
}

/* Tablet styles */
@media (min-width: 640px) {
  .component {
    /* Tablet enhancements */
  }
}

/* Desktop styles */
@media (min-width: 1024px) {
  .component {
    /* Desktop enhancements */
  }
}
```

### 2. Touch Target Sizes

Ensure all interactive elements have adequate touch target sizes:

- Minimum size: 44x44 pixels
- Minimum spacing between targets: 8 pixels

### 3. Column Prioritization

When designing responsive tables or lists:

1. Identify the most important columns for each viewport size
2. Hide less important columns on smaller screens
3. Consider alternative presentations for hidden data (e.g., expandable rows)

### 4. Performance Considerations

Optimize performance for mobile devices:

1. Minimize JavaScript execution
2. Use efficient CSS selectors
3. Implement virtualized lists for large datasets
4. Optimize images and assets

### 5. Testing Across Devices

Always test on actual devices or accurate emulations:

1. Test on multiple physical devices when possible
2. Use Chrome DevTools device emulation for development
3. Test with touch interactions, not just mouse
4. Verify performance on lower-end devices

## Known Issues and Workarounds

### 1. iOS Safari Momentum Scrolling

**Issue:** Horizontal scrolling of filter tags may not have momentum scrolling on iOS Safari.

**Workaround:** Add `-webkit-overflow-scrolling: touch` to scrollable elements:

```css
.scrollbar-thin {
  -webkit-overflow-scrolling: touch;
}
```

### 2. Touch Delay on Mobile Browsers

**Issue:** Some mobile browsers have a 300ms delay on touch events.

**Workaround:** Use the `touch-action: manipulation` CSS property:

```css
.touch-manipulation {
  touch-action: manipulation;
}
```

### 3. Fixed Position Elements on iOS

**Issue:** Fixed position elements may cause issues when the virtual keyboard is shown on iOS.

**Workaround:** Use absolute positioning with a fixed container:

```css
.ios-fixed-container {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  overflow: auto;
  -webkit-overflow-scrolling: touch;
}
```

### 4. Hover States on Touch Devices

**Issue:** Hover states may stick on touch devices after tapping.

**Workaround:** Use media queries to disable hover effects on touch devices:

```css
@media (hover: hover) {
  .button:hover {
    background-color: var(--color-accent);
  }
}
```

## Conclusion

The responsive transaction components provide a consistent, accessible, and touch-friendly experience across all device sizes. By following the responsive design patterns and implementation guidelines outlined in this document, you can ensure that transactions are displayed optimally on any device.