# frozen_string_literal: true

require "test_helper"

class Ui::TooltipComponentTest < ViewComponent::TestCase
  include ComponentTestingSuiteHelper
  
  def test_renders_tooltip_with_text
    render_inline(Ui::TooltipComponent.new(text: "Tooltip Text")) do
      tag.button("Hover me")
    end
    
    assert_selector "button", text: "Hover me"
    assert_selector "[data-controller='ui--tooltip']"
    assert_selector "[data-ui--tooltip-text-value='Tooltip Text']"
  end
  
  def test_renders_tooltip_with_different_positions
    render_inline(Ui::TooltipComponent.new(text: "Top Tooltip", position: :top)) do
      tag.button("Top")
    end
    assert_selector "[data-ui--tooltip-position-value='top']"
    
    render_inline(Ui::TooltipComponent.new(text: "Bottom Tooltip", position: :bottom)) do
      tag.button("Bottom")
    end
    assert_selector "[data-ui--tooltip-position-value='bottom']"
    
    render_inline(Ui::TooltipComponent.new(text: "Left Tooltip", position: :left)) do
      tag.button("Left")
    end
    assert_selector "[data-ui--tooltip-position-value='left']"
    
    render_inline(Ui::TooltipComponent.new(text: "Right Tooltip", position: :right)) do
      tag.button("Right")
    end
    assert_selector "[data-ui--tooltip-position-value='right']"
  end
  
  def test_renders_tooltip_with_custom_delay
    render_inline(Ui::TooltipComponent.new(
      text: "Delayed Tooltip",
      delay_show: 500,
      delay_hide: 200
    )) do
      tag.button("Delayed")
    end
    
    assert_selector "[data-ui--tooltip-delay-show-value='500']"
    assert_selector "[data-ui--tooltip-delay-hide-value='200']"
  end
  
  def test_renders_tooltip_with_different_variants
    render_inline(Ui::TooltipComponent.new(text: "Default Tooltip", variant: :default)) do
      tag.button("Default")
    end
    assert_selector "[data-ui--tooltip-variant-value='default']"
    
    render_inline(Ui::TooltipComponent.new(text: "Primary Tooltip", variant: :primary)) do
      tag.button("Primary")
    end
    assert_selector "[data-ui--tooltip-variant-value='primary']"
    
    render_inline(Ui::TooltipComponent.new(text: "Success Tooltip", variant: :success)) do
      tag.button("Success")
    end
    assert_selector "[data-ui--tooltip-variant-value='success']"
    
    render_inline(Ui::TooltipComponent.new(text: "Warning Tooltip", variant: :warning)) do
      tag.button("Warning")
    end
    assert_selector "[data-ui--tooltip-variant-value='warning']"
    
    render_inline(Ui::TooltipComponent.new(text: "Destructive Tooltip", variant: :destructive)) do
      tag.button("Destructive")
    end
    assert_selector "[data-ui--tooltip-variant-value='destructive']"
  end
  
  def test_theme_switching
    test_component_comprehensively(
      Ui::TooltipComponent.new(text: "Theme Test") { tag.button("Theme Test") },
      interactions: [:hover, :focus]
    )
  end
  
  def test_accessibility
    render_inline(Ui::TooltipComponent.new(text: "Accessibility Test")) do
      tag.button("Accessible Button", aria: { label: "Accessible Button" })
    end
    
    assert_selector "button[aria-label='Accessible Button']"
    assert_selector "[data-ui--tooltip-text-value='Accessibility Test']"
  end
  
  def test_renders_with_custom_class
    render_inline(Ui::TooltipComponent.new(text: "Custom Class", class: "custom-class")) do
      tag.button("Custom")
    end
    
    assert_selector ".custom-class"
  end
  
  def test_renders_with_custom_id
    render_inline(Ui::TooltipComponent.new(text: "Custom ID", id: "custom-id")) do
      tag.button("Custom ID")
    end
    
    assert_selector "#custom-id"
  end
end