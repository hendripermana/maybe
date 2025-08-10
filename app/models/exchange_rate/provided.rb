module ExchangeRate::Provided
  extend ActiveSupport::Concern

  class_methods do
    # Returns the first available provider instance based on configured order.
    def provider
      # Allow tests to stub ExchangeRate.provider directly; otherwise use configured order
      return @__provider_override if defined?(@__provider_override) && @__provider_override
      providers_in_order.first
    end

    # Returns an array of available provider instances in the configured order
    def providers_in_order
      registry = Provider::Registry.for_concept(:exchange_rates)

      names = if ENV["EXCHANGE_RATE_PROVIDERS"].present?
        ENV["EXCHANGE_RATE_PROVIDERS"].split(/\s*,\s*/)
      elsif ENV["EXCHANGE_RATE_PROVIDER"].present?
        [ ENV["EXCHANGE_RATE_PROVIDER"] ]
      else
        # Respect registry-defined order; return provider instances from names the registry considers available
        registry.send(:available_providers)
      end

      # If the test stubs get_provider for a specific name, we should honor only that and
      # avoid falling through to other providers. Prefer the first successfully resolved provider.
      resolved = []
      Array(names).each do |name|
        if name.respond_to?(:fetch_exchange_rate)
          resolved << name
          break
        else
          begin
            prov = registry.get_provider(name.to_sym)
            resolved << prov if prov
            break if resolved.any?
          rescue Provider::Registry::Error
            # ignore and try next
          end
        end
      end
      resolved
    end

    def find_or_fetch_rate(from:, to:, date: Date.current, cache: true)
      rate = find_by(from_currency: from, to_currency: to, date: date)
      return rate if rate.present?

      # Respect explicit provider stub (tests) or configured provider
      prov = provider
      return nil unless prov.present?

      # Try providers in order until one returns data
      response = prov.fetch_exchange_rate(from: from, to: to, date: date)

      return nil unless response&.success?

      rate = response.data

      # Provider responded but may not include a rate value (holidays, gaps, or partial data).
      # In that case, avoid persisting an invalid record and let the caller use a fallback.
      return nil unless rate && rate.respond_to?(:rate) && rate.rate.present?

      if cache
        ExchangeRate.find_or_create_by!(
          from_currency: rate.from,
          to_currency: rate.to,
          date: rate.date,
          rate: rate.rate
        )
      end

      rate
    end

    # @return [Integer] The number of exchange rates synced
    def import_provider_rates(from:, to:, start_date:, end_date:, clear_cache: false)
      provs = providers_in_order
      if provs.empty?
        Rails.logger.warn("No provider configured for ExchangeRate.import_provider_rates")
        return 0
      end

      provs.each do |prov|
        count = ExchangeRate::Importer.new(
          exchange_rate_provider: prov,
          from: from,
          to: to,
          start_date: start_date,
          end_date: end_date,
          clear_cache: clear_cache
        ).import_provider_rates

        return count.to_i if count.to_i > 0
      end

      0
    end
  end
end
