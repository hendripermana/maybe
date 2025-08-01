class AlertThrottler
  # Default throttling periods for different alert types
  DEFAULT_THROTTLE_PERIODS = {
    error: 30.minutes,
    performance: 1.hour,
    accessibility: 2.hours,
    general: 1.hour
  }.freeze

  def initialize
    @redis = Redis.new
  end

  # Check if an alert should be throttled
  # Returns true if the alert should be suppressed (throttled)
  def throttled?(alert_key, category)
    key = redis_key(alert_key)

    # Check if this alert has been sent recently
    if @redis.exists?(key)
      return true
    end

    # If not throttled, set the throttle key with appropriate expiration
    throttle_period = DEFAULT_THROTTLE_PERIODS[category.to_sym] || DEFAULT_THROTTLE_PERIODS[:general]
    @redis.setex(key, throttle_period.to_i, 1)

    # Not throttled
    false
  end

  # Get the number of alerts that have been throttled in the last period
  def throttled_count(category, period = 24.hours)
    pattern = "ui_monitoring_alert:#{category}:*"
    keys = @redis.keys(pattern)
    keys.size
  end

  # Clear all throttling keys (useful for testing)
  def clear_all!
    keys = @redis.keys("ui_monitoring_alert:*")
    @redis.del(keys) if keys.any?
  end

  private

    def redis_key(alert_key)
      # Normalize the key to avoid special characters
      normalized_key = alert_key.to_s.gsub(/[^a-zA-Z0-9_-]/, "_")
      "ui_monitoring_alert:#{normalized_key}"
    end
end
