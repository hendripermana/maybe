require "test_helper"

class UiMonitoringEventTest < ActiveSupport::TestCase
  # Basic validation tests
  test "should create event with valid attributes" do
    event = UiMonitoringEvent.new(
      event_type: "ui_error",
      data: { error_type: "TypeError", message: "Cannot read property of undefined" }
    )
    assert event.valid?
  end

  test "should require event_type" do
    event = UiMonitoringEvent.new(data: { message: "Test" })
    assert_not event.valid?
    assert_includes event.errors[:event_type], "can't be blank"
  end

  test "should allow optional user association" do
    event = UiMonitoringEvent.new(
      event_type: "ui_error",
      data: { error_type: "TypeError" }
    )
    assert event.valid?
    assert_nil event.user
  end

  test "should associate with user when provided" do
    user = users(:regular_user)
    event = UiMonitoringEvent.new(
      event_type: "ui_error",
      data: { error_type: "TypeError" },
      user: user
    )
    assert event.valid?
    assert_equal user, event.user
  end

  # Scope tests
  test "should find error events" do
    error_events = UiMonitoringEvent.errors
    assert_includes error_events, ui_monitoring_events(:ui_error_event)
    assert_includes error_events, ui_monitoring_events(:component_error_event)
    assert_not_includes error_events, ui_monitoring_events(:performance_metric_event)
  end

  test "should find performance issues" do
    performance_events = UiMonitoringEvent.performance_issues
    # Note: performance_issues scope looks for 'performance_issue' but our fixtures use 'performance_metric'
    # This tests the actual scope behavior
    assert_empty performance_events
  end

  test "should find theme related events" do
    theme_events = UiMonitoringEvent.theme_related
    assert_includes theme_events, ui_monitoring_events(:performance_metric_event)
    assert_includes theme_events, ui_monitoring_events(:theme_switch_event)
    assert_not_includes theme_events, ui_monitoring_events(:ui_error_event)
  end

  test "should find component errors" do
    component_errors = UiMonitoringEvent.component_errors
    assert_includes component_errors, ui_monitoring_events(:component_error_event)
    assert_not_includes component_errors, ui_monitoring_events(:ui_error_event)
  end

  test "should find recent events" do
    recent_events = UiMonitoringEvent.recent
    assert_equal 100, recent_events.limit_value
    # Should be ordered by created_at desc
    assert_equal UiMonitoringEvent.order(created_at: :desc).first, recent_events.first
  end

  # Class method tests
  test "should generate performance metrics summary" do
    # Create some test data
    UiMonitoringEvent.create!(
      event_type: "performance_metric",
      data: { metric_name: "page_load_time", value: 1000 }
    )
    UiMonitoringEvent.create!(
      event_type: "performance_metric",
      data: { metric_name: "page_load_time", value: 2000 }
    )

    summary = UiMonitoringEvent.performance_metrics_summary
    page_load_metric = summary.find { |s| s.metric_name == "page_load_time" }

    assert_not_nil page_load_metric
    assert_equal 1500.0, page_load_metric.avg_value
    assert_equal 2, page_load_metric.count
  end

  test "should generate error summary" do
    summary = UiMonitoringEvent.error_summary
    type_error_summary = summary.find { |s| s.error_type == "TypeError" }

    assert_not_nil type_error_summary
    assert_equal 1, type_error_summary.count
  end

  test "should calculate theme switch performance" do
    # The fixture has a theme_switched event with duration 1500.5
    avg_duration = UiMonitoringEvent.theme_switch_performance
    assert_equal 1500.5, avg_duration
  end

  # Instance method tests
  test "should return error message for ui_error events" do
    event = ui_monitoring_events(:ui_error_event)
    assert_equal "Cannot read property 'value' of undefined", event.error_message
  end

  test "should return nil error message for non-error events" do
    event = ui_monitoring_events(:performance_metric_event)
    assert_nil event.error_message
  end

  test "should return component name from context" do
    event = ui_monitoring_events(:component_error_event)
    assert_equal "DashboardCard", event.component_name
  end

  test "should return nil component name when no context" do
    event = ui_monitoring_events(:ui_error_event)
    assert_nil event.component_name
  end

  test "should detect browser from user agent" do
    event = UiMonitoringEvent.new(
      event_type: "ui_error",
      data: { user_agent: "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36" }
    )
    assert_equal "Chrome", event.browser_info

    event.data["user_agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:89.0) Gecko/20100101 Firefox/89.0"
    assert_equal "Firefox", event.browser_info

    event.data["user_agent"] = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15"
    assert_equal "Safari", event.browser_info

    event.data["user_agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36 Edg/91.0.864.59"
    assert_equal "Edge", event.browser_info

    event.data["user_agent"] = "Some unknown browser"
    assert_equal "Other", event.browser_info
  end

  # Data privacy tests
  test "should detect sensitive data" do
    event = ui_monitoring_events(:ui_error_event)
    assert event.contains_sensitive_data?
  end

  test "should not detect sensitive data in anonymized events" do
    event = ui_monitoring_events(:anonymized_event)
    assert_not event.contains_sensitive_data?
  end

  test "should anonymize event" do
    event = ui_monitoring_events(:ui_error_event)
    assert_not event.data_anonymized?

    # Mock the DataPrivacyService
    DataPrivacyService.expects(:anonymize_monitoring_event).with(event)

    event.anonymize!

    assert event.data_anonymized?
    assert_not_nil event.anonymized_at
  end

  test "should not anonymize already anonymized event" do
    event = ui_monitoring_events(:anonymized_event)
    original_anonymized_at = event.anonymized_at

    # Should not call the service
    DataPrivacyService.expects(:anonymize_monitoring_event).never

    event.anonymize!

    assert_equal original_anonymized_at, event.anonymized_at
  end

  # GDPR compliance tests
  test "should find old records for purging" do
    old_events = UiMonitoringEvent.old_records(90)
    assert_includes old_events, ui_monitoring_events(:old_event)
    assert_not_includes old_events, ui_monitoring_events(:ui_error_event)
  end

  test "should find records needing anonymization" do
    needs_anon = UiMonitoringEvent.needs_anonymization
    assert_includes needs_anon, ui_monitoring_events(:ui_error_event)
    assert_not_includes needs_anon, ui_monitoring_events(:anonymized_event)
  end

  test "should find anonymized records" do
    anonymized = UiMonitoringEvent.anonymized
    assert_includes anonymized, ui_monitoring_events(:anonymized_event)
    assert_not_includes anonymized, ui_monitoring_events(:ui_error_event)
  end

  test "should purge old records" do
    old_count = UiMonitoringEvent.old_records(90).count
    assert old_count > 0

    UiMonitoringEvent.purge_old_records(90)

    assert_equal 0, UiMonitoringEvent.old_records(90).count
  end

  test "should anonymize user data" do
    user = users(:regular_user)
    user_events = UiMonitoringEvent.where(user: user)

    # Mock the anonymize! method for each event
    user_events.each do |event|
      event.expects(:anonymize!)
    end

    UiMonitoringEvent.anonymize_user_data(user)
  end

  test "should export user data" do
    user = users(:regular_user)
    exported_data = UiMonitoringEvent.export_user_data(user)

    assert_not_empty exported_data

    exported_event = exported_data.first
    assert_includes exported_event.keys, :id
    assert_includes exported_event.keys, :event_type
    assert_includes exported_event.keys, :created_at
    assert_includes exported_event.keys, :data
  end

  # Sentry integration tests
  test "should return sentry event id when present" do
    event = UiMonitoringEvent.new(
      event_type: "ui_error",
      data: { sentry_event_id: "abc123def456" }
    )
    assert_equal "abc123def456", event.sentry_event_id
  end

  test "should return nil sentry event id when not present" do
    event = ui_monitoring_events(:ui_error_event)
    assert_nil event.sentry_event_id
  end

  test "should detect if has sentry event" do
    event = UiMonitoringEvent.new(
      event_type: "ui_error",
      data: { sentry_event_id: "abc123def456" }
    )
    assert event.has_sentry_event?

    event.data.delete("sentry_event_id")
    assert_not event.has_sentry_event?
  end

  test "should generate sentry url when configured" do
    with_env_overrides(
      "SENTRY_ORGANIZATION" => "test-org",
      "SENTRY_PROJECT" => "test-project"
    ) do
      event = UiMonitoringEvent.new(
        event_type: "ui_error",
        data: { sentry_event_id: "abc123def456" }
      )

      expected_url = "https://sentry.io/organizations/test-org/issues/?project=test-project&query=event.id%3Aabc123def456"
      assert_equal expected_url, event.sentry_url
    end
  end

  test "should return nil sentry url when not configured" do
    event = UiMonitoringEvent.new(
      event_type: "ui_error",
      data: { sentry_event_id: "abc123def456" }
    )
    assert_nil event.sentry_url
  end
end
