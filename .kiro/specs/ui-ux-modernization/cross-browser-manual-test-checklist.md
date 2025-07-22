# Cross-Browser Accessibility Manual Test Checklist

This checklist provides a structured approach for manually testing accessibility across different browsers and screen readers. Use this checklist to verify that the Maybe finance application meets WCAG 2.1 AA standards across all supported platforms.

## Browsers to Test

- Chrome (latest version)
- Firefox (latest version)
- Safari (latest version)
- Edge (latest version)

## Screen Readers to Test

- VoiceOver (macOS/iOS)
- NVDA (Windows)
- JAWS (Windows) - if available
- TalkBack (Android) - if testing mobile

## Test Environment Setup

1. **Desktop Testing**
   - Test on macOS with VoiceOver
   - Test on Windows with NVDA
   - Use standard screen sizes (1920x1080, 1366x768)

2. **Mobile Testing**
   - Test on iOS with VoiceOver
   - Test on Android with TalkBack
   - Test on both phone and tablet form factors

3. **Theme Testing**
   - Test in both light and dark themes
   - Test with system preference set to high contrast mode

## Manual Test Checklist

### 1. Keyboard Navigation

#### Tab Order and Focus
- [ ] Tab through the entire page and verify logical focus order
- [ ] Verify focus indicator is visible in all browsers
- [ ] Check that all interactive elements are keyboard accessible
- [ ] Verify that keyboard focus is not trapped (except in modals)
- [ ] Check that skip links are available and functional

#### Keyboard Shortcuts
- [ ] Test application-specific keyboard shortcuts
- [ ] Verify that keyboard shortcuts don't conflict with screen reader shortcuts
- [ ] Check that all keyboard interactions work consistently across browsers

### 2. Screen Reader Testing

#### Page Structure
- [ ] Verify proper heading structure (h1, h2, etc.)
- [ ] Check that landmark regions are properly identified
- [ ] Verify that page title is descriptive and accurate
- [ ] Check that language is properly specified

#### Interactive Elements
- [ ] Verify that buttons announce their purpose
- [ ] Check that links describe their destination
- [ ] Verify that form controls have proper labels
- [ ] Check that custom widgets have appropriate ARIA roles and properties

#### Dynamic Content
- [ ] Verify that dynamic content changes are announced
- [ ] Check that error messages are announced
- [ ] Verify that modal dialogs are properly announced
- [ ] Check that loading states are communicated

### 3. Visual Presentation

#### Color Contrast
- [ ] Verify sufficient contrast for text elements (4.5:1 for normal text, 3:1 for large text)
- [ ] Check that color is not the only means of conveying information
- [ ] Verify that focus indicators have sufficient contrast
- [ ] Check contrast in both light and dark themes

#### Text Resizing
- [ ] Verify that text can be resized up to 200% without loss of content
- [ ] Check that layout adapts properly when text is resized
- [ ] Verify that no horizontal scrolling is required at 400% zoom

#### Responsive Design
- [ ] Check that content reflows appropriately at different screen sizes
- [ ] Verify that touch targets are large enough (at least 44x44px)
- [ ] Check that content is usable in both portrait and landscape orientations

### 4. Forms and Validation

#### Form Controls
- [ ] Verify that all form controls have visible labels
- [ ] Check that form fields have proper instructions
- [ ] Verify that required fields are clearly indicated
- [ ] Check that form controls maintain proper states (focus, hover, active)

#### Error Handling
- [ ] Verify that error messages are clearly associated with form fields
- [ ] Check that error messages are descriptive and helpful
- [ ] Verify that errors are identified by more than just color
- [ ] Check that form validation works consistently across browsers

### 5. Media and Interactive Elements

#### Images and Icons
- [ ] Verify that all images have appropriate alt text
- [ ] Check that decorative images have empty alt text or are hidden from screen readers
- [ ] Verify that icon buttons have accessible names
- [ ] Check that complex images have detailed descriptions

#### Charts and Data Visualizations
- [ ] Verify that charts have text alternatives
- [ ] Check that data visualizations are keyboard accessible
- [ ] Verify that chart information is available to screen readers
- [ ] Check that interactive charts work with keyboard and screen readers

#### Videos and Animations
- [ ] Verify that videos have captions
- [ ] Check that animations respect reduced motion preferences
- [ ] Verify that auto-playing content can be paused
- [ ] Check that media controls are keyboard accessible

### 6. Custom Components

#### Modals and Dialogs
- [ ] Verify that focus is trapped within modal dialogs
- [ ] Check that modals return focus when closed
- [ ] Verify that modals have proper ARIA attributes
- [ ] Check that modals can be closed with Escape key

#### Tabs and Accordions
- [ ] Verify that tabs follow WAI-ARIA design patterns
- [ ] Check that tab panels are properly associated with tab controls
- [ ] Verify that accordions can be operated with keyboard
- [ ] Check that current state is communicated to screen readers

#### Dropdowns and Menus
- [ ] Verify that dropdown menus can be operated with keyboard
- [ ] Check that menu items are properly announced by screen readers
- [ ] Verify that submenus are accessible
- [ ] Check that menus close when Escape key is pressed

#### Toast Notifications
- [ ] Verify that notifications are announced to screen readers
- [ ] Check that notifications are visible long enough to read
- [ ] Verify that notifications can be dismissed with keyboard
- [ ] Check that notifications don't block other content

## Browser-Specific Checks

### Chrome
- [ ] Verify that form autofill works properly
- [ ] Check that custom focus styles are consistent
- [ ] Verify that high contrast mode is supported

### Firefox
- [ ] Check that form validation messages are accessible
- [ ] Verify that custom scrollbars are accessible
- [ ] Check that focus rings are visible

### Safari
- [ ] Verify that VoiceOver works properly with all components
- [ ] Check that form controls have proper labels
- [ ] Verify that custom keyboard handling works

### Edge
- [ ] Check that Windows high contrast mode is supported
- [ ] Verify that immersive reader features work if applicable
- [ ] Check that form controls are properly styled

## Mobile-Specific Checks

### Touch Interactions
- [ ] Verify that touch targets are large enough
- [ ] Check that swipe gestures work properly
- [ ] Verify that pinch-to-zoom is not disabled

### Screen Orientation
- [ ] Check that content works in both portrait and landscape
- [ ] Verify that orientation changes don't cause loss of context
- [ ] Check that fixed elements don't obscure content

### Mobile Screen Readers
- [ ] Verify that VoiceOver gestures work on iOS
- [ ] Check that TalkBack gestures work on Android
- [ ] Verify that all content is accessible via mobile screen readers

## Test Documentation

For each test, document the following:

1. **Test Environment**
   - Browser name and version
   - Operating system
   - Screen reader (if applicable)
   - Device type (desktop, tablet, mobile)

2. **Test Results**
   - Pass/Fail status
   - Description of any issues found
   - Screenshots or recordings of issues
   - Steps to reproduce issues

3. **Severity Rating**
   - Critical: Prevents access to core functionality
   - Major: Significantly impairs use but has workarounds
   - Minor: Causes inconvenience but doesn't prevent use

## Issue Reporting Template

```
Issue: [Brief description]
Environment: [Browser, OS, Screen reader, etc.]
URL: [Page where issue was found]
Steps to Reproduce:
1. [Step 1]
2. [Step 2]
3. [Step 3]

Expected Result: [What should happen]
Actual Result: [What actually happens]
Severity: [Critical/Major/Minor]
WCAG Success Criterion: [e.g., 1.1.1 Non-text Content]
```

## Regression Testing

After fixing identified issues, perform regression testing to ensure:

1. The fix resolves the original issue
2. The fix doesn't introduce new accessibility issues
3. The fix works consistently across all browsers and devices

Use this checklist for regular accessibility testing and whenever significant changes are made to the user interface.