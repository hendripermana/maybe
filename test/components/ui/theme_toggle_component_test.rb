# frozen_string_literal: true

require "test_helper"

class Ui::ThemeToggleComponentTest < ViewComponent::TestCase
  include ComponentTestingSuiteHelper
  
  def test_renders_theme_toggle
    render_inline(Ui::ThemeToggleComponent.new)
    
    assert_selector "button[data-testid='theme-toggle']"
    assert_selector "[data-controller='ui--theme-toggle']"
  end
  
  def test_renders_with_different_sizes
    render_inline(Ui::ThemeToggleComponent.new(size: :sm))
    assert_selector "button.h-8.w-8"
    
    render_inline(Ui::ThemeToggleComponent.new(size: :md))
    assert_selector "button.h-10.w-10"
    
    render_inline(Ui::ThemeToggleComponent.new(size: :lg))
    assert_selector "button.h-12.w-12"
  end
  
  def test_renders_with_custom_class
    render_inline(Ui::ThemeToggleComponent.new(class: "custom-class"))
    
    assert_selector "button.custom-class"
  end
  
  def test_renders_with_custom_id
    render_inline(Ui::ThemeToggleComponent.new(id: "custom-id"))
    
    assert_selector "button#custom-id"
  end
  
  def test_renders_with_custom_aria_label
    render_inline(Ui::ThemeToggleComponent.new(aria_label: "Custom theme toggle"))
    
    assert_selector "button[aria-label='Custom theme toggle']"
  end
  
  def test_theme_switching
    test_component_comprehensively(
      Ui::ThemeToggleComponent.new,
      interactions: [:hover, :focus, :click]
    )
  end
  
  def test_accessibility
    render_inline(Ui::ThemeToggleComponent.new)
    
    # Check for proper ARIA attributes
    assert_selector "button[aria-label]"
    assert_selector "button[role='switch']"
  end
  
  def test_renders_with_initial_theme
    render_inline(Ui::ThemeToggleComponent.new(initial_theme: "dark"))
    
    assert_selector "[data-ui--theme-toggle-initial-theme-value='dark']"
    
    render_inline(Ui::ThemeToggleComponent.new(initial_theme: "light"))
    
    assert_selector "[data-ui--theme-toggle-initial-theme-value='light']"
  end
  
  def test_renders_with_icons
    render_inline(Ui::ThemeToggleComponent.new(show_icons: true))
    
    assert_selector "svg"
  end
  
  def test_renders_without_icons
    render_inline(Ui::ThemeToggleComponent.new(show_icons: false))
    
    assert_no_selector "svg"
  end
end