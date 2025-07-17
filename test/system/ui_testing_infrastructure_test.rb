# frozen_string_literal: true

require "application_system_test_case"

class UiTestingInfrastructureTest < ApplicationSystemTestCase
  def setup
    @user = users(:family_admin)
    sign_in(@user)
  end
  
  test "theme testing infrastructure works" do
    visit root_path
    
    # Test theme detection
    initial_theme = current_theme
    assert_includes ['light', 'dark'], initial_theme
    
    # Test theme switching (if theme toggle exists)
    if page.has_selector?('[data-testid="theme-toggle"]', wait: 1)
      original_theme = current_theme
      toggle_theme
      new_theme = current_theme
      assert_not_equal original_theme, new_theme
    else
      # Manually test theme switching
      set_theme('dark')
      assert_theme_applied('dark')
      
      set_theme('light')
      assert_theme_applied('light')
    end
  end
  
  test "accessibility testing infrastructure works" do
    visit root_path
    
    # Test basic accessibility checks
    assert_proper_heading_hierarchy
    
    # Test that interactive elements are keyboard navigable
    if page.has_selector?('button')
      first_button = page.first('button')
      assert_keyboard_navigable(first_button)
    end
    
    # Test accessible names
    page.all('button, a').first(3).each do |element|
      assert_accessible_name(element)
    end
  end
  
  test "visual regression infrastructure works" do
    visit root_path
    
    # Test screenshot functionality
    screenshot_path = take_component_screenshot('homepage', theme: 'light')
    assert File.exist?(screenshot_path), "Screenshot should be created"
    
    # Test viewport changes
    with_viewport(375, 667) do
      mobile_screenshot = take_component_screenshot('homepage_mobile', theme: 'light')
      assert File.exist?(mobile_screenshot), "Mobile screenshot should be created"
    end
  end
  
  test "reduced motion preferences work" do
    visit root_path
    
    with_reduced_motion do
      # Test that reduced motion class is applied
      body_classes = page.evaluate_script("document.body.className")
      assert_includes body_classes, 'reduce-motion'
    end
    
    # Test that class is removed after block
    body_classes = page.evaluate_script("document.body.className")
    assert_not_includes body_classes, 'reduce-motion'
  end
  
  test "css variable testing works" do
    visit root_path
    
    # Test CSS variable detection
    assert_css_variable_defined('--background')
    assert_css_variable_defined('--foreground')
    
    # Test that variables change between themes
    if page.has_selector?('[data-testid="theme-toggle"]', wait: 1)
      assert_theme_variables_different('--background')
      assert_theme_variables_different('--foreground')
    end
  end
end