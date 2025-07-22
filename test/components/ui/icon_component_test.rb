# frozen_string_literal: true

require "test_helper"

class Ui::IconComponentTest < ViewComponent::TestCase
  include ComponentTestingSuiteHelper
  
  def test_renders_icon
    render_inline(Ui::IconComponent.new(name: "check"))
    
    assert_selector "svg"
  end
  
  def test_renders_different_sizes
    render_inline(Ui::IconComponent.new(name: "check", size: :xs))
    assert_selector "svg.w-3.h-3"
    
    render_inline(Ui::IconComponent.new(name: "check", size: :sm))
    assert_selector "svg.w-4.h-4"
    
    render_inline(Ui::IconComponent.new(name: "check", size: :md))
    assert_selector "svg.w-5.h-5"
    
    render_inline(Ui::IconComponent.new(name: "check", size: :lg))
    assert_selector "svg.w-6.h-6"
    
    render_inline(Ui::IconComponent.new(name: "check", size: :xl))
    assert_selector "svg.w-8.h-8"
  end
  
  def test_renders_different_variants
    render_inline(Ui::IconComponent.new(name: "check", variant: :default))
    assert_selector "svg.text-foreground"
    
    render_inline(Ui::IconComponent.new(name: "check", variant: :primary))
    assert_selector "svg.text-primary"
    
    render_inline(Ui::IconComponent.new(name: "check", variant: :secondary))
    assert_selector "svg.text-secondary"
    
    render_inline(Ui::IconComponent.new(name: "check", variant: :muted))
    assert_selector "svg.text-muted"
    
    render_inline(Ui::IconComponent.new(name: "check", variant: :accent))
    assert_selector "svg.text-accent"
    
    render_inline(Ui::IconComponent.new(name: "check", variant: :success))
    assert_selector "svg.text-success"
    
    render_inline(Ui::IconComponent.new(name: "check", variant: :warning))
    assert_selector "svg.text-warning"
    
    render_inline(Ui::IconComponent.new(name: "check", variant: :destructive))
    assert_selector "svg.text-destructive"
  end
  
  def test_renders_with_custom_class
    render_inline(Ui::IconComponent.new(name: "check", class: "custom-class"))
    
    assert_selector "svg.custom-class"
  end
  
  def test_renders_with_custom_id
    render_inline(Ui::IconComponent.new(name: "check", id: "custom-id"))
    
    assert_selector "svg#custom-id"
  end
  
  def test_theme_switching
    test_component_comprehensively(
      Ui::IconComponent.new(name: "check")
    )
  end
  
  def test_accessibility
    render_inline(Ui::IconComponent.new(
      name: "check",
      aria_label: "Success indicator"
    ))
    
    assert_selector "svg[aria-label='Success indicator']"
    assert_no_selector "svg[aria-hidden='true']"
    
    render_inline(Ui::IconComponent.new(
      name: "check",
      decorative: true
    ))
    
    assert_selector "svg[aria-hidden='true']"
    assert_no_selector "svg[aria-label]"
  end
end