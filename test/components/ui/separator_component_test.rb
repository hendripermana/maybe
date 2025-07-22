# frozen_string_literal: true

require "test_helper"

class Ui::SeparatorComponentTest < ViewComponent::TestCase
  include ComponentTestingSuiteHelper
  
  def test_renders_horizontal_separator
    render_inline(Ui::SeparatorComponent.new)
    
    assert_selector "hr.h-px.w-full"
  end
  
  def test_renders_vertical_separator
    render_inline(Ui::SeparatorComponent.new(orientation: :vertical))
    
    assert_selector "div.h-full.w-px"
  end
  
  def test_renders_decorative_separator
    render_inline(Ui::SeparatorComponent.new(decorative: true))
    
    assert_selector "hr[aria-hidden='true']"
  end
  
  def test_renders_semantic_separator
    render_inline(Ui::SeparatorComponent.new(decorative: false))
    
    assert_no_selector "hr[aria-hidden='true']"
  end
  
  def test_renders_different_variants
    render_inline(Ui::SeparatorComponent.new(variant: :default))
    assert_selector ".bg-border"
    
    render_inline(Ui::SeparatorComponent.new(variant: :primary))
    assert_selector ".bg-primary"
    
    render_inline(Ui::SeparatorComponent.new(variant: :success))
    assert_selector ".bg-success"
    
    render_inline(Ui::SeparatorComponent.new(variant: :warning))
    assert_selector ".bg-warning"
    
    render_inline(Ui::SeparatorComponent.new(variant: :destructive))
    assert_selector ".bg-destructive"
  end
  
  def test_theme_switching
    test_component_comprehensively(
      Ui::SeparatorComponent.new
    )
  end
  
  def test_renders_with_custom_class
    render_inline(Ui::SeparatorComponent.new(class: "custom-class"))
    
    assert_selector ".custom-class"
  end
  
  def test_renders_with_custom_id
    render_inline(Ui::SeparatorComponent.new(id: "custom-id"))
    
    assert_selector "#custom-id"
  end
end