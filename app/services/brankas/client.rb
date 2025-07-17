# frozen_string_literal: true
module Brankas
  class Error < StandardError; end

  class Client
    BASE_URL = Rails.configuration.x.brankas[:base_url]

    def initialize(api_key: Rails.configuration.x.brankas[:api_key])
      raise Error, "Missing BRANKAS_API_KEY" if api_key.blank?

      @conn = Faraday.new(url: BASE_URL) do |f|
        f.request  :json
        f.response :json, content_type: /json/
        f.headers["x-api-key"] = api_key
        f.options.timeout      = 10
        f.options.open_timeout = 5
      end
    end

    # 1. Create a checkout session and return redirect_url so user can grant consent
    # Docs: POST /v1/checkout ([api-reference.brankas.com](https://api-reference.brankas.com/))
    def checkout(return_url:, description: "Connect bank account to Maybe", amount_cents: 0, currency: Rails.configuration.x.brankas[:default_currency])
      body = {
        amount: {
          currency: currency,
          value: amount_cents
        },
        description: description,
        client: {
          return_url: return_url
        }
      }

      handle(@conn.post("/v1/checkout", body))
    end

    # 2. Retrieve details for a single transaction
    # Docs: GET /v1/transaction?transaction_id=… ([api-reference.brankas.com](https://api-reference.brankas.com/))
    def transaction(transaction_id)
      handle(@conn.get("/v1/transaction", { transaction_id: transaction_id })).dig("transactions", 0)
    end

    # 3. List paginated transactions (most recent first)
    def transactions(page: 1)
      handle(@conn.get("/v1/transaction", { page: page }))
    end

    private

    def handle(response)
      raise Error, response.body unless response.success?
      response.body
    end
  end
end
