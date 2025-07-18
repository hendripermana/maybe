# Dashboard Test Suite Documentation

This document provides comprehensive documentation for the dashboard test suite, including test coverage, test strategies, and special considerations.

## Test Coverage

The dashboard test suite covers the following areas:

1. **Theme System Consistency**
   - Theme switching between light and dark modes
   - CSS variable usage and consistency
   - Absence of hardcoded colors
   - Theme-aware component styling

2. **Component Rendering**
   - Dashboard cards
   - Chart containers
   - Buttons and interactive elements
   - Fullscreen modal functionality

3. **Accessibility Compliance**
   - WCAG 2.1 AA standards
   - Keyboard navigation
   - Screen reader compatibility
   - Color contrast requirements
   - Focus management

4. **Responsive Design**
   - Mobile, tablet, and desktop layouts
   - Viewport adaptations
   - Touch-friendly interactions
   - Responsive grid system

5. **Visual Regression**
   - Component appearance in both themes
   - Layout consistency across viewports
   - Special styling cases

## Test Files

### Core Test Files

1. **`dashboard_component_suite_test.rb`**
   - Comprehensive tests for all dashboard components
   - Theme awareness testing
   - Responsive design testing
   - Visual regression testing

2. **`dashboard_accessibility_test.rb`**
   - WCAG 2.1 AA compliance testing
   - Color contrast verification
   - Reduced motion preference support
   - High contrast mode testing

3. **`dashboard_keyboard_navigation_test.rb`**
   - Keyboard navigation testing
   - Focus management testing
   - Keyboard shortcuts testing
   - Focus trap testing for modals

4. **`dashboard_screen_reader_test.rb`**
   - Screen reader compatibility testing
   - ARIA attributes verification
   - Text alternatives for visual elements
   - Live region testing

5. **`dashboard_theme_documentation_test.rb`**
   - Documentation generation for theme overrides
   - Special layout case documentation
   - CSS variable documentation

### Supporting Test Files

1. **`dashboard_layout_test.rb`**
   - Tests for layout issues like white space
   - Chart container sizing tests
   - Theme consistency in layouts

2. **`dashboard_theme_switching_test.rb`**
   - Tests for theme switching functionality
   - Theme variable application
   - Theme persistence

3. **`dashboard_card_standardization_test.rb`**
   - Tests for card component standardization
   - Card styling consistency

## Test Helpers

The test suite uses several helper modules:

1. **`ThemeTestHelper`**
   - Methods for testing theme switching
   - Theme-aware component verification
   - CSS variable testing

2. **`AccessibilityTestHelper`**
   - Methods for testing WCAG compliance
   - Color contrast calculation
   - Keyboard navigation testing
   - Screen reader compatibility testing

3. **`VisualRegressionHelper`**
   - Methods for visual regression testing
   - Screenshot comparison
   - Viewport simulation

## Test Strategies

### Theme Testing Strategy

The dashboard test suite uses a comprehensive approach to theme testing:

1. **CSS Variable Verification**
   - Tests that all theme-specific CSS variables are defined
   - Verifies variables have different values in light and dark themes
   - Checks that components use these variables

2. **Hardcoded Color Detection**
   - Scans for hardcoded color classes (e.g., `bg-white`, `text-black`)
   - Verifies no hardcoded colors are visible in either theme

3. **Theme Switching Testing**
   - Tests theme switching functionality
   - Verifies all components update correctly when theme changes
   - Checks for any visual glitches during theme transition

### Accessibility Testing Strategy

The accessibility testing strategy follows WCAG 2.1 AA guidelines:

1. **Color Contrast Testing**
   - Calculates contrast ratios for text elements
   - Verifies all text meets AA contrast requirements (4.5:1 for normal text, 3:1 for large text)
   - Tests contrast in both themes

2. **Keyboard Navigation Testing**
   - Verifies all interactive elements are keyboard accessible
   - Tests logical tab order
   - Verifies visible focus indicators
   - Tests keyboard shortcuts

3. **Screen Reader Testing**
   - Verifies proper ARIA attributes
   - Tests for text alternatives for visual elements
   - Checks heading hierarchy
   - Verifies landmark regions

4. **Reduced Motion Testing**
   - Tests with reduced motion preference enabled
   - Verifies animations are disabled or reduced

### Visual Regression Testing Strategy

The visual regression testing strategy uses screenshot comparison:

1. **Baseline Screenshots**
   - Creates baseline screenshots for components in both themes
   - Captures screenshots at different viewport sizes

2. **Comparison Testing**
   - Compares new screenshots with baselines
   - Detects visual regressions

3. **Documentation**
   - Documents visual appearance of components
   - Captures special styling cases

## Special Test Cases

### 1. Sankey Chart Testing

The Sankey chart requires special testing considerations:

```ruby
test "sankey chart renders correctly in both themes" do
  visit root_path
  
  # Skip if no sankey chart exists
  skip "No sankey chart found" unless has_selector?("#sankey-chart")
  
  # Test sankey chart in both themes
  test_both_themes do
    # Verify chart elements
    assert_selector "#sankey-chart .node rect"
    assert_selector "#sankey-chart .link"
    
    # Check for theme-specific colors
    nodes = all("#sankey-chart .node rect")
    
    nodes.each do |node|
      # Check for theme awareness
      fill_color = page.evaluate_script(
        "arguments[0].getAttribute('fill')",
        node.native
      )
      
      # Verify node colors are not hardcoded
      refute ["#ffffff", "#000000", "white", "black"].include?(fill_color&.downcase),
             "Sankey chart nodes should not use hardcoded colors"
    end
  end
end
```

### 2. Fullscreen Modal Testing

The fullscreen modal requires special focus management testing:

```ruby
test "fullscreen modal manages focus correctly" do
  visit root_path
  
  # Skip if no fullscreen button exists
  skip "No fullscreen button found" unless has_selector?("[data-action*='fullscreen']")
  
  # Open fullscreen modal
  find("[data-action*='fullscreen']").click
  assert_selector ".modal-fullscreen", visible: true
  
  # Verify focus is moved to the modal
  focused_element = page.evaluate_script("document.activeElement")
  modal = find(".modal-fullscreen")
  
  assert_equal modal.native, focused_element,
               "Focus should move to modal when opened"
  
  # Tab multiple times to verify focus stays in modal
  trapped_in_modal = true
  
  10.times do
    page.send_keys(:tab)
    focused_element = page.evaluate_script("document.activeElement")
    
    # Check if focus is still within modal
    is_in_modal = page.evaluate_script(
      "document.querySelector('.modal-fullscreen').contains(document.activeElement)"
    )
    
    trapped_in_modal = trapped_in_modal && is_in_modal
  end
  
  assert trapped_in_modal, "Focus should be trapped within modal"
  
  # Close modal
  find(".modal-close").click
  
  # Verify focus returns to trigger element
  focused_element = page.evaluate_script("document.activeElement")
  fullscreen_button = find("[data-action*='fullscreen']")
  
  assert_equal fullscreen_button.native, focused_element,
               "Focus should return to trigger element when modal is closed"
end
```

### 3. Responsive Layout Testing

Testing responsive layouts requires viewport simulation:

```ruby
test "dashboard layout adapts to different viewports" do
  visit root_path
  
  # Test at different viewport sizes
  UiTestingConfig::VISUAL_REGRESSION_CONFIG[:viewports].each do |name, dimensions|
    with_viewport(*dimensions) do
      # Verify dashboard renders at this viewport
      assert_selector ".dashboard-page"
      
      # Check for responsive layout adjustments
      case name
      when :mobile
        # Mobile layout checks
        assert_no_selector ".dashboard-sidebar", visible: true
        assert_selector ".mobile-menu-button", visible: true
      when :desktop
        # Desktop layout checks
        assert_selector ".dashboard-sidebar", visible: true
        assert_no_selector ".mobile-menu-button", visible: true
      end
    end
  end
end
```

## Running the Tests

To run the dashboard test suite:

```bash
# Run all dashboard tests
rails test test/system/dashboard_*_test.rb

# Run specific test file
rails test test/system/dashboard_accessibility_test.rb

# Run with specific browser
BROWSER=firefox rails test test/system/dashboard_component_suite_test.rb

# Run with visual regression testing
VISUAL_REGRESSION=true rails test test/system/dashboard_component_suite_test.rb
```

## Test Maintenance

### Adding New Tests

When adding new dashboard components, follow these steps:

1. Add component rendering tests to `dashboard_component_suite_test.rb`
2. Add accessibility tests to `dashboard_accessibility_test.rb`
3. Add keyboard navigation tests to `dashboard_keyboard_navigation_test.rb`
4. Add screen reader tests to `dashboard_screen_reader_test.rb`
5. Update theme documentation in `dashboard_theme_documentation_test.rb`

### Updating Baseline Screenshots

To update baseline screenshots for visual regression testing:

```bash
rails test:visual:update_baselines
```

### Troubleshooting Failed Tests

Common issues and solutions:

1. **Theme Switching Failures**
   - Check CSS variable definitions
   - Verify no hardcoded colors
   - Check theme switching JavaScript

2. **Accessibility Failures**
   - Check color contrast ratios
   - Verify proper ARIA attributes
   - Check keyboard navigation

3. **Visual Regression Failures**
   - Compare screenshots manually
   - Check for intentional design changes
   - Update baselines if changes are expected

## Conclusion

The dashboard test suite provides comprehensive coverage of theme consistency, accessibility compliance, and responsive design. By running these tests regularly, we can ensure the dashboard maintains high quality and meets all requirements.