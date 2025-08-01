require "test_helper"

class DashboardLayoutIntegrationTest < ActionDispatch::IntegrationTest
  setup do
    sign_in @user = users(:family_admin)
  end

  test "dashboard layout uses page-specific CSS classes" do
    # Test that the layout file correctly applies dashboard-specific classes
    layout_content = File.read(Rails.root.join("app/views/layouts/application.html.erb"))

    # Verify the layout uses dashboard-main-content class
    assert_includes layout_content, "dashboard-main-content"

    # Verify it doesn't use the old pb-0 conditional approach
    assert_not_includes layout_content, "'pb-0' if controller_name == 'pages'"
  end

  test "CSS uses page-specific approach instead of global overrides" do
    css_content = File.read(Rails.root.join("app/assets/tailwind/application.css"))

    # Verify page-specific dashboard classes exist
    assert_includes css_content, ".dashboard-main-content"
    assert_includes css_content, ".dashboard-page"

    # Verify reduced use of !important declarations (allowing for necessary third-party overrides)
    important_count = css_content.scan(/!important/).length
    assert important_count < 20, "Too many !important declarations (#{important_count}), should be under 20"

    # Verify no dashboard-specific !important declarations for padding
    assert_not_includes css_content, "padding-bottom: 0 !important"
  end

  test "chart container conflicts are resolved" do
    css_content = File.read(Rails.root.join("app/assets/tailwind/application.css"))

    # Count actual .chart-container { definitions (not comments or nested selectors)
    chart_container_definitions = css_content.scan(/^\.chart-container\s*\{/).length
    assert_equal 1, chart_container_definitions, "Should have exactly one .chart-container definition"

    # Verify the single definition has all necessary properties
    assert_includes css_content, "position: relative"
    assert_includes css_content, "overflow: visible"
    assert_includes css_content, "min-height: 300px"
  end

  test "dashboard section has proper styling" do
    css_content = File.read(Rails.root.join("app/assets/tailwind/application.css"))

    # Verify dashboard section has proper min-height
    assert_includes css_content, ".dashboard-section"
    assert_includes css_content, "min-height: 540px"
  end

  test "dashboard CSS properly scopes chart container styles" do
    dashboard_css = File.read(Rails.root.join("app/assets/stylesheets/components/dashboard.css"))

    # Verify chart container styles are scoped to dashboard page
    assert_includes dashboard_css, ".dashboard-page .chart-container"

    # Verify responsive styles are also scoped
    assert_includes dashboard_css, "@media (max-width: 768px)"
  end
end
