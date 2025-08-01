# frozen_string_literal: true

require "test_helper"

class TabsComponentTest < ComprehensiveComponentTestCase
  include MasterComponentTestingSuite

  setup do
    @tabs = [
      { id: "tab1", label: "First Tab", active: true },
      { id: "tab2", label: "Second Tab" },
      { id: "tab3", label: "Third Tab" }
    ]
    @component = TabsComponent.new(tabs: @tabs)
  end

  test "renders tabs with default options" do
    render_inline(@component)

    assert_selector ".tabs-component"
    assert_selector ".tab-item", count: 3
    assert_selector ".tab-item.active", count: 1
  end

  test "renders tabs with correct labels" do
    render_inline(@component)

    assert_selector ".tab-item", text: "First Tab"
    assert_selector ".tab-item", text: "Second Tab"
    assert_selector ".tab-item", text: "Third Tab"
  end

  test "renders tabs with active tab" do
    render_inline(@component)

    assert_selector ".tab-item.active", text: "First Tab"
  end

  test "renders tabs with custom class" do
    render_inline(TabsComponent.new(tabs: @tabs, class: "custom-tabs"))

    assert_selector ".tabs-component.custom-tabs"
  end

  test "renders tabs with variant options" do
    # Default variant
    render_inline(TabsComponent.new(tabs: @tabs, variant: :default))
    assert_selector ".tabs-component.tabs-default"

    # Underline variant
    render_inline(TabsComponent.new(tabs: @tabs, variant: :underline))
    assert_selector ".tabs-component.tabs-underline"

    # Pills variant
    render_inline(TabsComponent.new(tabs: @tabs, variant: :pills))
    assert_selector ".tabs-component.tabs-pills"
  end

  test "renders tabs with proper theme awareness" do
    test_theme_switching(@component)

    # Check for theme-aware classes
    assert_component_theme_aware(@component)

    # Check for no hardcoded colors
    render_inline(@component)
    assert_no_hardcoded_theme_classes
  end

  test "tabs meet accessibility requirements" do
    render_inline(@component)

    # Check for proper ARIA attributes
    assert_selector "[role='tablist']"
    assert_selector ".tab-item[role='tab']", count: 3
    assert_selector ".tab-item[aria-selected='true']", count: 1

    # Check for proper keyboard navigation attributes
    assert_selector ".tab-item[tabindex]", count: 3
  end

  test "tabs handle interactions correctly" do
    render_inline(TabsComponent.new(
      tabs: @tabs,
      data: { controller: "tabs", action: "click->tabs#select" }
    ))

    # Check for click handler
    assert_selector "[data-controller='tabs']"
    assert_selector ".tab-item[data-action]", count: 3
  end

  # Comprehensive test using our testing suite
  test "tabs pass comprehensive component testing" do
    test_component_comprehensively(
      @component,
      interactions: [ :click, :keyboard ]
    )
  end

  # Test all variants at once
  test "all tabs variants are theme-aware" do
    variants = [ :default, :underline, :pills ]
    variants.each do |variant|
      render_inline(TabsComponent.new(tabs: @tabs, variant: variant))
      assert_selector ".tabs-component.tabs-#{variant}"
    end
  end
end
