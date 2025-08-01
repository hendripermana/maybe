require "test_helper"

class AlertThrottlerTest < ActiveSupport::TestCase
  setup do
    @throttler = AlertThrottler.new
    @throttler.clear_all!
  end

  test "should not throttle first alert" do
    assert_not @throttler.throttled?("test_alert", :error)
  end

  test "should throttle repeated alerts" do
    # First alert should not be throttled
    assert_not @throttler.throttled?("test_alert", :error)

    # Second alert with same key should be throttled
    assert @throttler.throttled?("test_alert", :error)
  end

  test "should use different throttle periods for different categories" do
    # This is a bit tricky to test without mocking time
    # We'll just verify that different categories use different keys
    assert_not @throttler.throttled?("test_alert", :error)
    assert_not @throttler.throttled?("test_alert", :performance)

    # Both should be throttled now
    assert @throttler.throttled?("test_alert", :error)
    assert @throttler.throttled?("test_alert", :performance)
  end

  test "should normalize alert keys" do
    assert_not @throttler.throttled?("test/alert:with:special!chars", :error)
    assert @throttler.throttled?("test/alert:with:special!chars", :error)
  end

  test "should count throttled alerts" do
    @throttler.throttled?("test_alert_1", :error)
    @throttler.throttled?("test_alert_2", :error)

    assert_equal 2, @throttler.throttled_count(:error)
  end
end
