# frozen_string_literal: true

require "test_helper"

class SearchInputComponentTest < ComprehensiveComponentTestCase
  include MasterComponentTestingSuite

  test "renders search input with default options" do
    render_inline(SearchInputComponent.new(name: "search"))

    assert_selector ".search-input-component"
    assert_selector "input[type='search'][name='search']"
    assert_selector ".search-icon svg"
  end

  test "renders search input with placeholder" do
    render_inline(SearchInputComponent.new(name: "search", placeholder: "Search items..."))

    assert_selector "input[placeholder='Search items...']"
  end

  test "renders search input with value" do
    render_inline(SearchInputComponent.new(name: "search", value: "test query"))

    assert_selector "input[value='test query']"
  end

  test "renders search input with clear button" do
    render_inline(SearchInputComponent.new(name: "search", value: "test", clearable: true))

    assert_selector ".search-input-component"
    assert_selector "input[value='test']"
    assert_selector "button.search-clear"
  end

  test "renders search input with custom class" do
    render_inline(SearchInputComponent.new(name: "search", class: "custom-search"))

    assert_selector ".search-input-component.custom-search"
  end

  test "renders search input with size options" do
    # Small size
    render_inline(SearchInputComponent.new(name: "search", size: :sm))
    assert_selector ".search-input-component.search-sm"

    # Medium size (default)
    render_inline(SearchInputComponent.new(name: "search", size: :md))
    assert_selector ".search-input-component.search-md"

    # Large size
    render_inline(SearchInputComponent.new(name: "search", size: :lg))
    assert_selector ".search-input-component.search-lg"
  end

  test "renders search input with proper theme awareness" do
    test_theme_switching(SearchInputComponent.new(name: "search"))

    # Check for theme-aware classes
    assert_component_theme_aware(SearchInputComponent.new(name: "search"))

    # Check for no hardcoded colors
    render_inline(SearchInputComponent.new(name: "search"))
    assert_no_hardcoded_theme_classes
  end

  test "search input meets accessibility requirements" do
    render_inline(SearchInputComponent.new(
      name: "search",
      label: "Search",
      aria: { label: "Search items" }
    ))

    # Check for proper ARIA attributes
    assert_selector "input[aria-label='Search items']"

    # Check for proper label association
    assert_selector "label[for]", text: "Search"
  end

  test "search input handles interactions correctly" do
    render_inline(SearchInputComponent.new(
      name: "search",
      data: { controller: "search", action: "input->search#filter" }
    ))

    # Check for input handler
    assert_selector "input[data-action*='input->search#filter']"
  end

  # Comprehensive test using our testing suite
  test "search input passes comprehensive component testing" do
    test_component_comprehensively(
      SearchInputComponent.new(name: "search", label: "Search", placeholder: "Search..."),
      interactions: [ :input, :focus ]
    )
  end

  # Test all sizes at once
  test "all search input sizes are theme-aware" do
    sizes = [ :sm, :md, :lg ]
    test_component_sizes(SearchInputComponent, :size, sizes, { name: "search" })
  end
end
