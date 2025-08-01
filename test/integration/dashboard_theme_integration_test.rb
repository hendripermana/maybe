require "test_helper"

class DashboardThemeIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:family_admin)
    sign_in @user
  end

  test "dashboard renders without hardcoded colors" do
    get root_path

    assert_response :success

    # Verify that hardcoded color classes are not present in the response
    refute_includes response.body, "bg-blue-100 text-blue-600"
    refute_includes response.body, "bg-gray-100"
    refute_includes response.body, "text-gray-600"

    # Verify that theme-aware classes are present
    assert_includes response.body, "icon-bg-primary"
    assert_includes response.body, "text-success"
    assert_includes response.body, "text-destructive"
    assert_includes response.body, "text-muted-foreground"
  end

  test "dashboard components use CSS variables" do
    get root_path

    assert_response :success

    # Verify CSS variable usage in the response
    assert_includes response.body, "text-foreground"
    assert_includes response.body, "text-muted-foreground"
    assert_includes response.body, "bg-card"
    assert_includes response.body, "border-border"
  end
end
