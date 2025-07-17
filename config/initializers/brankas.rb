# frozen_string_literal: true

Rails.application.config.x.brankas = {
  api_key: ENV.fetch("BRANKAS_API_KEY", nil),
  base_url: ENV.fetch("BRANKAS_BASE_URL", "https://direct.sandbox.bnk.to"),
  default_currency: "IDR"
}