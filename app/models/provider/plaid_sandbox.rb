class Provider::PlaidSandbox < Provider::Plaid
  attr_reader :client

  def initialize
    @client = create_client
    @region = :us
  end

  def create_public_token(username: nil)
    client.sandbox_public_token_create(
      Plaid::SandboxPublicTokenCreateRequest.new(
        institution_id: "ins_109508", # "First Platypus Bank" (Plaid's sandbox institution that works with all products)
        initial_products: [ "transactions", "investments", "liabilities" ],
        options: {
          override_username: username || "custom_test"
        }
      )
    ).public_token
  end

  def fire_webhook(item, type: "TRANSACTIONS", code: "SYNC_UPDATES_AVAILABLE")
    client.sandbox_item_fire_webhook(
      Plaid::SandboxItemFireWebhookRequest.new(
        access_token: item.access_token,
        webhook_type: type,
        webhook_code: code,
      )
    )
  end

  def reset_login(item)
    client.sandbox_item_reset_login(
      Plaid::SandboxItemResetLoginRequest.new(
        access_token: item.access_token
      )
    )
  end

  private
    def create_client
      raise "Plaid sandbox is not supported in production" if Rails.env.production?

      # Create a test configuration if none exists (for testing)
      plaid_config = Rails.application.config.plaid || create_test_config

      api_client = Plaid::ApiClient.new(plaid_config)

      # Force sandbox environment for PlaidSandbox regardless of Rails config
      api_client.config.server_index = Plaid::Configuration::Environment["sandbox"]

      Plaid::PlaidApi.new(api_client)
    end

    def create_test_config
      config = Plaid::Configuration.new
      config.server_index = Plaid::Configuration::Environment["sandbox"]
      config.api_key["PLAID-CLIENT-ID"] = "test_client_id"
      config.api_key["PLAID-SECRET"] = "test_secret"
      config
    end
end
