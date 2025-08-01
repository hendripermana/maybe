# frozen_string_literal: true

class Dashboard::NetWorthComponent < ViewComponent::Base
  attr_reader :balance_sheet, :period, :periods

  def initialize(balance_sheet:, period: Period.last_30_days)
    @balance_sheet = balance_sheet
    @period = period
    @periods = [
      { key: "7d", label: "7 days", period: Period.last_7_days },
      { key: "30d", label: "30 days", period: Period.last_30_days },
      { key: "90d", label: "90 days", period: Period.last_90_days },
      { key: "1y", label: "1 year", period: Period.last_365_days },
      { key: "all", label: "All time", period: Period.custom(start_date: 1.year.ago.to_date, end_date: Date.current) }
    ]
  end

  private

    def net_worth_series
      @net_worth_series ||= balance_sheet.net_worth_series(period: period)
    end

    def current_value
      balance_sheet.net_worth_money.format
    end

    def trend_data
      return nil unless net_worth_series.respond_to?(:trend)
      net_worth_series.trend
    end

    def has_data?
      net_worth_series.respond_to?(:any?) && net_worth_series.any?
    end

    def chart_data
      return "[]" unless has_data?
      net_worth_series.to_json
    end

    def period_active?(period_key)
      case period_key
      when "7d"
        period.days == 7
      when "30d"
        period.days == 30
      when "90d"
        period.days == 90
      when "1y"
        period.days == 365
      when "all"
        period.start_date == Current.family.oldest_entry_date
      else
        false
      end
    end
end