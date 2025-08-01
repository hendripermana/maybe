# frozen_string_literal: true

require "test_helper"

class AlertComponentTest < ComprehensiveComponentTestCase
  include MasterComponentTestingSuite

  test "renders alert with default options" do
    render_inline(AlertComponent.new) { "Alert Content" }

    assert_selector ".alert-modern"
    assert_text "Alert Content"
  end

  test "renders alert with different variants" do
    # Info variant (default)
    render_inline(AlertComponent.new(variant: :info)) { "Info Alert" }
    assert_selector ".alert-modern.alert-info"

    # Success variant
    render_inline(AlertComponent.new(variant: :success)) { "Success Alert" }
    assert_selector ".alert-modern.alert-success"

    # Warning variant
    render_inline(AlertComponent.new(variant: :warning)) { "Warning Alert" }
    assert_selector ".alert-modern.alert-warning"

    # Error variant
    render_inline(AlertComponent.new(variant: :error)) { "Error Alert" }
    assert_selector ".alert-modern.alert-error"
  end

  test "renders alert with title" do
    render_inline(AlertComponent.new(title: "Alert Title")) { "Alert with Title" }

    assert_selector ".alert-modern"
    assert_selector ".alert-title", text: "Alert Title"
    assert_text "Alert with Title"
  end

  test "renders alert with icon" do
    render_inline(AlertComponent.new(icon: true)) { "Alert with Icon" }

    assert_selector ".alert-modern"
    assert_selector ".alert-icon svg"
    assert_text "Alert with Icon"
  end

  test "renders alert with dismissible option" do
    render_inline(AlertComponent.new(dismissible: true)) { "Dismissible Alert" }

    assert_selector ".alert-modern"
    assert_selector "button.alert-dismiss"
    assert_text "Dismissible Alert"
  end

  test "renders alert with custom class" do
    render_inline(AlertComponent.new(class: "custom-alert")) { "Custom Alert" }

    assert_selector ".alert-modern.custom-alert"
    assert_text "Custom Alert"
  end

  test "renders alert with proper theme awareness" do
    test_theme_switching(AlertComponent.new) { "Theme Alert" }

    # Check for theme-aware classes
    assert_component_theme_aware(AlertComponent.new) { "Theme Alert" }

    # Check for no hardcoded colors
    render_inline(AlertComponent.new) { "No Hardcoded Colors" }
    assert_no_hardcoded_theme_classes
  end

  test "alert meets accessibility requirements" do
    render_inline(AlertComponent.new(
      role: "alert",
      title: "Accessible Alert"
    )) { "Alert Content" }

    # Check for proper ARIA attributes
    assert_selector "[role='alert']"

    # Check for proper heading structure
    assert_selector ".alert-title", text: "Accessible Alert"
  end

  test "alert handles interactions correctly" do
    render_inline(AlertComponent.new(
      dismissible: true,
      data: { controller: "alert", action: "click->alert#dismiss" }
    )) { "Interactive Alert" }

    # Check for click handler on dismiss button
    assert_selector "button.alert-dismiss[data-action]"
  end

  # Comprehensive test using our testing suite
  test "alert passes comprehensive component testing" do
    test_component_comprehensively(
      AlertComponent.new(title: "Test Alert", dismissible: true),
      content: "Alert Content",
      interactions: [ :click ]
    )
  end

  # Test all variants at once
  test "all alert variants are theme-aware" do
    variants = [ :info, :success, :warning, :error ]
    test_component_variants(AlertComponent, :variant, variants)
  end
end
