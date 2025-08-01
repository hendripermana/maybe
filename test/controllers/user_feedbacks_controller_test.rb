require "test_helper"

class UserFeedbacksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @valid_params = {
      user_feedback: {
        feedback_type: "bug_report",
        message: "Test feedback message",
        page: "/dashboard",
        theme: "light",
        browser: "Mozilla/5.0 (Test Browser)"
      }
    }
    @user = users(:regular_user)
  end

  # Basic functionality tests
  test "should create feedback with valid params" do
    assert_difference("UserFeedback.count") do
      post user_feedbacks_path, params: @valid_params
    end

    assert_redirected_to root_path
    assert_equal "Thank you for your feedback!", flash[:notice]

    feedback = UserFeedback.last
    assert_equal "bug_report", feedback.feedback_type
    assert_equal "Test feedback message", feedback.message
    assert_equal "/dashboard", feedback.page
    assert_equal "light", feedback.theme
    assert_equal "Mozilla/5.0 (Test Browser)", feedback.browser
  end

  test "should create feedback for all valid feedback types" do
    UserFeedback.feedback_types.keys.each do |type|
      params = @valid_params.deep_dup
      params[:user_feedback][:feedback_type] = type

      assert_difference("UserFeedback.count") do
        post user_feedbacks_path, params: params
      end

      assert_equal type, UserFeedback.last.feedback_type
    end
  end

  # Validation tests
  test "should not create feedback with invalid params" do
    assert_no_difference("UserFeedback.count") do
      post user_feedbacks_path, params: {
        user_feedback: {
          feedback_type: "",
          message: "",
          page: "/dashboard"
        }
      }
    end

    assert_redirected_to root_path
    assert_match "There was a problem submitting your feedback", flash[:alert]
  end

  test "should require feedback_type" do
    params = @valid_params.deep_dup
    params[:user_feedback].delete(:feedback_type)

    assert_no_difference("UserFeedback.count") do
      post user_feedbacks_path, params: params
    end

    assert_match "Feedback type can't be blank", flash[:alert]
  end

  test "should require message" do
    params = @valid_params.deep_dup
    params[:user_feedback][:message] = ""

    assert_no_difference("UserFeedback.count") do
      post user_feedbacks_path, params: params
    end

    assert_match "Message can't be blank", flash[:alert]
  end

  test "should require page" do
    params = @valid_params.deep_dup
    params[:user_feedback].delete(:page)

    assert_no_difference("UserFeedback.count") do
      post user_feedbacks_path, params: params
    end

    assert_match "Page can't be blank", flash[:alert]
  end

  # JSON API tests
  test "should create feedback with JSON format" do
    assert_difference("UserFeedback.count") do
      post user_feedbacks_path, params: @valid_params, as: :json
    end

    assert_response :created
    assert_equal({ "status" => "success" }, JSON.parse(response.body))
  end

  test "should return errors with JSON format" do
    assert_no_difference("UserFeedback.count") do
      post user_feedbacks_path, params: {
        user_feedback: {
          feedback_type: "",
          message: "",
          page: "/dashboard"
        }
      }, as: :json
    end

    assert_response :unprocessable_entity
    response_json = JSON.parse(response.body)
    assert_equal "error", response_json["status"]
    assert_includes response_json["error"], "Feedback type can't be blank"
    assert_includes response_json["error"], "Message can't be blank"
  end

  # User association tests
  test "should create anonymous feedback when not signed in" do
    assert_difference("UserFeedback.count") do
      post user_feedbacks_path, params: @valid_params
    end

    feedback = UserFeedback.last
    assert_nil feedback.user
  end

  test "should associate feedback with current user when signed in" do
    sign_in(@user)

    assert_difference("UserFeedback.count") do
      post user_feedbacks_path, params: @valid_params
    end

    feedback = UserFeedback.last
    assert_equal @user, feedback.user
  end

  # Data sanitization tests
  test "should sanitize email addresses from feedback message" do
    params = @valid_params.deep_dup
    params[:user_feedback][:message] = "Contact me at user@example.com for details"

    assert_difference("UserFeedback.count") do
      post user_feedbacks_path, params: params
    end

    feedback = UserFeedback.last
    assert_equal "Contact me at [EMAIL REDACTED] for details", feedback.message
  end

  test "should sanitize phone numbers from feedback message" do
    params = @valid_params.deep_dup
    params[:user_feedback][:message] = "Call me at (555) 123-4567 or 555-987-6543"

    assert_difference("UserFeedback.count") do
      post user_feedbacks_path, params: params
    end

    feedback = UserFeedback.last
    assert_equal "Call me at [PHONE REDACTED] or [PHONE REDACTED]", feedback.message
  end

  test "should sanitize API keys and tokens from feedback message" do
    params = @valid_params.deep_dup
    params[:user_feedback][:message] = "API key: abcdefghijklmnopqrstuvwxyz123456 is not working"

    assert_difference("UserFeedback.count") do
      post user_feedbacks_path, params: params
    end

    feedback = UserFeedback.last
    assert_equal "API key: [TOKEN REDACTED] is not working", feedback.message
  end

  test "should sanitize multiple sensitive data types" do
    params = @valid_params.deep_dup
    params[:user_feedback][:message] = "Email: test@example.com, Phone: 555-123-4567, Token: abcdefghijklmnopqrstuvwxyz123456"

    assert_difference("UserFeedback.count") do
      post user_feedbacks_path, params: params
    end

    feedback = UserFeedback.last
    expected_message = "Email: [EMAIL REDACTED], Phone: [PHONE REDACTED], Token: [TOKEN REDACTED]"
    assert_equal expected_message, feedback.message
  end

  test "should not sanitize normal text" do
    params = @valid_params.deep_dup
    params[:user_feedback][:message] = "The button is not working properly on the dashboard"

    assert_difference("UserFeedback.count") do
      post user_feedbacks_path, params: params
    end

    feedback = UserFeedback.last
    assert_equal "The button is not working properly on the dashboard", feedback.message
  end

  # Parameter filtering tests
  test "should only permit allowed parameters" do
    params = {
      user_feedback: {
        feedback_type: "bug_report",
        message: "Test message",
        page: "/dashboard",
        theme: "light",
        browser: "Test Browser",
        # These should be filtered out
        admin_notes: "Should not be saved",
        resolved: true,
        resolved_by: @user.id
      }
    }

    assert_difference("UserFeedback.count") do
      post user_feedbacks_path, params: params
    end

    feedback = UserFeedback.last
    assert_equal "bug_report", feedback.feedback_type
    assert_equal "Test message", feedback.message
    assert_equal "/dashboard", feedback.page
    assert_equal "light", feedback.theme
    assert_equal "Test Browser", feedback.browser

    # These should not be set
    assert_not feedback.resolved
    assert_nil feedback.resolved_by
  end

  # Redirect behavior tests
  test "should redirect back to referrer when available" do
    referrer = "/transactions"

    post user_feedbacks_path,
         params: @valid_params,
         headers: { "HTTP_REFERER" => referrer }

    assert_redirected_to referrer
  end

  test "should fallback to root path when no referrer" do
    post user_feedbacks_path, params: @valid_params

    assert_redirected_to root_path
  end

  # Error handling tests
  test "should handle database errors gracefully" do
    # Mock a database error
    UserFeedback.any_instance.stubs(:save).returns(false)
    UserFeedback.any_instance.stubs(:errors).returns(
      ActiveModel::Errors.new(UserFeedback.new).tap do |errors|
        errors.add(:base, "Database connection failed")
      end
    )

    post user_feedbacks_path, params: @valid_params

    assert_redirected_to root_path
    assert_includes flash[:alert], "Database connection failed"
  end

  test "should handle database errors gracefully with JSON" do
    # Mock a database error
    UserFeedback.any_instance.stubs(:save).returns(false)
    UserFeedback.any_instance.stubs(:errors).returns(
      ActiveModel::Errors.new(UserFeedback.new).tap do |errors|
        errors.add(:base, "Database connection failed")
      end
    )

    post user_feedbacks_path, params: @valid_params, as: :json

    assert_response :unprocessable_entity
    response_json = JSON.parse(response.body)
    assert_equal "error", response_json["status"]
    assert_includes response_json["error"], "Database connection failed"
  end

  # Edge case tests
  test "should handle empty message after sanitization" do
    params = @valid_params.deep_dup
    params[:user_feedback][:message] = "test@example.com"  # Only contains email

    # This should still create the feedback with redacted content
    assert_difference("UserFeedback.count") do
      post user_feedbacks_path, params: params
    end

    feedback = UserFeedback.last
    assert_equal "[EMAIL REDACTED]", feedback.message
  end

  test "should handle very long messages" do
    params = @valid_params.deep_dup
    params[:user_feedback][:message] = "A" * 10000  # Very long message

    assert_difference("UserFeedback.count") do
      post user_feedbacks_path, params: params
    end

    feedback = UserFeedback.last
    assert_equal "A" * 10000, feedback.message
  end

  test "should handle special characters in message" do
    params = @valid_params.deep_dup
    params[:user_feedback][:message] = "Special chars: <script>alert('xss')</script> & 中文 & émojis 🎉"

    assert_difference("UserFeedback.count") do
      post user_feedbacks_path, params: params
    end

    feedback = UserFeedback.last
    assert_equal "Special chars: <script>alert('xss')</script> & 中文 & émojis 🎉", feedback.message
  end

  # Content type tests
  test "should accept form data" do
    post user_feedbacks_path, params: @valid_params

    assert_response :redirect
    assert_equal "Thank you for your feedback!", flash[:notice]
  end

  test "should accept JSON data" do
    post user_feedbacks_path,
         params: @valid_params.to_json,
         headers: { "Content-Type" => "application/json" }

    assert_response :created
  end

  # CSRF protection tests
  test "should require CSRF token for HTML requests" do
    # This test ensures CSRF protection is working for regular form submissions
    # The test framework automatically includes CSRF tokens, so we need to disable them
    ActionController::Base.allow_forgery_protection = true

    begin
      post user_feedbacks_path,
           params: @valid_params,
           headers: { "X-CSRF-Token" => "invalid_token" }

      # Should be rejected due to invalid CSRF token
      assert_response :unprocessable_entity
    ensure
      ActionController::Base.allow_forgery_protection = false
    end
  end
end
