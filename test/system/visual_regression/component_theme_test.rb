# frozen_string_literal: true

require "application_system_test_case"

class ComponentThemeTest < ApplicationSystemTestCase
  include VisualRegressionHelper

  setup do
    @visual_test_dir = Rails.root.join("test", "visual_regression", "screenshots")
    FileUtils.mkdir_p(@visual_test_dir)
  end

  test "button component in both themes" do
    visit "/lookbook/preview/ui/button_component_preview/theme_examples"

    # Test light theme
    assert_selector "[data-theme='light']"
    take_component_screenshot("button", theme: "light")

    # Toggle theme
    find("[data-testid='theme-toggle']").click

    # Test dark theme
    assert_selector "[data-theme='dark']"
    take_component_screenshot("button", theme: "dark")

    # Verify no hardcoded colors are visible
    assert_no_selector ".bg-white", visible: true
    assert_no_selector ".text-black", visible: true
  end

  test "card component in both themes" do
    visit "/lookbook/preview/ui/card_component_preview/theme_examples"

    # Test light theme
    assert_selector "[data-theme='light']"
    take_component_screenshot("card", theme: "light")

    # Toggle theme
    find("[data-testid='theme-toggle']").click

    # Test dark theme
    assert_selector "[data-theme='dark']"
    take_component_screenshot("card", theme: "dark")

    # Verify no hardcoded colors are visible
    assert_no_selector ".bg-white", visible: true
    assert_no_selector ".text-black", visible: true
  end

  test "input component in both themes" do
    visit "/lookbook/preview/ui/input_component_preview/theme_examples"

    # Test light theme
    assert_selector "[data-theme='light']"
    take_component_screenshot("input", theme: "light")

    # Toggle theme
    find("[data-testid='theme-toggle']").click

    # Test dark theme
    assert_selector "[data-theme='dark']"
    take_component_screenshot("input", theme: "dark")

    # Verify no hardcoded colors are visible
    assert_no_selector ".bg-white", visible: true
    assert_no_selector ".text-black", visible: true
  end

  test "badge component in both themes" do
    visit "/lookbook/preview/ui/badge_component_preview/theme_examples"

    # Test light theme
    assert_selector "[data-theme='light']"
    take_component_screenshot("badge", theme: "light")

    # Toggle theme
    find("[data-testid='theme-toggle']").click

    # Test dark theme
    assert_selector "[data-theme='dark']"
    take_component_screenshot("badge", theme: "dark")

    # Verify no hardcoded colors are visible
    assert_no_selector ".bg-white", visible: true
    assert_no_selector ".text-black", visible: true
  end

  test "skeleton component in both themes" do
    visit "/lookbook/preview/ui/skeleton_component_preview/theme_examples"

    # Test light theme
    assert_selector "[data-theme='light']"
    take_component_screenshot("skeleton", theme: "light")

    # Toggle theme
    find("[data-testid='theme-toggle']").click

    # Test dark theme
    assert_selector "[data-theme='dark']"
    take_component_screenshot("skeleton", theme: "dark")

    # Verify no hardcoded colors are visible
    assert_no_selector ".bg-white", visible: true
    assert_no_selector ".text-black", visible: true
  end
end
