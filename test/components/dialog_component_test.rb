# frozen_string_literal: true
require "test_helper"

class DialogComponentTest < ComprehensiveComponentTestCase
  include MasterComponentTestingSuite
  
  test "renders dialog with default options" do
    render_inline(DialogComponent.new(id: "test-dialog")) { "Dialog Content" }
    
    assert_selector "#test-dialog.dialog-modern"
    assert_selector "[role='dialog']"
    assert_text "Dialog Content"
  end
  
  test "renders dialog with title" do
    render_inline(DialogComponent.new(id: "test-dialog", title: "Dialog Title")) { "Dialog with Title" }
    
    assert_selector "#test-dialog.dialog-modern"
    assert_selector ".dialog-title", text: "Dialog Title"
    assert_text "Dialog with Title"
  end
  
  test "renders dialog with close button" do
    render_inline(DialogComponent.new(id: "test-dialog", close_button: true)) { "Dialog with Close Button" }
    
    assert_selector "#test-dialog.dialog-modern"
    assert_selector "button.dialog-close"
    assert_text "Dialog with Close Button"
  end
  
  test "renders dialog with custom class" do
    render_inline(DialogComponent.new(id: "test-dialog", class: "custom-dialog")) { "Custom Dialog" }
    
    assert_selector "#test-dialog.dialog-modern.custom-dialog"
    assert_text "Custom Dialog"
  end
  
  test "renders dialog with size options" do
    # Small size
    render_inline(DialogComponent.new(id: "test-dialog", size: :sm)) { "Small Dialog" }
    assert_selector "#test-dialog.dialog-modern.dialog-sm"
    
    # Medium size (default)
    render_inline(DialogComponent.new(id: "test-dialog", size: :md)) { "Medium Dialog" }
    assert_selector "#test-dialog.dialog-modern.dialog-md"
    
    # Large size
    render_inline(DialogComponent.new(id: "test-dialog", size: :lg)) { "Large Dialog" }
    assert_selector "#test-dialog.dialog-modern.dialog-lg"
    
    # Full size
    render_inline(DialogComponent.new(id: "test-dialog", size: :full)) { "Full Dialog" }
    assert_selector "#test-dialog.dialog-modern.dialog-full"
  end
  
  test "renders dialog with proper theme awareness" do
    test_theme_switching(DialogComponent.new(id: "test-dialog")) { "Theme Dialog" }
    
    # Check for theme-aware classes
    assert_component_theme_aware(DialogComponent.new(id: "test-dialog")) { "Theme Dialog" }
    
    # Check for no hardcoded colors
    render_inline(DialogComponent.new(id: "test-dialog")) { "No Hardcoded Colors" }
    assert_no_hardcoded_theme_classes
  end
  
  test "dialog meets accessibility requirements" do
    render_inline(DialogComponent.new(
      id: "test-dialog",
      title: "Accessible Dialog",
      aria: { labelledby: "dialog-title" }
    )) { "Dialog Content" }
    
    # Check for proper ARIA attributes
    assert_selector "[role='dialog']"
    assert_selector "[aria-labelledby='dialog-title']"
    
    # Check for proper focus management
    assert_selector "[data-controller='dialog']"
  end
  
  test "dialog handles interactions correctly" do
    render_inline(DialogComponent.new(
      id: "test-dialog",
      close_button: true,
      data: { action: "keydown.escape->dialog#close" }
    )) { "Interactive Dialog" }
    
    # Check for click handler on close button
    assert_selector "button.dialog-close[data-action]"
    
    # Check for keyboard event handler
    assert_selector "[data-action*='keydown.escape->dialog#close']"
  end
  
  # Comprehensive test using our testing suite
  test "dialog passes comprehensive component testing" do
    test_component_comprehensively(
      DialogComponent.new(id: "test-dialog", title: "Test Dialog"),
      content: "Dialog Content",
      interactions: [:click, :keyboard]
    )
  end
  
  # Test all sizes at once
  test "all dialog sizes are theme-aware" do
    sizes = [:sm, :md, :lg, :full]
    sizes.each do |size|
      render_inline(DialogComponent.new(id: "test-dialog", size: size)) { "#{size.to_s.capitalize} Dialog" }
      assert_selector "#test-dialog.dialog-modern.dialog-#{size}"
    end
  end
end