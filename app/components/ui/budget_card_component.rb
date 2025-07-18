class UI::BudgetCardComponent < ViewComponent::Base
  STATUS_VARIANTS = {
    under_budget: {
      text_class: "text-green-500",
      progress_variant: :success
    },
    on_budget: {
      text_class: "text-yellow-500",
      progress_variant: :warning
    },
    over_budget: {
      text_class: "text-red-500",
      progress_variant: :danger
    },
    unallocated: {
      text_class: "text-muted-foreground",
      progress_variant: :default
    }
  }.freeze

  def initialize(budget_category:, **options)
    @budget_category = budget_category
    @options = options
  end

  def status
    return :unallocated unless @budget_category.initialized?
    
    if @budget_category.available_to_spend.negative?
      :over_budget
    elsif @budget_category.available_to_spend.zero? || @budget_category.percent_of_budget_spent > 90
      :on_budget
    else
      :under_budget
    end
  end

  def status_text
    case status
    when :over_budget
      "#{format_money(@budget_category.available_to_spend_money.abs)} over"
    when :on_budget, :under_budget
      "#{format_money(@budget_category.available_to_spend_money)} left"
    when :unallocated
      "#{@budget_category.median_monthly_expense_money.format} avg"
    end
  end

  def status_classes
    STATUS_VARIANTS[status][:text_class]
  end

  def progress_variant
    STATUS_VARIANTS[status][:progress_variant]
  end

  def percent_spent
    @budget_category.percent_of_budget_spent
  end

  def card_classes
    [
      "bg-card border border-border rounded-lg shadow-sm hover:shadow-md transition-shadow duration-200",
      "p-4 flex flex-col gap-3",
      @options[:class]
    ].compact.join(" ")
  end

  def has_icon?
    @budget_category.category.lucide_icon.present?
  end

  def icon_color_style
    "color: #{@budget_category.category.color}"
  end

  def icon_bg_style
    "background-color: #{hex_with_alpha(@budget_category.category.color, 0.1)}"
  end

  private

  def format_money(money)
    helpers.format_money(money)
  end

  def hex_with_alpha(hex, alpha)
    helpers.hex_with_alpha(hex, alpha)
  end
end