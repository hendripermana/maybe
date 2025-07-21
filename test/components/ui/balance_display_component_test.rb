# frozen_string_literal: true

require "test_helper"

class Ui::BalanceDisplayComponentTest < ViewComponent::TestCase
  def test_renders_positive_amount
    render_inline(Ui::BalanceDisplayComponent.new(amount: 1250.75))
    
    # This assumes format_currency helper works as expected
    assert_text "$1,250.75"
    assert_selector ".text-green-600"
  end
  
  def test_renders_negative_amount
    render_inline(Ui::BalanceDisplayComponent.new(amount: -450.25))
    
    # This assumes format_currency helper works as expected
    assert_text "$450.25"
    assert_selector ".text-red-600"
  end
  
  def test_renders_zero_amount
    render_inline(Ui::BalanceDisplayComponent.new(amount: 0))
    
    # This assumes format_currency helper works as expected
    assert_text "$0.00"
  end
  
  def test_renders_with_sign
    render_inline(Ui::BalanceDisplayComponent.new(amount: 1250.75, show_sign: true))
    
    # This assumes format_currency helper works as expected with show_sign: true
    assert_text "+$1,250.75"
  end
  
  def test_renders_with_indicator
    render_inline(Ui::BalanceDisplayComponent.new(amount: 1250.75, show_indicator: true))
    
    assert_selector "span.inline-flex"
  end
  
  def test_renders_with_custom_currency
    render_inline(Ui::BalanceDisplayComponent.new(amount: 1250.75, currency: "EUR"))
    
    # This assumes format_currency helper works as expected with EUR
    assert_text "€1,250.75"
  end
  
  def test_renders_different_variants
    render_inline(Ui::BalanceDisplayComponent.new(amount: 1250.75, variant: :primary))
    assert_selector ".text-blue-600"
    
    render_inline(Ui::BalanceDisplayComponent.new(amount: 1250.75, variant: :success))
    assert_selector ".text-green-600"
    
    render_inline(Ui::BalanceDisplayComponent.new(amount: 1250.75, variant: :warning))
    assert_selector ".text-yellow-600"
    
    render_inline(Ui::BalanceDisplayComponent.new(amount: 1250.75, variant: :destructive))
    assert_selector ".text-red-600"
  end
  
  def test_renders_different_sizes
    render_inline(Ui::BalanceDisplayComponent.new(amount: 1250.75, size: :xs))
    assert_selector ".text-xs"
    
    render_inline(Ui::BalanceDisplayComponent.new(amount: 1250.75, size: :sm))
    assert_selector ".text-sm"
    
    render_inline(Ui::BalanceDisplayComponent.new(amount: 1250.75, size: :md))
    assert_selector ".text-base"
    
    render_inline(Ui::BalanceDisplayComponent.new(amount: 1250.75, size: :lg))
    assert_selector ".text-lg"
    
    render_inline(Ui::BalanceDisplayComponent.new(amount: 1250.75, size: :xl))
    assert_selector ".text-xl"
    
    render_inline(Ui::BalanceDisplayComponent.new(amount: 1250.75, size: :"2xl"))
    assert_selector ".text-2xl"
    
    render_inline(Ui::BalanceDisplayComponent.new(amount: 1250.75, size: :"3xl"))
    assert_selector ".text-3xl"
  end
end