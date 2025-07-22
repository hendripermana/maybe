# frozen_string_literal: true
require "test_helper"

class ToggleComponentTest < ComprehensiveComponentTestCase
  include MasterComponentTestingSuite
  
  test "renders toggle with default options" do
    render_inline(ToggleComponent.new(name: "test-toggle"))
    
    assert_selector ".toggle-component"
    assert_selector "input[type='checkbox'][name='test-toggle']"
  end
  
  test "renders toggle with checked state" do
    render_inline(ToggleComponent.new(name: "test-toggle", checked: true))
    
    assert_selector "input[type='checkbox'][name='test-toggle'][checked]"
  end
  
  test "renders toggle with label" do
    render_inline(ToggleComponent.new(name: "test-toggle", label: "Toggle Label"))
    
    assert_selector ".toggle-component"
    assert_selector "label", text: "Toggle Label"
    assert_selector "input[type='checkbox'][name='test-toggle']"
  end
  
  test "renders toggle with disabled state" do
    render_inline(ToggleComponent.new(name: "test-toggle", disabled: true))
    
    assert_selector "input[type='checkbox'][name='test-toggle'][disabled]"
    assert_selector ".toggle-component.opacity-50"
  end
  
  test "renders toggle with custom class" do
    render_inline(ToggleComponent.new(name: "test-toggle", class: "custom-toggle"))
    
    assert_selector ".toggle-component.custom-toggle"
  end
  
  test "renders toggle with size options" do
    # Small size
    render_inline(ToggleComponent.new(name: "test-toggle", size: :sm))
    assert_selector ".toggle-component.toggle-sm"
    
    # Medium size (default)
    render_inline(ToggleComponent.new(name: "test-toggle", size: :md))
    assert_selector ".toggle-component.toggle-md"
    
    # Large size
    render_inline(ToggleComponent.new(name: "test-toggle", size: :lg))
    assert_selector ".toggle-component.toggle-lg"
  end
  
  test "renders toggle with proper theme awareness" do
    test_theme_switching(ToggleComponent.new(name: "test-toggle"))
    
    # Check for theme-aware classes
    assert_component_theme_aware(ToggleComponent.new(name: "test-toggle"))
    
    # Check for no hardcoded colors
    render_inline(ToggleComponent.new(name: "test-toggle"))
    assert_no_hardcoded_theme_classes
  end
  
  test "toggle meets accessibility requirements" do
    render_inline(ToggleComponent.new(
      name: "test-toggle",
      label: "Accessible Toggle",
      aria: { describedby: "toggle-description" }
    ))
    
    # Check for proper label association
    assert_selector "label[for]"
    
    # Check for proper ARIA attributes
    assert_selector "input[aria-describedby='toggle-description']"
  end
  
  test "toggle handles interactions correctly" do
    render_inline(ToggleComponent.new(
      name: "test-toggle",
      data: { action: "change->form#submit" }
    ))
    
    # Check for change handler
    assert_selector "input[data-action*='change->form#submit']"
  end
  
  # Comprehensive test using our testing suite
  test "toggle passes comprehensive component testing" do
    test_component_comprehensively(
      ToggleComponent.new(name: "test-toggle", label: "Test Toggle"),
      interactions: [:click, :keyboard]
    )
  end
  
  # Test all sizes at once
  test "all toggle sizes are theme-aware" do
    sizes = [:sm, :md, :lg]
    test_component_sizes(ToggleComponent, :size, sizes, { name: "test-toggle" })
  end
end