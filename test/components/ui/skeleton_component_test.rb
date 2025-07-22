# frozen_string_literal: true

require "test_helper"

class Ui::SkeletonComponentTest < ViewComponent::TestCase
  include ComponentTestingSuiteHelper
  
  def test_renders_default_skeleton
    render_inline(Ui::SkeletonComponent.new)
    
    assert_selector ".animate-pulse.rounded-md.bg-muted"
  end
  
  def test_renders_with_custom_dimensions
    render_inline(Ui::SkeletonComponent.new(width: "200px", height: "100px"))
    
    assert_selector "[style*='width: 200px']"
    assert_selector "[style*='height: 100px']"
  end
  
  def test_renders_with_percentage_dimensions
    render_inline(Ui::SkeletonComponent.new(width: "50%", height: "25%"))
    
    assert_selector "[style*='width: 50%']"
    assert_selector "[style*='height: 25%']"
  end
  
  def test_renders_without_animation
    render_inline(Ui::SkeletonComponent.new(animate: false))
    
    assert_no_selector ".animate-pulse"
  end
  
  def test_renders_with_custom_rounded_corners
    render_inline(Ui::SkeletonComponent.new(rounded: "full"))
    
    assert_selector ".rounded-full"
    assert_no_selector ".rounded-md"
  end
  
  def test_renders_different_variants
    render_inline(Ui::SkeletonComponent.new(variant: :default))
    assert_selector ".bg-muted"
    
    render_inline(Ui::SkeletonComponent.new(variant: :primary))
    assert_selector ".bg-primary/20"
    
    render_inline(Ui::SkeletonComponent.new(variant: :success))
    assert_selector ".bg-success/20"
    
    render_inline(Ui::SkeletonComponent.new(variant: :warning))
    assert_selector ".bg-warning/20"
    
    render_inline(Ui::SkeletonComponent.new(variant: :destructive))
    assert_selector ".bg-destructive/20"
  end
  
  def test_theme_switching
    test_component_comprehensively(
      Ui::SkeletonComponent.new(width: "100px", height: "20px")
    )
  end
  
  def test_respects_reduced_motion_preferences
    with_reduced_motion do
      render_inline(Ui::SkeletonComponent.new)
      
      assert_no_selector ".animate-pulse"
    end
  end
  
  def test_renders_with_custom_class
    render_inline(Ui::SkeletonComponent.new(class: "custom-class"))
    
    assert_selector ".custom-class"
  end
  
  def test_renders_with_custom_id
    render_inline(Ui::SkeletonComponent.new(id: "custom-id"))
    
    assert_selector "#custom-id"
  end
  
  def test_renders_with_screen_reader_text
    render_inline(Ui::SkeletonComponent.new(
      width: "100px", 
      height: "20px",
      screen_reader_text: "Loading content"
    ))
    
    assert_selector "[aria-label='Loading content']"
    assert_selector ".sr-only", text: "Loading content"
  end
end