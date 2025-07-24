require 'test_helper'

class UiMonitoringEventSimpleTest < ActiveSupport::TestCase
  # Basic validation tests
  test "should create event with valid attributes" do
    event = UiMonitoringEvent.new(
      event_type: 'ui_error',
      data: { error_type: 'TypeError', message: 'Cannot read property of undefined' }
    )
    assert event.valid?
  end
  
  test "should require event_type" do
    event = UiMonitoringEvent.new(data: { message: 'Test' })
    assert_not event.valid?
    assert_includes event.errors[:event_type], "can't be blank"
  end
  
  test "should allow optional user association" do
    event = UiMonitoringEvent.new(
      event_type: 'ui_error',
      data: { error_type: 'TypeError' }
    )
    assert event.valid?
    assert_nil event.user
  end

  # Scope tests
  test "should find error events" do
    UiMonitoringEvent.create!(event_type: 'ui_error', data: { error_type: 'TypeError' })
    UiMonitoringEvent.create!(event_type: 'performance_metric', data: { metric_name: 'load_time' })
    
    error_events = UiMonitoringEvent.errors
    assert_equal 1, error_events.count
    assert_equal 'ui_error', error_events.first.event_type
  end
  
  test "should find theme related events" do
    UiMonitoringEvent.create!(
      event_type: 'performance_metric', 
      data: { event_name: 'theme_switch_started' }
    )
    UiMonitoringEvent.create!(
      event_type: 'performance_metric', 
      data: { event_name: 'theme_switched' }
    )
    UiMonitoringEvent.create!(
      event_type: 'ui_error', 
      data: { error_type: 'TypeError' }
    )
    
    theme_events = UiMonitoringEvent.theme_related
    assert_equal 2, theme_events.count
  end

  # Instance method tests
  test "should return error message for ui_error events" do
    event = UiMonitoringEvent.new(
      event_type: 'ui_error',
      data: { message: 'Test error message' }
    )
    assert_equal 'Test error message', event.error_message
  end
  
  test "should return nil error message for non-error events" do
    event = UiMonitoringEvent.new(
      event_type: 'performance_metric',
      data: { metric_name: 'load_time' }
    )
    assert_nil event.error_message
  end
  
  test "should detect browser from user agent" do
    event = UiMonitoringEvent.new(
      event_type: 'ui_error',
      data: { user_agent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36' }
    )
    assert_equal 'Chrome', event.browser_info
    
    event.data['user_agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:89.0) Gecko/20100101 Firefox/89.0'
    assert_equal 'Firefox', event.browser_info
    
    event.data['user_agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15'
    assert_equal 'Safari', event.browser_info
    
    event.data['user_agent'] = 'Some unknown browser'
    assert_equal 'Other', event.browser_info
  end

  # Class method tests
  test "should generate performance metrics summary" do
    UiMonitoringEvent.create!(
      event_type: 'performance_metric',
      data: { metric_name: 'page_load_time', value: 1000 }
    )
    UiMonitoringEvent.create!(
      event_type: 'performance_metric',
      data: { metric_name: 'page_load_time', value: 2000 }
    )
    
    summary = UiMonitoringEvent.performance_metrics_summary
    page_load_metric = summary.find { |s| s.metric_name == 'page_load_time' }
    
    assert_not_nil page_load_metric
    assert_equal 1500.0, page_load_metric.avg_value
    assert_equal 2, page_load_metric.count
  end
  
  test "should generate error summary" do
    UiMonitoringEvent.create!(
      event_type: 'ui_error',
      data: { error_type: 'TypeError' }
    )
    UiMonitoringEvent.create!(
      event_type: 'ui_error',
      data: { error_type: 'ReferenceError' }
    )
    UiMonitoringEvent.create!(
      event_type: 'ui_error',
      data: { error_type: 'TypeError' }
    )
    
    summary = UiMonitoringEvent.error_summary
    type_error_summary = summary.find { |s| s.error_type == 'TypeError' }
    
    assert_not_nil type_error_summary
    assert_equal 2, type_error_summary.count
  end
  
  test "should calculate theme switch performance" do
    UiMonitoringEvent.create!(
      event_type: 'performance_metric',
      data: { event_name: 'theme_switched', duration: 1500.5 }
    )
    UiMonitoringEvent.create!(
      event_type: 'performance_metric',
      data: { event_name: 'theme_switched', duration: 2000.0 }
    )
    
    avg_duration = UiMonitoringEvent.theme_switch_performance
    assert_equal 1750.25, avg_duration
  end
end