require "test_helper"

class UserFeedbackSimpleTest < ActiveSupport::TestCase
  # Basic validation tests
  test "should create feedback with valid attributes" do
    feedback = UserFeedback.new(
      feedback_type: 'bug_report',
      message: 'I found a bug',
      page: '/dashboard'
    )
    assert feedback.valid?
  end
  
  test "should require feedback_type" do
    feedback = UserFeedback.new(message: 'Test message', page: '/dashboard')
    assert_not feedback.valid?
    assert_includes feedback.errors[:feedback_type], "can't be blank"
  end
  
  test "should require message" do
    feedback = UserFeedback.new(feedback_type: 'bug_report', page: '/dashboard')
    assert_not feedback.valid?
    assert_includes feedback.errors[:message], "can't be blank"
  end
  
  test "should require page" do
    feedback = UserFeedback.new(feedback_type: 'bug_report', message: 'Test message')
    assert_not feedback.valid?
    assert_includes feedback.errors[:page], "can't be blank"
  end

  # Enum tests
  test "should have valid feedback types" do
    expected_types = %w[bug_report feature_request ui_feedback accessibility_issue performance_issue general_feedback]
    assert_equal expected_types, UserFeedback.feedback_types.keys
  end
  
  test "should accept valid feedback types" do
    UserFeedback.feedback_types.keys.each do |type|
      feedback = UserFeedback.new(
        feedback_type: type,
        message: 'Test message',
        page: '/dashboard'
      )
      assert feedback.valid?, "#{type} should be a valid feedback type"
    end
  end

  # Scope tests
  test "should find recent feedback" do
    old_feedback = UserFeedback.create!(
      feedback_type: 'bug_report',
      message: 'Old feedback',
      page: '/dashboard',
      created_at: 1.week.ago
    )
    new_feedback = UserFeedback.create!(
      feedback_type: 'bug_report',
      message: 'New feedback',
      page: '/dashboard'
    )
    
    recent_feedback = UserFeedback.recent
    assert_equal new_feedback, recent_feedback.first
  end
  
  test "should find unresolved feedback" do
    resolved_feedback = UserFeedback.create!(
      feedback_type: 'bug_report',
      message: 'Resolved feedback',
      page: '/dashboard',
      resolved: true
    )
    unresolved_feedback = UserFeedback.create!(
      feedback_type: 'bug_report',
      message: 'Unresolved feedback',
      page: '/dashboard',
      resolved: false
    )
    
    unresolved = UserFeedback.unresolved
    assert_includes unresolved, unresolved_feedback
    assert_not_includes unresolved, resolved_feedback
  end
  
  test "should find ui related feedback" do
    ui_feedback = UserFeedback.create!(
      feedback_type: 'ui_feedback',
      message: 'UI issue',
      page: '/dashboard'
    )
    accessibility_feedback = UserFeedback.create!(
      feedback_type: 'accessibility_issue',
      message: 'Accessibility issue',
      page: '/dashboard'
    )
    bug_feedback = UserFeedback.create!(
      feedback_type: 'bug_report',
      message: 'Bug report',
      page: '/dashboard'
    )
    
    ui_related = UserFeedback.ui_related
    assert_includes ui_related, ui_feedback
    assert_includes ui_related, accessibility_feedback
    assert_not_includes ui_related, bug_feedback
  end

  # Instance method tests
  test "should mark as resolved with notes" do
    feedback = UserFeedback.create!(
      feedback_type: 'bug_report',
      message: 'Test feedback',
      page: '/dashboard'
    )
    
    assert_not feedback.resolved
    
    feedback.mark_as_resolved(nil, "Fixed in latest release")
    
    assert feedback.resolved
    assert_not_nil feedback.resolved_at
    assert_equal "Fixed in latest release", feedback.resolution_notes
  end
  
  test "should mark as resolved without notes" do
    feedback = UserFeedback.create!(
      feedback_type: 'bug_report',
      message: 'Test feedback',
      page: '/dashboard'
    )
    
    feedback.mark_as_resolved
    
    assert feedback.resolved
    assert_not_nil feedback.resolved_at
    assert_nil feedback.resolution_notes
  end
  
  test "should generate summary" do
    feedback = UserFeedback.new(
      feedback_type: 'bug_report',
      message: 'I found a bug in the dashboard',
      page: '/dashboard'
    )
    expected_summary = "Bug report: I found a bug in the dashboard"
    assert_equal expected_summary, feedback.summary
  end
  
  test "should truncate long messages in summary" do
    feedback = UserFeedback.new(
      feedback_type: 'bug_report',
      message: 'This is a very long message that should be truncated when displayed in the summary because it exceeds the character limit',
      page: '/dashboard'
    )
    
    summary = feedback.summary
    assert summary.length <= 60 # "Bug report: " + 50 chars + "..."
    assert_includes summary, "Bug report:"
    assert_includes summary, "..."
  end

  # Data privacy tests
  test "should detect PII in message" do
    feedback = UserFeedback.new(
      feedback_type: 'bug_report',
      message: 'Contact me at user@example.com for more details',
      page: '/dashboard'
    )
    assert feedback.contains_pii?
  end
  
  test "should detect phone numbers in message" do
    feedback = UserFeedback.new(
      feedback_type: 'bug_report',
      message: 'Call me at (555) 123-4567',
      page: '/dashboard'
    )
    assert feedback.contains_pii?
  end
  
  test "should not detect PII in clean message" do
    feedback = UserFeedback.new(
      feedback_type: 'bug_report',
      message: 'The button is not working properly',
      page: '/dashboard'
    )
    assert_not feedback.contains_pii?
  end
end