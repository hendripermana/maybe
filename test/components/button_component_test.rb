# frozen_string_literal: true

require "test_helper"

class ButtonComponentTest < ComprehensiveComponentTestCase
  include MasterComponentTestingSuite

  test "renders button with default variant" do
    render_inline(ButtonComponent.new) { "Click me" }

    assert_selector "button.btn-modern-primary"
    assert_text "Click me"
  end

  test "renders button with primary variant" do
    render_inline(ButtonComponent.new(variant: :primary)) { "Primary Button" }

    assert_selector "button.btn-modern-primary"
    assert_text "Primary Button"
  end

  test "renders button with secondary variant" do
    render_inline(ButtonComponent.new(variant: :secondary)) { "Secondary Button" }

    assert_selector "button.btn-modern-secondary"
    assert_text "Secondary Button"
  end

  test "renders button with ghost variant" do
    render_inline(ButtonComponent.new(variant: :ghost)) { "Ghost Button" }

    assert_selector "button.btn-modern-ghost"
    assert_text "Ghost Button"
  end

  test "renders button with destructive variant" do
    render_inline(ButtonComponent.new(variant: :destructive)) { "Destructive Button" }

    assert_selector "button.btn-modern-destructive"
    assert_text "Destructive Button"
  end

  test "renders button with different sizes" do
    # Small size
    render_inline(ButtonComponent.new(size: :sm)) { "Small Button" }
    assert_selector "button.text-sm"

    # Medium size (default)
    render_inline(ButtonComponent.new(size: :md)) { "Medium Button" }
    assert_selector "button.text-sm"

    # Large size
    render_inline(ButtonComponent.new(size: :lg)) { "Large Button" }
    assert_selector "button.text-base"
  end

  test "renders disabled button" do
    render_inline(ButtonComponent.new(disabled: true)) { "Disabled Button" }

    assert_selector "button[disabled]"
    assert_selector "button.opacity-50"
  end

  test "renders button with custom class" do
    render_inline(ButtonComponent.new(class: "custom-class")) { "Custom Button" }

    assert_selector "button.custom-class"
  end

  test "renders button with icon" do
    render_inline(ButtonComponent.new(icon: "plus")) { "Button with Icon" }

    assert_selector "button svg"
    assert_text "Button with Icon"
  end

  test "renders button with proper theme awareness" do
    test_theme_switching(ButtonComponent.new) { "Theme Button" }

    # Check for theme-aware classes
    assert_component_theme_aware(ButtonComponent.new) { "Theme Button" }

    # Check for no hardcoded colors
    render_inline(ButtonComponent.new) { "No Hardcoded Colors" }
    assert_no_hardcoded_theme_classes
  end

  test "button meets accessibility requirements" do
    render_inline(ButtonComponent.new) { "Accessible Button" }

    # Check for proper role
    assert_selector "button[type]"

    # Check for focus styles
    assert_selector "button.focus:ring-2", visible: false

    # Check for hover styles
    assert_selector "button.hover:bg-opacity-90", visible: false
  end

  test "button handles interactions correctly" do
    render_inline(ButtonComponent.new(data: { action: "click->some-controller#action" })) { "Interactive Button" }

    # Check for click handler
    assert_selector "button[data-action]"
  end

  # Comprehensive test using our testing suite
  test "button passes comprehensive component testing" do
    test_component_comprehensively(
      ButtonComponent.new,
      content: "Test Button",
      interactions: [ :click, :hover, :focus, :keyboard ]
    )
  end

  # Test all variants at once
  test "all button variants are theme-aware" do
    variants = [ :primary, :secondary, :ghost, :destructive ]
    test_component_variants(ButtonComponent, :variant, variants)
  end

  # Test all sizes at once
  test "all button sizes are theme-aware" do
    sizes = [ :sm, :md, :lg ]
    test_component_sizes(ButtonComponent, :size, sizes)
  end
end
