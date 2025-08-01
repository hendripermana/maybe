module ApiRateLimiter
  extend ActiveSupport::Concern

  included do
    class_attribute :rate_limited_actions, default: {}
  end

  class_methods do
    def rate_limit(action, limit:, period:)
      self.rate_limited_actions = rate_limited_actions.merge(
        action.to_sym => { limit: limit, period: period.to_i }
      )

      before_action -> { check_rate_limit }, only: action
    end
  end

  private

    def check_rate_limit
      action = action_name.to_sym
      return unless rate_limited_actions.key?(action)

      limit_config = rate_limited_actions[action]
      key = generate_rate_limit_key(action)

      # Get current count from Redis
      count = Rails.cache.read(key) || 0

      if count >= limit_config[:limit]
        render json: {
          error: "Rate limit exceeded",
          retry_after: calculate_retry_after(key)
        }, status: :too_many_requests
        return false
      end

      # Increment counter
      Rails.cache.increment(key)

      # Set expiration if this is the first request
      if count == 0
        Rails.cache.expire(key, limit_config[:period])
      end

      true
    end

    def generate_rate_limit_key(action)
      identifier = if user_signed_in?
        "user:#{current_user.id}"
      else
        "ip:#{anonymized_ip}"
      end

      "rate_limit:#{controller_path}:#{action}:#{identifier}"
    end

    def anonymized_ip
      ip = request.remote_ip

      # Anonymize IPv4 addresses
      if ip =~ /^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$/
        octets = ip.split(".")
        "#{octets[0]}.#{octets[1]}.0.0"
      elsif ip.include?(":") # IPv6
        # For IPv6, keep only the network portion
        ip.gsub(/:[^:]+:[^:]+$/, ":0:0")
      else
        ip
      end
    end

    def calculate_retry_after(key)
      # Get the TTL of the key to tell the client when they can retry
      ttl = Rails.cache.redis.ttl(key)
      ttl.positive? ? ttl : 60 # Default to 60 seconds if TTL is not available
    end
end
