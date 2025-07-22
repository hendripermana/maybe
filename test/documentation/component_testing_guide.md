# Component Testing Guide

This guide explains how to use the comprehensive component testing suite to test UI components in the Maybe finance application.

## Overview

The component testing suite provides tools for testing:

1. Basic component rendering
2. Theme switching and theme awareness
3. Accessibility compliance
4. Component interactions
5. Visual regression

## Getting Started

### Creating a New Component Test

To create a test for a component, create a new file in the `test/components` directory with the naming convention `component_name_test.rb`:

```ruby
# frozen_string_literal: true
require "test_helper"

class ButtonComponentTest < ComprehensiveComponentTestCase
  include MasterComponentTestingSuite
  
  test "renders button with default props" do
    render_inline(ButtonComponent.new) { "Click me" }
    
    assert_selector "button.btn-modern-primary"
    assert_text "Click me"
  end
  
  # Add more specific tests...
end
```

### Using the Testing Suite Helpers

The `MasterComponentTestingSuite` module provides several helper methods for comprehensive testing:

```ruby
# Test theme switching
test "button renders correctly in both themes" do
  test_theme_switching(ButtonComponent.new) { "Theme Button" }
end

# Test accessibility
test "button meets accessibility requirements" do
  test_component_accessibility(ButtonComponent.new) { "Accessible Button" }
end

# Test interactions
test "button handles interactions correctly" do
  test_component_interactions(ButtonComponent.new, [:click, :hover, :focus])
end

# Comprehensive test
test "button passes comprehensive component testing" do
  test_component_comprehensively(
    ButtonComponent.new,
    content: "Test Button",
    interactions: [:click, :hover, :focus, :keyboard]
  )
end
```

### Using the Test Generator

For standard components, you can use the test generator to create a complete test suite:

```ruby
class ButtonComponentTest < ComprehensiveComponentTestCase
  include MasterComponentTestingSuite
  
  # Generate standard tests for the component
  generate_standard_tests_for ButtonComponent, {
    props: { variant: :primary },
    content: "Test Button",
    interactive: true,
    theme_aware: true,
    accessibility: true,
    visual_regression: true,
    interactions: [:click, :hover, :focus, :keyboard]
  }
  
  # Add any additional specific tests...
end
```

## Testing Categories

### Theme Testing

Theme testing ensures components render correctly in both light and dark themes:

```ruby
test "component is theme-aware" do
  # Test in both themes
  test_theme_switching(ComponentName.new)
  
  # Check for theme-aware classes
  assert_component_theme_aware(ComponentName.new)
  
  # Check for no hardcoded colors
  assert_no_hardcoded_theme_classes
  
  # Check for CSS variables
  assert_css_variables_used
end
```

### Accessibility Testing

Accessibility testing ensures components meet WCAG 2.1 AA standards:

```ruby
test "component meets accessibility requirements" do
  render_inline(ComponentName.new)
  
  # Check for proper ARIA attributes
  assert_selector "[aria-label]"
  
  # Check for proper roles
  assert_selector "[role='button']"
  
  # Check for proper focus management
  assert_selector "[tabindex='0']"
end
```

### Interaction Testing

Interaction testing ensures components handle user interactions correctly:

```ruby
test "component handles interactions correctly" do
  render_inline(ComponentName.new)
  
  # Check for click handlers
  assert_selector "[data-action*='click->']"
  
  # Check for hover states
  assert_selector "[class*='hover:']"
  
  # Check for focus states
  assert_selector "[class*='focus:']"
end
```

### Visual Regression Testing

Visual regression testing captures screenshots of components in different themes and compares them to baseline images:

```ruby
test "component visual regression" do
  component_name = "button"
  variant = "primary"
  
  # Take screenshots in both themes
  ThemeTestHelper::THEMES.each do |theme|
    take_component_screenshot(component_name, variant: variant, theme: theme)
    compare_with_baseline("#{component_name}_#{variant}_#{theme}")
  end
end
```

## Running Tests

### Running Individual Component Tests

```bash
bundle exec ruby -I test test/components/button_component_test.rb
```

### Running All Component Tests

```bash
ruby test/run_component_tests.rb
```

## Best Practices

1. **Test all variants and sizes** - Ensure all component variants and sizes are tested
2. **Test both themes** - Always test components in both light and dark themes
3. **Test accessibility** - Ensure components meet WCAG 2.1 AA standards
4. **Test interactions** - Test all interactive behaviors
5. **Keep tests focused** - Each test should focus on a specific aspect of the component
6. **Use the testing helpers** - Use the provided helpers for consistent testing
7. **Update baselines when needed** - Update visual regression baselines when component designs change

## Troubleshooting

### Common Issues

1. **Test fails in one theme but not the other** - Check for hardcoded colors or theme-specific issues
2. **Accessibility tests fail** - Check for missing ARIA attributes or improper semantic structure
3. **Visual regression tests fail** - Compare the current and baseline screenshots to identify differences
4. **Interaction tests fail** - Check that the component has proper event handlers and interactive elements