require "test_helper"

class FeedbackFormComponentTest < ViewComponent::TestCase
  # Basic rendering tests
  test "renders feedback form with default position" do
    render_inline(FeedbackFormComponent.new(current_page: "/dashboard"))

    assert_selector ".feedback-form"
    assert_selector ".feedback-button"
    assert_selector ".feedback-panel"
    assert_selector "form"
    assert_selector "select[name='user_feedback[feedback_type]']"
    assert_selector "textarea[name='user_feedback[message]']"
    assert_selector "input[type='hidden'][name='user_feedback[page]'][value='/dashboard']", visible: false
  end

  test "renders with custom position" do
    render_inline(FeedbackFormComponent.new(position: :top_left, current_page: "/dashboard"))

    assert_selector ".feedback-form"
    # Position classes are applied via private method, so we test the component renders
    assert_selector ".feedback-button"
  end

  test "renders feedback button with text" do
    render_inline(FeedbackFormComponent.new(current_page: "/dashboard"))

    assert_selector ".feedback-button", text: "Feedback"
  end

  test "renders form with proper structure" do
    render_inline(FeedbackFormComponent.new(current_page: "/dashboard"))

    assert_selector "form[action='/user_feedbacks']"
    assert_selector "h3.feedback-title", text: "Share Your Feedback"
    assert_selector ".form-group", count: 2
    assert_selector ".form-actions"
    assert_selector "button[type='button']", text: "Cancel"
    assert_selector "input[type='submit'][value='Submit Feedback']"
  end

  # Form field tests
  test "renders feedback type select with all options" do
    render_inline(FeedbackFormComponent.new(current_page: "/dashboard"))

    assert_selector "select[name='user_feedback[feedback_type]'][required]"
    assert_selector "option", text: "Select a type"

    UserFeedback.feedback_types.keys.each do |type|
      assert_selector "option[value='#{type}']", text: type.humanize
    end
  end

  test "renders message textarea with proper attributes" do
    render_inline(FeedbackFormComponent.new(current_page: "/dashboard"))

    assert_selector "textarea[name='user_feedback[message]'][required][rows='4']"
    assert_selector "textarea[placeholder*='Please describe your feedback']"
  end

  test "renders hidden fields with current context" do
    render_inline(FeedbackFormComponent.new(current_page: "/dashboard"))

    assert_selector "input[type='hidden'][name='user_feedback[page]'][value='/dashboard']", visible: false
  end

  # Context data tests
  test "includes current theme in hidden field" do
    component = FeedbackFormComponent.new(current_page: "/dashboard")
    component.stubs(:current_theme).returns("dark")

    render_inline(component)

    assert_selector "input[type='hidden'][name='user_feedback[theme]'][value='dark']", visible: false
  end

  test "includes browser info in hidden field" do
    component = FeedbackFormComponent.new(current_page: "/dashboard")
    component.stubs(:browser_info).returns("Mozilla/5.0 (Test Browser)")

    render_inline(component)

    assert_selector "input[type='hidden'][name='user_feedback[browser]'][value='Mozilla/5.0 (Test Browser)']", visible: false
  end

  test "uses provided current_page parameter" do
    render_inline(FeedbackFormComponent.new(current_page: "/custom/page"))

    assert_selector "input[type='hidden'][name='user_feedback[page]'][value='/custom/page']", visible: false
  end

  test "falls back to request url when no current_page provided" do
    component = FeedbackFormComponent.new
    # Mock the request object
    mock_request = mock("request")
    mock_request.stubs(:url).returns("http://localhost:3000/fallback")
    mock_request.stubs(:user_agent).returns("Test Browser")
    component.stubs(:request).returns(mock_request)

    render_inline(component)

    assert_selector "input[type='hidden'][name='user_feedback[page]'][value='http://localhost:3000/fallback']", visible: false
  end

  # Theme helper tests
  test "handles missing current_theme helper gracefully" do
    component = FeedbackFormComponent.new(current_page: "/dashboard")
    # Mock helpers that don't respond to current_theme
    mock_helpers = mock("helpers")
    mock_helpers.stubs(:respond_to?).with(:current_theme).returns(false)
    component.stubs(:helpers).returns(mock_helpers)

    assert_equal "default", component.current_theme
  end

  test "uses current_theme helper when available" do
    component = FeedbackFormComponent.new(current_page: "/dashboard")
    mock_helpers = mock("helpers")
    mock_helpers.stubs(:respond_to?).with(:current_theme).returns(true)
    mock_helpers.stubs(:current_theme).returns("custom_theme")
    component.stubs(:helpers).returns(mock_helpers)

    assert_equal "custom_theme", component.current_theme
  end

  # User context tests
  test "works without current_user" do
    render_inline(FeedbackFormComponent.new(current_page: "/dashboard"))

    # Should render successfully without errors
    assert_selector ".feedback-form"
  end

  test "works with current_user provided" do
    user = users(:regular_user)
    render_inline(FeedbackFormComponent.new(current_page: "/dashboard", current_user: user))

    # Should render successfully with user context
    assert_selector ".feedback-form"
  end

  # Position class tests
  test "applies correct position classes" do
    positions = {
      bottom_right: "bottom-4 right-4",
      bottom_left: "bottom-4 left-4",
      top_right: "top-4 right-4",
      top_left: "top-4 left-4"
    }

    positions.each do |position, expected_classes|
      component = FeedbackFormComponent.new(position: position, current_page: "/dashboard")

      # Test that position_classes method returns expected classes
      assert_equal expected_classes, component.send(:position_classes)
    end
  end

  test "defaults to bottom_right position" do
    component = FeedbackFormComponent.new(current_page: "/dashboard")
    assert_equal "bottom-4 right-4", component.send(:position_classes)
  end

  test "handles invalid position gracefully" do
    component = FeedbackFormComponent.new(position: :invalid, current_page: "/dashboard")
    assert_equal "bottom-4 right-4", component.send(:position_classes)
  end

  # Data controller tests
  test "includes stimulus data controller" do
    render_inline(FeedbackFormComponent.new(current_page: "/dashboard"))

    assert_selector "[data-controller='feedback-form']"
  end

  test "includes stimulus data targets" do
    render_inline(FeedbackFormComponent.new(current_page: "/dashboard"))

    assert_selector "[data-feedback-form-target='panel']"
  end

  test "includes stimulus data actions" do
    render_inline(FeedbackFormComponent.new(current_page: "/dashboard"))

    assert_selector "[data-action='click->feedback-form#toggleForm']"
    assert_selector "[data-action='feedback-form#closeForm']"
  end

  # Accessibility tests
  test "includes proper form labels" do
    render_inline(FeedbackFormComponent.new(current_page: "/dashboard"))

    assert_selector "label[for='feedback-type']", text: "Type of Feedback"
    assert_selector "label[for='feedback-message']", text: "Your Feedback"
  end

  test "includes required attributes for accessibility" do
    render_inline(FeedbackFormComponent.new(current_page: "/dashboard"))

    assert_selector "select[required]"
    assert_selector "textarea[required]"
  end

  test "includes helpful placeholder text" do
    render_inline(FeedbackFormComponent.new(current_page: "/dashboard"))

    assert_selector "textarea[placeholder*='Please describe your feedback']"
  end

  # Form submission tests
  test "form submits to correct endpoint" do
    render_inline(FeedbackFormComponent.new(current_page: "/dashboard"))

    assert_selector "form[action='/user_feedbacks'][method='post']"
  end

  test "includes CSRF token field" do
    render_inline(FeedbackFormComponent.new(current_page: "/dashboard"))

    # Rails form helpers automatically include CSRF token
    assert_selector "input[name='authenticity_token']", visible: false
  end

  # Error handling tests
  test "handles missing request object gracefully" do
    component = FeedbackFormComponent.new(current_page: "/dashboard")
    component.stubs(:request).returns(nil)

    # Should not raise an error when browser_info is called
    assert_nothing_raised do
      component.browser_info
    end
  end

  test "handles request without user_agent gracefully" do
    component = FeedbackFormComponent.new(current_page: "/dashboard")
    mock_request = mock("request")
    mock_request.stubs(:user_agent).returns(nil)
    component.stubs(:request).returns(mock_request)

    assert_nil component.browser_info
  end
end
