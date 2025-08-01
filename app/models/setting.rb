# Dynamic settings the user can change within the app (helpful for self-hosting)
class Setting < RailsSettings::Base
  cache_prefix { "v1" }

  field :exchange_rates_api_key, type: :string, default: ENV["EXCHANGE_RATES_API_KEY"]
  field :alpha_vantage_api_key, type: :string, default: ENV["ALPHA_VANTAGE_API_KEY"]
  field :openai_access_token, type: :string, default: ENV["OPENAI_ACCESS_TOKEN"]

  field :require_invite_for_signup, type: :boolean, default: false
  field :require_email_confirmation, type: :boolean, default: ENV.fetch("REQUIRE_EMAIL_CONFIRMATION", "true") == "true"
end
