require "test_helper"

class Dashboard::ThemeSwitchingTest < ViewComponent::TestCase
  test "dashboard card component uses theme-aware icon backgrounds" do
    # Test success variant
    render_inline(Dashboard::CardComponent.new(
      title: "Test Card",
      value: "$1,000",
      variant: :success,
      icon_name: "trending-up"
    ))

    assert_selector ".icon-bg-success"
    refute_selector ".bg-green-100"
    refute_selector ".text-green-600"

    # Test primary/accent variant
    render_inline(Dashboard::CardComponent.new(
      title: "Test Card",
      value: "$1,000", 
      variant: :accent,
      icon_name: "trending-up"
    ))

    assert_selector ".icon-bg-primary"
    refute_selector ".bg-blue-100"
    refute_selector ".text-blue-600"

    # Test destructive variant
    render_inline(Dashboard::CardComponent.new(
      title: "Test Card",
      value: "$1,000",
      variant: :destructive,
      icon_name: "trending-down"
    ))

    assert_selector ".icon-bg-destructive"
    refute_selector ".bg-red-100"
    refute_selector ".text-red-600"
  end

  test "dashboard card component uses theme-aware trend colors" do
    # Test positive trend
    render_inline(Dashboard::CardComponent.new(
      title: "Test Card",
      value: "$1,000",
      trend: { direction: :up, positive: true, value: "5%" }
    ))

    assert_selector ".text-success"
    refute_selector ".text-green-600"

    # Test negative trend
    render_inline(Dashboard::CardComponent.new(
      title: "Test Card", 
      value: "$1,000",
      trend: { direction: :down, positive: false, value: "5%" }
    ))

    assert_selector ".text-destructive"
    refute_selector ".text-red-600"

    # Test neutral trend
    render_inline(Dashboard::CardComponent.new(
      title: "Test Card",
      value: "$1,000",
      trend: { direction: :neutral, positive: nil, value: "0%" }
    ))

    assert_selector ".text-muted-foreground"
    refute_selector ".text-gray-500"
  end
end