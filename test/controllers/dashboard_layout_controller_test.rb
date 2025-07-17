require "test_helper"

class DashboardLayoutControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in @user = users(:family_admin)
  end

  test "dashboard page renders with correct layout class" do
    get root_path
    assert_response :success
    
    # Verify the dashboard page uses the correct CSS class
    assert_select ".dashboard-main-content"
    assert_select ".dashboard-page"
  end

  test "dashboard controller sets correct action and controller names" do
    get root_path
    assert_response :success
    
    # Verify we're on the pages controller dashboard action
    assert_equal "pages", @controller.controller_name
    assert_equal "dashboard", @controller.action_name
  end
end