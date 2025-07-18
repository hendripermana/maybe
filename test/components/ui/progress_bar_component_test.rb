require "test_helper"

class UI::ProgressBarComponentTest < ViewComponent::TestCase
  def test_renders_with_default_values
    render_inline(UI::ProgressBarComponent.new)
    
    assert_selector("div[role='progressbar']")
    assert_selector("div[style='width: 0%']")
  end
  
  def test_renders_with_custom_value
    render_inline(UI::ProgressBarComponent.new(value: 50))
    
    assert_selector("div[role='progressbar'][aria-valuenow='50']")
    assert_selector("div[style='width: 50%']")
  end
  
  def test_renders_with_custom_variant
    render_inline(UI::ProgressBarComponent.new(value: 50, variant: :success))
    
    assert_selector("div.bg-green-500")
  end
  
  def test_renders_with_custom_size
    render_inline(UI::ProgressBarComponent.new(value: 50, size: :lg))
    
    assert_selector("div.h-3")
  end
  
  def test_renders_with_label
    render_inline(UI::ProgressBarComponent.new(value: 50, show_label: true, label: "Budget Progress"))
    
    assert_text("Budget Progress")
    assert_text("50%")
  end
  
  def test_caps_percent_at_100
    render_inline(UI::ProgressBarComponent.new(value: 150, max: 100))
    
    assert_selector("div[aria-valuenow='100']")
    assert_selector("div[style='width: 100%']")
  end
end