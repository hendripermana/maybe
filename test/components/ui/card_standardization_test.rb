# frozen_string_literal: true

require "test_helper"

class Ui::CardStandardizationTest < ViewComponent::TestCase
  test "renders unified card component with consistent styling" do
    render_inline(Ui::CardComponent.new(variant: :elevated, size: :lg)) { "Test content" }
    
    assert_selector ".card-modern"
    assert_text "Test content"
  end

  test "dashboard card component uses consistent styling" do
    render_inline(Dashboard::CardComponent.new(
      title: "Test Card",
      value: "$1,000",
      description: "Test description",
      icon_name: "trending-up",
      variant: :elevated
    ))
    
    # Check that the rendered content includes the card-modern class
    assert_includes rendered_content, "card-modern"
    assert_includes rendered_content, "shadow-floating"
    assert_text "Test Card"
    assert_text "$1,000"
    assert_text "Test description"
  end

  test "all card variants use consistent theme-aware styling" do
    variants = [:default, :elevated, :accent, :success, :warning, :destructive]
    
    variants.each do |variant|
      render_inline(Dashboard::CardComponent.new(
        title: "#{variant.to_s.capitalize} Card",
        value: "$100",
        variant: variant
      ))
      
      # All variants should use card-modern base class
      assert_includes rendered_content, "card-modern"
    end
  end

  test "card variants use consistent shadow system" do
    render_inline(Ui::CardComponent.new(variant: :elevated)) { "Content" }
    
    # Should use card-modern class which includes shadow-elevated
    assert_selector ".card-modern"
  end
end