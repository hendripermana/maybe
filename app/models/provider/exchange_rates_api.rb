class Provider::ExchangeRatesApi < Provider
  include ExchangeRateConcept

  # Subclass so errors caught in this provider are raised as Provider::ExchangeRatesApi::Error
  Error = Class.new(Provider::Error)
  InvalidExchangeRateError = Class.new(Error)

  def initialize(api_key = nil)
    @api_key = api_key # Optional for free tier
  end

  def healthy?
    with_provider_response do
      response = client.get("#{base_url}/latest")
      JSON.parse(response.body).dig("success") == true
    end
  end

  def usage
    # Free tier doesn't provide usage info, return basic structure
    with_provider_response do
      UsageData.new(
        used: 0,
        limit: 1000, # Free tier limit
        utilization: 0,
        plan: api_key.present? ? "paid" : "free",
      )
    end
  end

  # ================================
  #          Exchange Rates
  # ================================

  def fetch_exchange_rate(from:, to:, date:)
    with_provider_response do
      response = client.get("#{base_url}/#{date}") do |req|
        req.params["base"] = from
        req.params["symbols"] = to
        req.params["access_key"] = api_key if api_key.present?
      end

      data = JSON.parse(response.body)
      
      unless data["success"]
        raise Error, data.dig("error", "info") || "API request failed"
      end

      rate = data.dig("rates", to)
      
      if rate.nil?
        Rails.logger.warn("#{self.class.name} returned invalid rate data for pair from: #{from} to: #{to} on: #{date}")
        Sentry.capture_exception(InvalidExchangeRateError.new("#{self.class.name} returned invalid rate data"), level: :warning) do |scope|
          scope.set_context("rate", { from: from, to: to, date: date })
        end
        raise InvalidExchangeRateError, "No rate found for #{from} to #{to} on #{date}"
      end

      Rate.new(date: date.to_date, from: from, to: to, rate: rate)
    end
  end

  def fetch_exchange_rates(from:, to:, start_date:, end_date:)
    with_provider_response do
      rates = []
      current_date = start_date.to_date
      end_date = end_date.to_date

      # Free tier only supports historical data for last 1000 days
      # For longer ranges, we'll fetch monthly samples
      date_range = (end_date - current_date).to_i
      
      if date_range > 365
        # For long ranges, sample monthly to stay within limits
        dates_to_fetch = []
        while current_date <= end_date
          dates_to_fetch << current_date
          current_date = current_date.next_month
        end
      else
        # For shorter ranges, fetch daily
        dates_to_fetch = (current_date..end_date).to_a
      end

      dates_to_fetch.each do |date|
        begin
          rate_response = fetch_exchange_rate(from: from, to: to, date: date)
          rates << rate_response.data if rate_response.success?
        rescue => e
          Rails.logger.warn("Failed to fetch rate for #{date}: #{e.message}")
          # Continue with other dates
        end
        
        # Add small delay to respect rate limits
        sleep(0.1) if dates_to_fetch.size > 10
      end

      rates.compact
    end
  end

  private
    attr_reader :api_key

    def base_url
      "https://api.exchangeratesapi.io/v1"
    end

    def client
      @client ||= Faraday.new(url: base_url) do |faraday|
        faraday.request(:retry, {
          max: 2,
          interval: 0.05,
          interval_randomness: 0.5,
          backoff_factor: 2
        })

        faraday.response :raise_error
        faraday.headers["User-Agent"] = "Maybe Finance App"
      end
    end
end