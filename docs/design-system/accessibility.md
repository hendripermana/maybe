# Accessibility Guidelines

This document outlines the accessibility standards and best practices for the Maybe Finance design system. Following these guidelines ensures that our application is usable by people with a wide range of abilities and meets WCAG 2.1 AA standards.

## Core Principles

1. **Perceivable**: Information and user interface components must be presentable to users in ways they can perceive
2. **Operable**: User interface components and navigation must be operable
3. **Understandable**: Information and the operation of the user interface must be understandable
4. **Robust**: Content must be robust enough to be interpreted by a wide variety of user agents, including assistive technologies

## Visual Design

### Color and Contrast

- **Minimum Contrast**: Maintain a contrast ratio of at least 4.5:1 for normal text and 3:1 for large text
- **Color Independence**: Don't use color as the only visual means of conveying information
- **Text Over Images**: Ensure text over images has sufficient contrast by using overlays or text shadows

```css
/* Example of accessible text over image */
.text-over-image {
  background-color: rgba(0, 0, 0, 0.6);
  color: white;
  padding: var(--spacing-4);
}
```

### Typography

- **Font Size**: Use a minimum font size of 16px for body text
- **Line Height**: Set line height to at least 1.5 for body text
- **Letter Spacing**: Ensure adequate letter spacing for readability
- **Font Weight**: Provide sufficient contrast between different font weights

```css
/* Accessible typography */
body {
  font-size: var(--font-size-base); /* 16px */
  line-height: var(--line-height-normal); /* 1.5 */
  letter-spacing: normal;
}
```

### Focus Indicators

- **Visible Focus**: Ensure all interactive elements have a visible focus indicator
- **Focus Style**: Use a consistent focus style throughout the application
- **Focus Ring**: Use a focus ring that is visible in both light and dark themes

```css
/* Accessible focus style */
:focus-visible {
  outline: 2px solid hsl(var(--ring));
  outline-offset: 2px;
}
```

## Semantic HTML

### Document Structure

- **Landmarks**: Use HTML5 landmark elements (`<header>`, `<main>`, `<nav>`, `<aside>`, `<footer>`)
- **Headings**: Use proper heading hierarchy (h1-h6) to structure content
- **Lists**: Use appropriate list elements (`<ul>`, `<ol>`, `<dl>`) for lists

```html
<!-- Example of proper document structure -->
<header role="banner">
  <h1>Page Title</h1>
</header>

<nav role="navigation">
  <!-- Navigation links -->
</nav>

<main role="main">
  <section>
    <h2>Section Title</h2>
    <!-- Section content -->
  </section>
</main>

<footer role="contentinfo">
  <!-- Footer content -->
</footer>
```

### Interactive Elements

- **Buttons**: Use `<button>` elements for interactive controls
- **Links**: Use `<a>` elements for navigation
- **Form Controls**: Use proper form elements with associated labels

```html
<!-- Button example -->
<button type="button" class="btn-primary">Click Me</button>

<!-- Link example -->
<a href="/page" class="link">Go to Page</a>

<!-- Form control example -->
<label for="name">Name</label>
<input type="text" id="name" name="name">
```

## Keyboard Accessibility

### Focus Management

- **Tab Order**: Ensure a logical tab order that follows the visual layout
- **Focus Trapping**: Trap focus within modal dialogs and other overlays
- **Skip Links**: Provide skip links to bypass repetitive navigation

```html
<!-- Skip link example -->
<a href="#main-content" class="skip-link">Skip to main content</a>

<!-- Later in the document -->
<main id="main-content">
  <!-- Main content -->
</main>
```

### Keyboard Navigation

- **All Interactive Elements**: Ensure all interactive elements are keyboard accessible
- **Custom Components**: Implement proper keyboard interactions for custom components
- **Keyboard Shortcuts**: Document keyboard shortcuts and ensure they don't conflict with assistive technologies

```javascript
// Example of keyboard navigation in a Stimulus controller
export default class extends Controller {
  connect() {
    this.element.addEventListener('keydown', this.handleKeyDown.bind(this));
  }
  
  handleKeyDown(event) {
    switch (event.key) {
      case 'ArrowDown':
        this.navigateNext();
        event.preventDefault();
        break;
      case 'ArrowUp':
        this.navigatePrevious();
        event.preventDefault();
        break;
      case 'Enter':
      case ' ':
        this.activate();
        event.preventDefault();
        break;
      case 'Escape':
        this.close();
        event.preventDefault();
        break;
    }
  }
}
```

## ARIA Implementation

### ARIA Roles

- **Use Semantic HTML First**: Prefer semantic HTML elements over ARIA roles when possible
- **Landmark Roles**: Use ARIA landmark roles when HTML5 elements aren't sufficient
- **Widget Roles**: Use appropriate ARIA widget roles for custom components

```html
<!-- Example of ARIA roles -->
<div role="tablist">
  <button role="tab" aria-selected="true" id="tab-1">Tab 1</button>
  <button role="tab" aria-selected="false" id="tab-2">Tab 2</button>
</div>

<div role="tabpanel" aria-labelledby="tab-1">
  <!-- Tab 1 content -->
</div>

<div role="tabpanel" aria-labelledby="tab-2" hidden>
  <!-- Tab 2 content -->
</div>
```

### ARIA States and Properties

- **aria-expanded**: Use for expandable elements like accordions
- **aria-selected**: Use for selectable elements like tabs
- **aria-pressed**: Use for toggle buttons
- **aria-disabled**: Use for disabled elements that remain in the DOM
- **aria-hidden**: Use to hide decorative elements from screen readers

```html
<!-- Example of ARIA states -->
<button aria-expanded="false" aria-controls="dropdown-menu">
  Menu
</button>

<div id="dropdown-menu" hidden>
  <!-- Dropdown content -->
</div>
```

### ARIA Live Regions

- **aria-live**: Use for dynamic content updates
- **role="alert"**: Use for important, time-sensitive messages
- **role="status"**: Use for non-critical status updates

```html
<!-- Example of ARIA live regions -->
<div aria-live="polite" role="status" class="sr-only">
  <!-- Content updated dynamically -->
</div>
```

## Forms

### Form Structure

- **Fieldsets**: Group related form controls with `<fieldset>` and `<legend>`
- **Labels**: Associate labels with form controls using `for` attribute
- **Required Fields**: Indicate required fields both visually and with the `required` attribute

```html
<!-- Example of accessible form structure -->
<fieldset>
  <legend>Contact Information</legend>
  
  <div class="form-group">
    <label for="name">Name <span class="required">*</span></label>
    <input type="text" id="name" name="name" required>
  </div>
  
  <div class="form-group">
    <label for="email">Email <span class="required">*</span></label>
    <input type="email" id="email" name="email" required>
  </div>
</fieldset>
```

### Form Validation

- **Error Messages**: Provide clear error messages for form validation
- **Error Association**: Associate error messages with form controls using `aria-describedby`
- **Error Summary**: Provide a summary of errors at the top of the form

```html
<!-- Example of accessible form validation -->
<div role="alert" class="error-summary">
  <h2>Please fix the following errors:</h2>
  <ul>
    <li><a href="#name">Name is required</a></li>
    <li><a href="#email">Email is invalid</a></li>
  </ul>
</div>

<div class="form-group">
  <label for="name">Name <span class="required">*</span></label>
  <input 
    type="text" 
    id="name" 
    name="name" 
    required 
    aria-invalid="true" 
    aria-describedby="name-error"
  >
  <div id="name-error" class="error-message">Name is required</div>
</div>
```

## Images and Media

### Images

- **Alt Text**: Provide alternative text for all images
- **Decorative Images**: Use empty alt text (`alt=""`) for decorative images
- **Complex Images**: Provide detailed descriptions for complex images

```html
<!-- Example of accessible images -->
<img src="logo.png" alt="Maybe Finance Logo">

<!-- Decorative image -->
<img src="decorative.png" alt="" role="presentation">

<!-- Complex image -->
<figure>
  <img src="chart.png" alt="Bar chart showing monthly expenses">
  <figcaption>Monthly expenses from January to December 2023</figcaption>
</figure>
```

### Media

- **Captions**: Provide captions for videos
- **Transcripts**: Provide transcripts for audio content
- **Audio Description**: Provide audio descriptions for videos when necessary
- **Controls**: Ensure media players have keyboard-accessible controls

```html
<!-- Example of accessible video -->
<video controls>
  <source src="video.mp4" type="video/mp4">
  <track kind="captions" src="captions.vtt" srclang="en" label="English">
  Your browser does not support the video tag.
</video>
```

## Dynamic Content

### Loading States

- **Loading Indicators**: Provide visual loading indicators
- **ARIA Live Regions**: Use ARIA live regions to announce loading states
- **Skeleton Screens**: Use skeleton screens for content that is loading

```html
<!-- Example of accessible loading state -->
<div aria-live="polite" role="status">
  <div class="loading-spinner" aria-hidden="true"></div>
  <span class="sr-only">Loading content...</span>
</div>
```

### Notifications

- **Toast Messages**: Ensure toast messages are announced to screen readers
- **Modal Dialogs**: Ensure modal dialogs trap focus and are properly announced
- **Error Messages**: Ensure error messages are announced to screen readers

```html
<!-- Example of accessible toast notification -->
<div 
  role="status" 
  aria-live="polite" 
  class="toast"
>
  Your changes have been saved successfully.
</div>
```

## Testing

### Automated Testing

- **Accessibility Linting**: Use accessibility linting tools in the development process
- **Unit Tests**: Include accessibility checks in component unit tests
- **Integration Tests**: Test keyboard navigation and screen reader announcements

```ruby
# Example of accessibility testing in a component test
test "button has accessible name" do
  render_inline(ButtonComponent.new(aria: { label: "Close" }))
  
  assert_selector "button[aria-label='Close']"
end
```

### Manual Testing

- **Keyboard Navigation**: Test all functionality using only the keyboard
- **Screen Reader Testing**: Test with popular screen readers (NVDA, VoiceOver)
- **Zoom Testing**: Test the application at different zoom levels (up to 400%)
- **Color Contrast**: Verify color contrast meets WCAG AA standards
- **Reduced Motion**: Test with reduced motion preferences enabled

## Responsive Design

### Mobile Accessibility

- **Touch Targets**: Ensure touch targets are at least 44x44 pixels
- **Pinch to Zoom**: Don't disable pinch-to-zoom functionality
- **Orientation**: Support both portrait and landscape orientations
- **Mobile Screen Readers**: Test with mobile screen readers (VoiceOver, TalkBack)

```css
/* Example of accessible touch targets */
.touch-target {
  min-width: 44px;
  min-height: 44px;
  padding: var(--spacing-3);
}
```

### Responsive Text

- **Fluid Typography**: Use responsive typography that scales with viewport size
- **Line Length**: Maintain optimal line length (50-75 characters) across screen sizes
- **Text Spacing**: Allow text spacing to be adjusted without breaking layout

```css
/* Example of fluid typography */
h1 {
  font-size: clamp(1.5rem, 5vw, 2.5rem);
}

p {
  max-width: 75ch;
}
```

## User Preferences

### Reduced Motion

- **Respect prefers-reduced-motion**: Reduce or eliminate animations for users who prefer reduced motion
- **Essential Animations**: Only use animations that are essential for understanding

```css
/* Example of respecting reduced motion preference */
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.001ms !important;
    transition-duration: 0.001ms !important;
  }
}
```

### Color Scheme

- **Respect prefers-color-scheme**: Support both light and dark color schemes
- **High Contrast**: Test with high contrast mode

```css
/* Example of respecting color scheme preference */
@media (prefers-color-scheme: dark) {
  :root {
    --background: 224 71% 4%;
    --foreground: 213 31% 91%;
    /* Other dark mode variables */
  }
}
```

## Component-Specific Guidelines

### Buttons

- Use proper button elements
- Provide descriptive text or aria-label
- Ensure sufficient size and spacing
- Maintain consistent focus styles

### Links

- Use descriptive link text
- Avoid "click here" or "read more"
- Style links to be distinguishable from surrounding text
- Indicate when links open in a new window

### Form Controls

- Associate labels with form controls
- Group related controls with fieldset and legend
- Provide clear instructions and error messages
- Support keyboard navigation

### Tables

- Use proper table markup with headers
- Use scope attribute for header cells
- Provide captions or summaries for complex tables
- Ensure responsive behavior on small screens

### Dialogs

- Trap focus within the dialog
- Provide a visible close button
- Support closing with the Escape key
- Announce the dialog to screen readers

### Tabs

- Use proper ARIA roles and attributes
- Support keyboard navigation between tabs
- Ensure visible focus indicators
- Announce tab changes to screen readers

### Accordions

- Use proper ARIA attributes (aria-expanded, aria-controls)
- Support keyboard activation
- Provide visible expand/collapse indicators
- Announce state changes to screen readers

## Resources

- [WCAG 2.1 Guidelines](https://www.w3.org/TR/WCAG21/)
- [WAI-ARIA Authoring Practices](https://www.w3.org/TR/wai-aria-practices-1.1/)
- [A11y Project Checklist](https://www.a11yproject.com/checklist/)
- [MDN Accessibility Documentation](https://developer.mozilla.org/en-US/docs/Web/Accessibility)
- [Inclusive Components](https://inclusive-components.design/)