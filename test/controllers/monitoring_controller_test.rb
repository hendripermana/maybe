require "test_helper"

class MonitoringControllerTest < ActionDispatch::IntegrationTest
  setup do
    @admin = users(:admin)
    @user_feedback = user_feedbacks(:bug_report)
    sign_in @admin
  end

  test "should get index" do
    get monitoring_url
    assert_response :success
  end

  test "should get events" do
    get monitoring_events_url
    assert_response :success
  end

  test "should get feedback" do
    get monitoring_feedback_url
    assert_response :success
  end

  test "should resolve feedback" do
    assert_not @user_feedback.resolved

    post resolve_feedback_url(@user_feedback), params: { resolution_notes: "Fixed in latest release" }

    assert_redirected_to monitoring_feedback_url
    @user_feedback.reload
    assert @user_feedback.resolved
    assert_equal "Fixed in latest release", @user_feedback.resolution_notes
    assert_equal @admin.id, @user_feedback.resolved_by
    assert_not_nil @user_feedback.resolved_at
  end

  test "should unresolve feedback" do
    @user_feedback.update(resolved: true, resolved_at: Time.current, resolved_by: @admin.id, resolution_notes: "Test note")

    post unresolve_feedback_url(@user_feedback)

    assert_redirected_to monitoring_feedback_url
    @user_feedback.reload
    assert_not @user_feedback.resolved
    assert_nil @user_feedback.resolved_by
    assert_nil @user_feedback.resolved_at
    assert_nil @user_feedback.resolution_notes
  end

  test "should export feedback as CSV" do
    get export_feedback_url(format: :csv)

    assert_response :success
    assert_equal "text/csv", response.content_type
    assert_includes response.headers["Content-Disposition"], "attachment"

    # Check CSV content
    csv_content = response.body
    assert_includes csv_content, "ID,Type,Message,Page,User,Browser,Theme,Status,Created At,Resolved At,Resolved By,Resolution Notes"
    assert_includes csv_content, @user_feedback.id.to_s
  end

  test "should filter exported feedback" do
    get export_feedback_url(format: :csv, feedback_type: "bug_report")

    assert_response :success
    csv_lines = response.body.split("\n")

    # Header + at least one data row
    assert csv_lines.length >= 2

    # All data rows should be bug reports
    csv_lines[1..-1].each do |line|
      columns = CSV.parse_line(line)
      assert_equal "Bug Report", columns[1] # Type column
    end
  end
end
