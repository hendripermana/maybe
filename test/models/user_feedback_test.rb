require "test_helper"

class UserFeedbackTest < ActiveSupport::TestCase
  # Basic validation tests
  test "should create feedback with valid attributes" do
    feedback = UserFeedback.new(
      feedback_type: "bug_report",
      message: "I found a bug",
      page: "/dashboard"
    )
    assert feedback.valid?
  end

  test "should require feedback_type" do
    feedback = UserFeedback.new(message: "Test message", page: "/dashboard")
    assert_not feedback.valid?
    assert_includes feedback.errors[:feedback_type], "can't be blank"
  end

  test "should require message" do
    feedback = UserFeedback.new(feedback_type: "bug_report", page: "/dashboard")
    assert_not feedback.valid?
    assert_includes feedback.errors[:message], "can't be blank"
  end

  test "should require page" do
    feedback = UserFeedback.new(feedback_type: "bug_report", message: "Test message")
    assert_not feedback.valid?
    assert_includes feedback.errors[:page], "can't be blank"
  end

  test "should allow optional user association" do
    feedback = UserFeedback.new(
      feedback_type: "bug_report",
      message: "Test message",
      page: "/dashboard"
    )
    assert feedback.valid?
    assert_nil feedback.user
  end

  test "should associate with user when provided" do
    user = users(:regular_user)
    feedback = UserFeedback.new(
      feedback_type: "bug_report",
      message: "Test message",
      page: "/dashboard",
      user: user
    )
    assert feedback.valid?
    assert_equal user, feedback.user
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
        message: "Test message",
        page: "/dashboard"
      )
      assert feedback.valid?, "#{type} should be a valid feedback type"
    end
  end

  # Scope tests
  test "should find recent feedback" do
    recent_feedback = UserFeedback.recent
    # Should be ordered by created_at desc
    assert_equal UserFeedback.order(created_at: :desc).first, recent_feedback.first
  end

  test "should find unresolved feedback" do
    unresolved = UserFeedback.unresolved
    assert_includes unresolved, user_feedbacks(:bug_report)
    assert_includes unresolved, user_feedbacks(:ui_feedback)
    assert_not_includes unresolved, user_feedbacks(:feature_request)
  end

  test "should find ui related feedback" do
    ui_related = UserFeedback.ui_related
    assert_includes ui_related, user_feedbacks(:ui_feedback)
    assert_not_includes ui_related, user_feedbacks(:bug_report)
    assert_not_includes ui_related, user_feedbacks(:feature_request)
  end

  # Instance method tests
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

  test "should mark as resolved without notes" do
    feedback = user_feedbacks(:bug_report)
    user = users(:admin)

    feedback.mark_as_resolved(user)

    assert feedback.resolved
    assert_equal user.id, feedback.resolved_by
    assert_not_nil feedback.resolved_at
    assert_nil feedback.resolution_notes
  end

  test "should mark as resolved without user" do
    feedback = user_feedbacks(:bug_report)

    feedback.mark_as_resolved

    assert feedback.resolved
    assert_nil feedback.resolved_by
    assert_not_nil feedback.resolved_at
  end

  test "should get resolver" do
    feedback = user_feedbacks(:feature_request)
    assert_equal users(:admin), feedback.resolver
  end

  test "should return nil resolver when no resolved_by" do
    feedback = user_feedbacks(:bug_report)
    assert_nil feedback.resolver
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

  test "should generate summary" do
    feedback = user_feedbacks(:bug_report)
    expected_summary = "Bug report: I found a bug in the dashboard"
    assert_equal expected_summary, feedback.summary
  end

  test "should truncate long messages in summary" do
    feedback = UserFeedback.new(
      feedback_type: "bug_report",
      message: "This is a very long message that should be truncated when displayed in the summary because it exceeds the character limit",
      page: "/dashboard"
    )

    summary = feedback.summary
    assert summary.length <= 60 # "Bug report: " + 50 chars + "..."
    assert_includes summary, "Bug report:"
    assert_includes summary, "..."
  end

  # Data privacy tests
  test "should detect PII in message" do
    feedback = UserFeedback.new(
      feedback_type: "bug_report",
      message: "Contact me at user@example.com for more details",
      page: "/dashboard"
    )
    assert feedback.contains_pii?
  end

  test "should detect phone numbers in message" do
    feedback = UserFeedback.new(
      feedback_type: "bug_report",
      message: "Call me at (555) 123-4567",
      page: "/dashboard"
    )
    assert feedback.contains_pii?
  end

  test "should detect credit card numbers in message" do
    feedback = UserFeedback.new(
      feedback_type: "bug_report",
      message: "My card 1234 5678 9012 3456 is not working",
      page: "/dashboard"
    )
    assert feedback.contains_pii?
  end

  test "should detect SSN in message" do
    feedback = UserFeedback.new(
      feedback_type: "bug_report",
      message: "My SSN is 123-45-6789",
      page: "/dashboard"
    )
    assert feedback.contains_pii?
  end

  test "should not detect PII in clean message" do
    feedback = UserFeedback.new(
      feedback_type: "bug_report",
      message: "The button is not working properly",
      page: "/dashboard"
    )
    assert_not feedback.contains_pii?
  end

  test "should not detect PII in anonymized feedback" do
    feedback = UserFeedback.new(
      feedback_type: "bug_report",
      message: "Contact me at user@example.com",
      page: "/dashboard",
      data_anonymized: true
    )
    assert_not feedback.contains_pii?
  end

  test "should anonymize feedback" do
    feedback = user_feedbacks(:bug_report)
    assert_not feedback.data_anonymized?

    # Mock the DataPrivacyService
    DataPrivacyService.expects(:anonymize_user_feedback).with(feedback)

    feedback.anonymize!

    assert feedback.data_anonymized?
    assert_not_nil feedback.anonymized_at
  end

  test "should not anonymize already anonymized feedback" do
    feedback = UserFeedback.create!(
      feedback_type: "bug_report",
      message: "Test message",
      page: "/dashboard",
      data_anonymized: true,
      anonymized_at: 1.hour.ago
    )

    original_anonymized_at = feedback.anonymized_at

    # Should not call the service
    DataPrivacyService.expects(:anonymize_user_feedback).never

    feedback.anonymize!

    assert_equal original_anonymized_at, feedback.anonymized_at
  end

  # GDPR compliance tests
  test "should find old resolved records for purging" do
    old_resolved = UserFeedback.create!(
      feedback_type: "bug_report",
      message: "Old resolved feedback",
      page: "/dashboard",
      resolved: true,
      resolved_at: 400.days.ago
    )

    old_records = UserFeedback.old_resolved_records(365)
    assert_includes old_records, old_resolved
    assert_not_includes old_records, user_feedbacks(:feature_request)
  end

  test "should find old unresolved records for purging" do
    old_unresolved = UserFeedback.create!(
      feedback_type: "bug_report",
      message: "Old unresolved feedback",
      page: "/dashboard",
      resolved: false,
      created_at: 800.days.ago
    )

    old_records = UserFeedback.old_unresolved_records(730)
    assert_includes old_records, old_unresolved
    assert_not_includes old_records, user_feedbacks(:bug_report)
  end

  test "should find records needing anonymization" do
    needs_anon = UserFeedback.needs_anonymization
    assert_includes needs_anon, user_feedbacks(:bug_report)

    # Create an anonymized record to test exclusion
    anonymized_feedback = UserFeedback.create!(
      feedback_type: "bug_report",
      message: "Test",
      page: "/dashboard",
      user: users(:regular_user),
      data_anonymized: true
    )

    needs_anon = UserFeedback.needs_anonymization
    assert_not_includes needs_anon, anonymized_feedback
  end

  test "should find anonymized records" do
    anonymized_feedback = UserFeedback.create!(
      feedback_type: "bug_report",
      message: "Test",
      page: "/dashboard",
      data_anonymized: true
    )

    anonymized = UserFeedback.anonymized
    assert_includes anonymized, anonymized_feedback
    assert_not_includes anonymized, user_feedbacks(:bug_report)
  end

  test "should purge old resolved records" do
    old_resolved = UserFeedback.create!(
      feedback_type: "bug_report",
      message: "Old resolved feedback",
      page: "/dashboard",
      resolved: true,
      resolved_at: 400.days.ago
    )

    old_count = UserFeedback.old_resolved_records(365).count
    assert old_count > 0

    UserFeedback.purge_old_resolved_records(365)

    assert_equal 0, UserFeedback.old_resolved_records(365).count
  end

  test "should purge old unresolved records" do
    old_unresolved = UserFeedback.create!(
      feedback_type: "bug_report",
      message: "Old unresolved feedback",
      page: "/dashboard",
      resolved: false,
      created_at: 800.days.ago
    )

    old_count = UserFeedback.old_unresolved_records(730).count
    assert old_count > 0

    UserFeedback.purge_old_unresolved_records(730)

    assert_equal 0, UserFeedback.old_unresolved_records(730).count
  end

  test "should anonymize user data" do
    user = users(:regular_user)
    user_feedback = UserFeedback.where(user: user)

    # Mock the anonymize! method for each feedback
    user_feedback.each do |feedback|
      feedback.expects(:anonymize!)
    end

    UserFeedback.anonymize_user_data(user)
  end

  test "should export user data" do
    user = users(:regular_user)
    exported_data = UserFeedback.export_user_data(user)

    assert_not_empty exported_data

    exported_feedback = exported_data.first
    assert_includes exported_feedback.keys, :id
    assert_includes exported_feedback.keys, :feedback_type
    assert_includes exported_feedback.keys, :message
    assert_includes exported_feedback.keys, :page
    assert_includes exported_feedback.keys, :created_at
  end
end
