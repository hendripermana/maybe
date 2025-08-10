module Security::Provided
  extend ActiveSupport::Concern

  SecurityInfoMissingError = Class.new(StandardError)

  class_methods do
    # Returns the first available provider instance based on configured order.
    # Order of precedence:
    # 1) SECURITIES_PROVIDERS (comma-separated list), e.g. "twelve_data,alpha_vantage"
    # 2) SECURITIES_PROVIDER (single value)
    # 3) Registry default order for :securities concept
    def provider
      return @__provider_override if defined?(@__provider_override) && @__provider_override
      providers_in_order.first
    end

    # Returns an array of available provider instances in the configured order
    def providers_in_order
      registry = Provider::Registry.for_concept(:securities)

      names = if ENV["SECURITIES_PROVIDERS"].present?
        ENV["SECURITIES_PROVIDERS"].split(/\s*,\s*/)
      elsif ENV["SECURITIES_PROVIDER"].present?
        [ ENV["SECURITIES_PROVIDER"] ]
      else
        # Use registry ordering (%i[twelve_data alpha_vantage]) without hardcoding
        # and let registry resolve each provider (may be nil if not configured)
        registry.send(:available_providers)
      end

      resolved = []
      Array(names).each do |name|
        if name.respond_to?(:fetch_security_price)
          resolved << name
          break
        else
          begin
            prov = registry.get_provider(name.to_sym)
            resolved << prov if prov
            break if resolved.any?
          rescue Provider::Registry::Error
            # ignore and continue
          end
        end
      end
      resolved
    end

    def search_provider(symbol, country_code: nil, exchange_operating_mic: nil)
      return [] if provider.nil? || symbol.blank?

      params = {
        country_code: country_code,
        exchange_operating_mic: exchange_operating_mic
      }.compact_blank

      providers_in_order.each do |prov|
        response = prov.search_securities(symbol, **params)
        next unless response.success? && response.data.present?

        return response.data.map do |provider_security|
          # Need to map to domain model so Combobox can display via to_combobox_option
          Security.new(
            ticker: provider_security.symbol,
            name: provider_security.name,
            logo_url: provider_security.logo_url,
            exchange_operating_mic: provider_security.exchange_operating_mic,
            country_code: provider_security.country_code
          )
        end
      end

      []
    end
  end

  def find_or_fetch_price(date: Date.current, cache: true)
    price = prices.find_by(date: date)

    return price if price.present?

    prov = self.class.provider
    return nil if prov.nil?

    response = prov.fetch_security_price(
      symbol: ticker,
      exchange_operating_mic: exchange_operating_mic,
      date: date
    )

    return nil unless response.success?

    price = response.data
    Security::Price.find_or_create_by!(
      security_id: self.id,
      date: price.date,
      price: price.price,
      currency: price.currency
    ) if cache
    price
  end

  def import_provider_details(clear_cache: false)
    provs = self.class.providers_in_order
    if provs.empty?
      Rails.logger.warn("No provider configured for Security.import_provider_details")
      return
    end

    if self.name.present? && self.logo_url.present? && !clear_cache
      return
    end

    provs.each do |prov|
      response = prov.fetch_security_info(
        symbol: ticker,
        exchange_operating_mic: exchange_operating_mic
      )

      if response.success?
        update(
          name: response.data.name,
          logo_url: response.data.logo_url,
        )
        return
      else
        Rails.logger.warn("Failed to fetch security info for #{ticker} from #{prov.class.name}: #{response.error.message}")
      end
    end

    Sentry.capture_exception(SecurityInfoMissingError.new("Failed to get security info"), level: :warning) do |scope|
      scope.set_tags(security_id: self.id)
      scope.set_context("security", { id: self.id, provider_error: "all providers failed" })
    end
  end

  def import_provider_prices(start_date:, end_date:, clear_cache: false)
    provs = self.class.providers_in_order
    if provs.empty?
      Rails.logger.warn("No provider configured for Security.import_provider_prices")
      return 0
    end

    provs.each do |prov|
      count = Security::Price::Importer.new(
        security: self,
        security_provider: prov,
        start_date: start_date,
        end_date: end_date,
        clear_cache: clear_cache
      ).import_provider_prices

      return count if count.to_i > 0
    end

    0
  end

  private
    def provider
      self.class.provider
    end
end
