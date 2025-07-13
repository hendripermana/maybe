# frozen_string_literal: true

# Dashboard statistics overview component
class Dashboard::StatsComponent < ViewComponent::Base
  attr_reader :balance_sheet

  def initialize(balance_sheet:, **html_options)
    @balance_sheet = balance_sheet
    @html_options = html_options
  end

  private

    def stats_data
      [
        {
          title: "Net Worth",
          value: net_worth_value,
          description: "Your total financial worth",
          icon: "trending-up",
          variant: :accent,
          trend: net_worth_trend,
          loading: balance_sheet.syncing?
        },
        {
          title: "Total Assets",
          value: assets_value,
          description: "Everything you own",
          icon: "piggy-bank",
          variant: :success,
          trend: assets_trend,
          loading: balance_sheet.syncing?
        },
        {
          title: "Total Liabilities",
          value: liabilities_value,
          description: "What you owe",
          icon: "credit-card",
          variant: :warning,
          trend: liabilities_trend,
          loading: balance_sheet.syncing?
        },
        {
          title: "Cash Flow",
          value: cash_flow_value,
          description: "This month's flow",
          icon: "activity",
          variant: cash_flow_variant,
          trend: cash_flow_trend,
          loading: balance_sheet.syncing?
        }
      ]
    end

    def net_worth_value
      balance_sheet.net_worth_money.format
    end

    def assets_value
      assets_total = balance_sheet.classification_groups
                                  .find { |g| g.name == "Assets" }&.total_money
      assets_total&.format || "$0"
    end

    def liabilities_value
      liabilities_total = balance_sheet.classification_groups
                                       .find { |g| g.name == "Liabilities" }&.total_money
      liabilities_total&.format || "$0"
    end

    def cash_flow_value
      # This would need to be passed from the controller or calculated
      # For now, returning a placeholder
      "$2,450"
    end

    def net_worth_trend
      # Placeholder - would need actual trend calculation
      { direction: :up, percentage: 12.5, positive: true }
    end

    def assets_trend
      # Placeholder - would need actual trend calculation
      { direction: :up, percentage: 8.3, positive: true }
    end

    def liabilities_trend
      # Placeholder - would need actual trend calculation
      { direction: :down, percentage: 3.2, positive: true }
    end

    def cash_flow_trend
      # Placeholder - would need actual trend calculation
      { direction: :up, percentage: 15.7, positive: true }
    end

    def cash_flow_variant
      # Determine variant based on cash flow value (positive/negative)
      :success # Placeholder
    end

    def css_classes
      classes = [
        "grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-4 md:gap-6"
      ]

      classes << @html_options[:class] if @html_options[:class]
      classes.compact.join(" ")
    end

    def html_options
      @html_options.except(:class).merge(class: css_classes)
    end
end
