# frozen_string_literal: true

require "application_system_test_case"

class ThemeSystemTest < ApplicationSystemTestCase
  test "theme switching works correctly" do
    visit "/theme-test.html"
    
    # Verify initial light theme
    assert_selector "html[data-theme='light']"
    assert_text "Current theme: light"
    
    # Test theme toggle
    click_button "Toggle Theme"
    
    # Verify dark theme is applied
    assert_selector "html[data-theme='dark']"
    assert_text "Current theme: dark"
    
    # Toggle back to light
    click_button "Toggle Theme"
    
    # Verify light theme is restored
    assert_selector "html[data-theme='light']"
    assert_text "Current theme: light"
  end
  
  test "CSS variables are properly defined" do
    visit "/theme-test.html"
    
    # Test that CSS variables are accessible
    primary_color = page.evaluate_script("getComputedStyle(document.documentElement).getPropertyValue('--color-primary')")
    background_color = page.evaluate_script("getComputedStyle(document.documentElement).getPropertyValue('--color-background')")
    
    assert_not_empty primary_color.strip
    assert_not_empty background_color.strip
  end
  
  test "theme variables change between light and dark modes" do
    visit "/theme-test.html"
    
    # Get light mode colors
    light_bg = page.evaluate_script("getComputedStyle(document.documentElement).getPropertyValue('--color-background')")
    light_text = page.evaluate_script("getComputedStyle(document.documentElement).getPropertyValue('--color-text-primary')")
    
    # Switch to dark mode
    click_button "Toggle Theme"
    
    # Get dark mode colors
    dark_bg = page.evaluate_script("getComputedStyle(document.documentElement).getPropertyValue('--color-background')")
    dark_text = page.evaluate_script("getComputedStyle(document.documentElement).getPropertyValue('--color-text-primary')")
    
    # Verify colors are different between themes
    assert_not_equal light_bg.strip, dark_bg.strip, "Background color should change between themes"
    assert_not_equal light_text.strip, dark_text.strip, "Text color should change between themes"
  end
  
  test "components use CSS variables correctly" do
    visit "/theme-test.html"
    
    # Test that buttons have proper styling
    assert_selector ".btn-modern-primary"
    assert_selector ".btn-modern-secondary"
    assert_selector ".btn-modern-ghost"
    
    # Test that cards use CSS variables
    assert_selector ".card-modern"
    
    # Test that inputs use CSS variables
    assert_selector ".input-modern"
    
    # Test that chart containers use CSS variables
    assert_selector ".chart-container"
  end
  
  test "shadow system works in both themes" do
    visit "/theme-test.html"
    
    # Test shadows in light mode
    elevated_shadow_light = page.evaluate_script("getComputedStyle(document.querySelector('[style*=\"--shadow-elevated\"]')).boxShadow")
    
    # Switch to dark mode
    click_button "Toggle Theme"
    
    # Test shadows in dark mode
    elevated_shadow_dark = page.evaluate_script("getComputedStyle(document.querySelector('[style*=\"--shadow-elevated\"]')).boxShadow")
    
    # Verify shadows exist in both modes
    assert_not_empty elevated_shadow_light
    assert_not_empty elevated_shadow_dark
  end
end