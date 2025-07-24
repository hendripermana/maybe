require "test_helper"

class UserFeedbacksControllerTest < ActionDispatch::IntegrationTest
  test "should create feedback with valid params" do
    assert_difference("UserFeedback.count") do
      post user_feedbacks_path, params: {
        user_feedback: {
          feedback_type: "bug_report",
          message: "Test feedback",
          page: "/dashboard",
          theme: "light",
          browser: "Test Browser"
        }
      }
    end
    
    assert_redirected_to root_path
    assert_equal "Thank you for your feedback!", flash[:notice]
  end
  
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
  
  test "should create feedback with JSON format" do
    assert_difference("UserFeedback.count") do
      post user_feedbacks_path, params: {
        user_feedback: {
          feedback_type: "bug_report",
          message: "Test feedback",
          page: "/dashboard",
          theme: "light",
          browser: "Test Browser"
        }
      }, as: :json
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
  end
  
  test "should associate feedback with current user when signed in" do
    user = users(:one)
    sign_in(user)
    
    assert_difference("UserFeedback.count") do
      post user_feedbacks_path, params: {
        user_feedback: {
          feedback_type: "bug_report",
          message: "Test feedback",
          page: "/dashboard",
          theme: "light",
          browser: "Test Browser"
        }
      }
    end
    
    assert_equal user, UserFeedback.last.user
  end
  
  test "should sanitize sensitive information from feedback message" do
    assert_difference("UserFeedback.count") do
      post user_feedbacks_path, params: {
        user_feedback: {
          feedback_type: "bug_report",
          message: "My email is test@example.com and my phone is 555-123-4567. API key: abcdefghijklmnopqrstuvwxyz123456",
          page: "/dashboard",
          theme: "light",
          browser: "Test Browser"
        }
      }
    end
    
    feedback = UserFeedback.last
    assert_equal "My email is [EMAIL REDACTED] and my phone is [PHONE REDACTED]. API key: [TOKEN REDACTED]", feedback.message
  end
end