# UI Component Testing Infrastructure

This directory contains comprehensive testing utilities for UI components, focusing on theme consistency, accessibility, and visual regression testing.

## Overview

The testing infrastructure provides three main areas of functionality:

1. **Visual Regression Testing** - Automated screenshot comparison
2. **Theme Testing** - Light/dark theme consistency validation  
3. **Accessibility Testing** - WCAG 2.1 AA compliance verification

## Testing Helpers

### VisualRegressionHelper

Provides utilities for taking and comparing screenshots across different themes and viewports.

```ruby
# Take a screenshot for visual comparison
assert_visual_regression('button', variant: 'primary', theme: 'light')

# Test across multiple viewports
with_viewport(375, 667) do
  assert_visual_regression('mobile_layout', theme: 'dark')
end
```

### ThemeTestHelper

Validates that components properly support light and dark themes without hardcoded colors.

```ruby
# Test component in both themes
test_both_themes do
  assert_theme_aware_colors('.btn-primary')
  assert_no_hardcoded_colors('.btn-primary')
end

# Test theme switching
toggle_theme
assert_theme_applied('dark')
assert_theme_consistency('.card-component')
```

### AccessibilityTestHelper

Ensures components meet WCAG accessibility standards.

```ruby
# Test color contrast
assert_sufficient_color_contrast('.btn-primary', level: :aa)

# Test keyboard navigation
assert_keyboard_navigable('button')

# Test screen reader compatibility
assert_accessible_name('.btn-primary')
assert_proper_form_labels
```

## Component Test Base Classes

### ComponentTestCase

Base class for ViewComponent tests with theme support.

```ruby
class ButtonComponentTest < ComponentTestCase
  def test_theme_awareness
    component = ButtonComponent.new(variant: :primary)
    assert_component_theme_aware(component) { "Test" }
  end
  
  def test_no_hardcoded_colors
    render_inline(ButtonComponent.new) { "Button" }
    assert_no_hardcoded_theme_classes
    assert_css_variables_used
  end
end
```

## System Test Examples

### Theme Testing

```ruby
class UiComponentThemeTest < ApplicationSystemTestCase
  test "components maintain theme consistency" do
    visit dashboard_path
    
    # Test all dashboard cards
    page.all('.dashboard-card').each do |card|
      assert_theme_consistency(card)
      assert_no_hardcoded_colors(card)
    end
  end
end
```

### Accessibility Testing

```ruby
test "form accessibility compliance" do
  visit new_account_path
  
  assert_proper_form_labels
  assert_no_accessibility_violations
  assert_keyboard_navigable('input[type="text"]')
end
```

### Visual Regression Testing

```ruby
visual_regression_test "dashboard_layout" do
  visit dashboard_path
  
  # Test in both themes
  with_theme('light') do
    assert_visual_regression('dashboard', theme: 'light')
  end
  
  with_theme('dark') do
    assert_visual_regression('dashboard', theme: 'dark')
  end
end
```

## Configuration

The testing infrastructure is configured via `UiTestingConfig`:

```ruby
# Visual regression settings
UiTestingConfig::VISUAL_REGRESSION_CONFIG[:threshold] # Difference threshold
UiTestingConfig::VISUAL_REGRESSION_CONFIG[:viewports] # Test viewports

# Theme testing settings  
UiTestingConfig::THEME_CONFIG[:themes] # Supported themes
UiTestingConfig::THEME_CONFIG[:css_variables] # Required CSS variables

# Accessibility settings
UiTestingConfig::ACCESSIBILITY_CONFIG[:wcag_level] # WCAG compliance level
UiTestingConfig::ACCESSIBILITY_CONFIG[:color_contrast] # Contrast ratios
```

## Running Tests

### Component Tests
```bash
# Run all component tests
rails test test/components/

# Run specific component test
rails test test/components/ui/button_component_test.rb
```

### System Tests
```bash
# Run all system tests
rails test:system

# Run UI-specific system tests
rails test test/system/ui_component_theme_test.rb
```

### Visual Regression Tests
```bash
# Run with screenshot generation
VISUAL_REGRESSION=true rails test:system

# Clean up old screenshots
rails runner "UiTestingConfig.cleanup_old_screenshots"
```

## Best Practices

### Component Testing

1. **Always test both themes** - Use `test_both_themes` or `assert_component_theme_aware`
2. **Verify no hardcoded colors** - Use `assert_no_hardcoded_theme_classes`
3. **Check CSS variable usage** - Use `assert_css_variables_used`
4. **Test all variants** - Test different component variants, sizes, and states

### System Testing

1. **Test real user workflows** - Focus on actual user interactions
2. **Include accessibility checks** - Always run `assert_no_accessibility_violations`
3. **Test responsive behavior** - Use `with_viewport` for different screen sizes
4. **Verify theme switching** - Test theme toggle functionality

### Visual Regression

1. **Establish baselines** - First run creates baseline screenshots
2. **Review changes carefully** - Visual differences may indicate regressions
3. **Test key viewports** - Mobile, tablet, and desktop breakpoints
4. **Include both themes** - Light and dark mode screenshots

## Troubleshooting

### Common Issues

**Theme tests failing:**
- Check that CSS variables are properly defined
- Verify theme switching mechanism works
- Ensure no hardcoded colors in components

**Accessibility tests failing:**
- Add proper ARIA labels and descriptions
- Check color contrast ratios
- Verify keyboard navigation works

**Visual regression tests failing:**
- Review screenshot differences carefully
- Update baselines if changes are intentional
- Check for timing issues in dynamic content

### Debug Helpers

```ruby
# Debug theme state
puts current_theme
puts get_css_variable_value('--background')

# Debug accessibility
puts get_accessible_name(element)
puts calculate_contrast_ratio([255,255,255], [0,0,0])

# Debug visual regression
take_component_screenshot('debug', variant: 'test')
```

## Integration with CI/CD

The testing infrastructure is designed to work in CI environments:

- Screenshots are stored in `test/visual_regression/screenshots/`
- Baseline images should be committed to version control
- Tests run in headless mode in CI environments
- Accessibility violations fail tests automatically

For CI setup, ensure:
- Selenium WebDriver is properly configured
- Screenshot directories are writable
- Baseline images are available in the repository