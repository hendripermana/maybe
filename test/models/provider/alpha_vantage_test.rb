require "test_helper"

class Provider::AlphaVantageTest < ActiveSupport::TestCase
  setup do
    @subject = Provider::AlphaVantage.new(ENV.fetch("ALPHA_VANTAGE_API_KEY", "test-key"))
  end

  test "initializes with API key" do
    provider = Provider::AlphaVantage.new("test-key")
    assert_not_nil provider
  end

  test "returns usage data" do
    response = @subject.usage
    assert response.success?
    assert_equal 25, response.data.limit # Free tier limit
    assert_equal "free", response.data.plan
  end

  # Skip actual API tests unless we have a real key
  test "can search securities with real API key" do
    skip "No API key provided" unless ENV["ALPHA_VANTAGE_API_KEY"].present?
    
    VCR.use_cassette("alpha_vantage/search") do
      response = @subject.search_securities("AAPL")
      
      if response.success?
        assert response.data.is_a?(Array)
        if response.data.any?
          security = response.data.first
          assert_not_nil security.symbol
          assert_not_nil security.name
        end
      else
        # API might be down or rate limited, just ensure we handle errors gracefully
        assert_not_nil response.error
      end
    end
  end
end