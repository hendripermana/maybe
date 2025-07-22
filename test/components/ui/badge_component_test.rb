# frozen_string_literal: true

require "test_helper"

class Ui::BadgeComponentTest < ViewComponent::TestCase
  include ComponentTestingSuiteHelper
  
  def test_renders_default_badge
    render_inline(Ui::BadgeComponent.new) { "Badge Text" }
    
    assert_text "Badge Text"
    assert_selector ".inline-flex.items-center"
  end
  
  def test_renders_different_variants
    render_inline(Ui::BadgeComponent.new(variant: :default)) { "Default" }
    assert_selector ".bg-muted"
    
    render_inline(Ui::BadgeComponent.new(variant: :primary)) { "Primary" }
    assert_selector ".bg-primary"
    
    render_inline(Ui::BadgeComponent.new(variant: :secondary)) { "Secondary" }
    assert_selector ".bg-secondary"
    
    render_inline(Ui::BadgeComponent.new(variant: :success)) { "Success" }
    assert_selector ".bg-success"
    
    render_inline(Ui::BadgeComponent.new(variant: :warning)) { "Warning" }
    assert_selector ".bg-warning"
    
    render_inline(Ui::BadgeComponent.new(variant: :destructive)) { "Destructive" }
    assert_selector ".bg-destructive"
    
    render_inline(Ui::BadgeComponent.new(variant: :outline)) { "Outline" }
    assert_selector ".border"
  end
  
  def test_renders_with_icon
    render_inline(Ui::BadgeComponent.new(icon: "check")) { "With Icon" }
    
    assert_text "With Icon"
    assert_selector "svg"
  end
  
  def test_renders_with_count
    render_inline(Ui::BadgeComponent.new(count: 5)) { "Items" }
    
    assert_text "Items"
    assert_text "5"
  end
  
  def test_renders_removable_badge
    render_inline(Ui::BadgeComponent.new(removable: true)) { "Removable" }
    
    assert_text "Removable"
    assert_selector "button[aria-label='Remove']"
    assert_selector "[data-action='click->ui--badge#remove']"
  end
  
  def test_theme_switching
    test_component_comprehensively(
      Ui::BadgeComponent.new { "Theme Test" },
      interactions: [:hover, :focus]
    )
  end
  
  def test_accessibility
    render_inline(Ui::BadgeComponent.new(removable: true)) { "Accessibility Test" }
    
    # Check for proper ARIA attributes on remove button
    assert_selector "button[aria-label='Remove']"
  end
  
  def test_renders_with_custom_class
    render_inline(Ui::BadgeComponent.new(class: "custom-class")) { "Custom Class" }
    
    assert_selector ".custom-class"
  end
end