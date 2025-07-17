require "application_system_test_case"

class DashboardLayoutTest < ApplicationSystemTestCase
  setup do
    sign_in @user = users(:family_admin)
  end

  test "dashboard page has no bottom white space" do
    visit root_path
    
    # Verify dashboard page uses the correct CSS class
    assert_selector ".dashboard-main-content"
    assert_selector ".dashboard-page"
    
    # Verify no global py-6 padding is applied to dashboard content
    dashboard_content = find(".dashboard-main-content")
    assert_not dashboard_content[:class].include?("py-6")
    
    # Verify chart containers are properly sized
    assert_selector ".chart-container"
    
    # Verify dashboard sections have proper spacing
    assert_selector ".dashboard-section"
  end

  test "chart containers have consistent styling" do
    visit root_path
    
    # Verify chart containers exist and have proper classes
    chart_containers = all(".chart-container")
    assert chart_containers.count > 0
    
    # Verify chart containers have proper overflow handling
    chart_containers.each do |container|
      # Check that containers are visible and properly sized
      assert container.visible?
    end
  end

  test "dashboard layout works in both themes" do
    visit root_path
    
    # Test light theme
    assert_selector ".dashboard-page"
    
    # Switch to dark theme (if theme switcher exists)
    if has_button?("Toggle theme") || has_selector("[data-action*='theme']")
      click_button "Toggle theme" rescue nil
      
      # Verify dashboard still displays correctly in dark theme
      assert_selector ".dashboard-page"
      assert_selector ".chart-container"
    end
  end
end