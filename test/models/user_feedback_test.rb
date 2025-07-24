require "test_helper"

class UserFeedbackTest < ActiveSupport::TestCase
  test "should create feedback with valid attributes" do
    feedback = UserFeedback.new(
      feedback_type: 'bug_report',
      message: 'I found a bug',
      page: '/dashboard'
    )
    assert feedback.valid?
  end
  
  test "should require message" do
    feedback = UserFeedback.new(feedback_type: 'bug_report', page: '/dashboard')
    assert_not feedback.valid?
    assert_includes feedback.errors[:message], "can't be blank"
  end
  
  test "should mark as resolved with notes" do
    feedback = user_feedbacks(:bug_report)
    user = users(:admin)
    
    assert_not feedback.resolved
    
    feedback.mark_as_resolved(user, "Fixed in latest release")
    
    assert feedback.resolved
    assert_equal user.id, feedback.resolved_by
    assert_not_nil feedback.resolved_at
    assert_equal "Fixed in latest release", feedback.resolution_notes
  end
  
  test "should get resolver" do
    feedback = user_feedbacks(:feature_request)
    
    assert_equal users(:admin), feedback.resolver
  end
  
  test "should get resolution info" do
    feedback = user_feedbacks(:feature_request)
    
    assert_includes feedback.resolution_info, "Resolved"
    assert_includes feedback.resolution_info, users(:admin).email
  end
  
  test "should return nil resolution info for unresolved feedback" do
    feedback = user_feedbacks(:bug_report)
    
    assert_nil feedback.resolution_info
  end
end