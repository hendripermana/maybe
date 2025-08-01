class Provider::AlphaVantage < Provider
  include SecurityConcept

  # Subclass so errors caught in this provider are raised as Provider::AlphaVantage::Error
  Error = Class.new(Provider::Error)
  InvalidSecurityPriceError = Class.new(Error)

  def initialize(api_key)
    @api_key = api_key
  end

  def healthy?
    with_provider_response do
      response = client.get(base_url) do |req|
        req.params["function"] = "GLOBAL_QUOTE"
        req.params["symbol"] = "AAPL"
        req.params["apikey"] = api_key
      end
      
      data = JSON.parse(response.body)
      !data.key?("Error Message") && !data.key?("Note")
    end
  end

  def usage
    # Alpha Vantage doesn't provide usage info in API, return basic structure
    with_provider_response do
      UsageData.new(
        used: 0,
        limit: 25, # Free tier: 25 requests per day
        utilization: 0,
        plan: "free",
      )
    end
  end

  # ================================
  #           Securities
  # ================================

  def search_securities(symbol, country_code: nil, exchange_operating_mic: nil)
    with_provider_response do
      response = client.get(base_url) do |req|
        req.params["function"] = "SYMBOL_SEARCH"
        req.params["keywords"] = symbol
        req.params["apikey"] = api_key
      end

      data = JSON.parse(response.body)
      
      if data.key?("Error Message") || data.key?("Note")
        raise Error, data["Error Message"] || data["Note"] || "API request failed"
      end

      matches = data.dig("bestMatches") || []
      
      matches.map do |security|
        # Alpha Vantage format: "1. symbol", "2. name", etc.
        Security.new(
          symbol: security["1. symbol"],
          name: security["2. name"],
          logo_url: nil, # Alpha Vantage doesn't provide logos
          exchange_operating_mic: map_exchange_to_mic(security["4. region"]),
          country_code: map_region_to_country(security["4. region"])
        )
      end
    end
  end

  def fetch_security_info(symbol:, exchange_operating_mic:)
    with_provider_response do
      response = client.get(base_url) do |req|
        req.params["function"] = "OVERVIEW"
        req.params["symbol"] = symbol
        req.params["apikey"] = api_key
      end

      data = JSON.parse(response.body)
      
      if data.key?("Error Message") || data.key?("Note") || data.empty?
        raise Error, data["Error Message"] || data["Note"] || "No data found"
      end

      SecurityInfo.new(
        symbol: symbol,
        name: data["Name"],
        links: { homepage_url: data["OfficialSite"] }.compact,
        logo_url: nil,
        description: data["Description"],
        kind: data["AssetType"],
        exchange_operating_mic: exchange_operating_mic
      )
    end
  end

  def fetch_security_price(symbol:, exchange_operating_mic: nil, date:)
    with_provider_response do
      # For single date, use daily adjusted data
      response = client.get(base_url) do |req|
        req.params["function"] = "TIME_SERIES_DAILY_ADJUSTED"
        req.params["symbol"] = symbol
        req.params["apikey"] = api_key
        req.params["outputsize"] = "compact" # Last 100 data points
      end

      data = JSON.parse(response.body)
      
      if data.key?("Error Message") || data.key?("Note")
        raise Error, data["Error Message"] || data["Note"] || "API request failed"
      end

      time_series = data["Time Series (Daily)"]
      date_str = date.to_s
      
      price_data = time_series[date_str]
      
      if price_data.nil?
        # Try to find closest available date
        available_dates = time_series.keys.map(&:to_date).sort
        closest_date = available_dates.find { |d| d <= date.to_date }
        
        if closest_date
          price_data = time_series[closest_date.to_s]
          date = closest_date
        else
          raise Error, "No price data found for #{symbol} on or before #{date}"
        end
      end

      Price.new(
        symbol: symbol,
        date: date.to_date,
        price: price_data["4. close"].to_f,
        currency: "USD", # Alpha Vantage primarily provides USD prices
        exchange_operating_mic: exchange_operating_mic
      )
    end
  end

  def fetch_security_prices(symbol:, exchange_operating_mic: nil, start_date:, end_date:)
    with_provider_response do
      response = client.get(base_url) do |req|
        req.params["function"] = "TIME_SERIES_DAILY_ADJUSTED"
        req.params["symbol"] = symbol
        req.params["apikey"] = api_key
        req.params["outputsize"] = "full" # All available data
      end

      data = JSON.parse(response.body)
      
      if data.key?("Error Message") || data.key?("Note")
        raise Error, data["Error Message"] || data["Note"] || "API request failed"
      end

      time_series = data["Time Series (Daily)"] || {}
      prices = []

      time_series.each do |date_str, price_data|
        date = Date.parse(date_str)
        
        # Filter by date range
        next if date < start_date.to_date || date > end_date.to_date
        
        price = price_data["4. close"].to_f
        
        if price.nil? || price <= 0
          Rails.logger.warn("#{self.class.name} returned invalid price data for security #{symbol} on: #{date}")
          next
        end

        prices << Price.new(
          symbol: symbol,
          date: date,
          price: price,
          currency: "USD",
          exchange_operating_mic: exchange_operating_mic
        )
      end

      prices.sort_by(&:date)
    end
  end

  private
    attr_reader :api_key

    def base_url
      "https://www.alphavantage.co/query"
    end

    def client
      @client ||= Faraday.new do |faraday|
        faraday.request(:retry, {
          max: 2,
          interval: 1, # Alpha Vantage has rate limits
          interval_randomness: 0.5,
          backoff_factor: 2
        })

        faraday.response :raise_error
        faraday.headers["User-Agent"] = "Maybe Finance App"
      end
    end

    def map_exchange_to_mic(region)
      case region&.upcase
      when "UNITED STATES"
        "XNAS" # Default to NASDAQ
      when "UNITED KINGDOM"
        "XLON"
      when "CANADA"
        "XTSE"
      else
        nil
      end
    end

    def map_region_to_country(region)
      case region&.upcase
      when "UNITED STATES"
        "US"
      when "UNITED KINGDOM"
        "GB"
      when "CANADA"
        "CA"
      else
        "US" # Default
      end
    end
end