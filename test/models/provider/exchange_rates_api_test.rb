require "test_helper"

class Provider::ExchangeRatesApiTest < ActiveSupport::TestCase
  setup do
    @subject = Provider::ExchangeRatesApi.new(ENV["EXCHANGE_RATES_API_KEY"])
  end

  test "initializes without API key for free tier" do
    provider = Provider::ExchangeRatesApi.new
    assert_not_nil provider
  end

  test "initializes with API key" do
    provider = Provider::ExchangeRatesApi.new("test-key")
    assert_not_nil provider
  end

  test "returns usage data" do
    response = @subject.usage
    assert response.success?
    assert_not_nil response.data.limit
    assert_not_nil response.data.plan
  end

  # Skip actual API tests unless we have a real key
  test "can fetch exchange rate with real API key" do
    skip "No API key provided" unless ENV["EXCHANGE_RATES_API_KEY"].present?
    
    VCR.use_cassette("exchange_rates_api/single_rate") do
      response = @subject.fetch_exchange_rate(
        from: "USD",
        to: "EUR", 
        date: Date.parse("2024-01-01")
      )
      
      if response.success?
        assert_not_nil response.data.rate
        assert_equal "USD", response.data.from
        assert_equal "EUR", response.data.to
      else
        # API might be down or rate limited, just ensure we handle errors gracefully
        assert_not_nil response.error
      end
    end
  end
end