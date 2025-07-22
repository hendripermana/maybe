# frozen_string_literal: true
require "test_helper"

class CardComponentTest < ComprehensiveComponentTestCase
  include MasterComponentTestingSuite
  
  test "renders card with default options" do
    render_inline(CardComponent.new) { "Card Content" }
    
    assert_selector ".card-modern"
    assert_text "Card Content"
  end
  
  test "renders card with title" do
    render_inline(CardComponent.new(title: "Card Title")) { "Card with Title" }
    
    assert_selector ".card-modern"
    assert_selector ".card-title", text: "Card Title"
    assert_text "Card with Title"
  end
  
  test "renders card with footer" do
    render_inline(CardComponent.new(footer: "Card Footer")) { "Card with Footer" }
    
    assert_selector ".card-modern"
    assert_selector ".card-footer", text: "Card Footer"
    assert_text "Card with Footer"
  end
  
  test "renders card with custom class" do
    render_inline(CardComponent.new(class: "custom-card")) { "Custom Card" }
    
    assert_selector ".card-modern.custom-card"
    assert_text "Custom Card"
  end
  
  test "renders card with padding options" do
    # No padding
    render_inline(CardComponent.new(padding: false)) { "No Padding Card" }
    assert_selector ".card-modern:not(.p-6)"
    
    # Default padding
    render_inline(CardComponent.new) { "Default Padding Card" }
    assert_selector ".card-modern.p-6"
    
    # Custom padding
    render_inline(CardComponent.new(padding: "p-4")) { "Custom Padding Card" }
    assert_selector ".card-modern.p-4"
  end
  
  test "renders card with proper theme awareness" do
    test_theme_switching(CardComponent.new) { "Theme Card" }
    
    # Check for theme-aware classes
    assert_component_theme_aware(CardComponent.new) { "Theme Card" }
    
    # Check for no hardcoded colors
    render_inline(CardComponent.new) { "No Hardcoded Colors" }
    assert_no_hardcoded_theme_classes
  end
  
  test "card meets accessibility requirements" do
    render_inline(CardComponent.new(title: "Accessible Card")) { "Card Content" }
    
    # Check for proper heading structure
    assert_selector "h3.card-title", text: "Accessible Card"
    
    # Check for proper contrast
    assert_css_variables_used
  end
  
  # Comprehensive test using our testing suite
  test "card passes comprehensive component testing" do
    test_component_comprehensively(
      CardComponent.new(title: "Test Card"),
      content: "Card Content",
      interactions: [] # Cards are not interactive by default
    )
  end
  
  # Test card with interactive content
  test "card with interactive content handles interactions correctly" do
    render_inline(CardComponent.new) do
      content_tag :button, "Click Me", class: "btn-modern-primary"
    end
    
    assert_selector ".card-modern button.btn-modern-primary"
  end
end