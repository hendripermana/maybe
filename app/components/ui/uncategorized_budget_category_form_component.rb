# frozen_string_literal: true

module Ui
  # Modern uncategorized budget category form component with theme-aware styling
  # Provides consistent form styling across light and dark themes
  class UncategorizedBudgetCategoryFormComponent < BaseComponent
    attr_reader :budget

    def initialize(
      budget:,
      **options
    )
      super(**options)
      @budget = budget
    end

    def call
      budget_category = budget.uncategorized_budget_category

      content_tag(:div, id: dom_id(budget, :uncategorized_budget_category_form), class: "flex gap-3 items-center") do
        # Category color indicator
        concat(
          content_tag(:div, "", 
            class: "w-1 h-3 rounded-xl mt-1", 
            style: "background-color: #{budget_category.category.color}"
          )
        )

        # Category name and average info
        concat(
          content_tag(:div, class: "text-sm mr-3") do
            concat(content_tag(:p, budget_category.category.name, class: "text-primary font-medium mb-0.5"))
            concat(content_tag(:p, "#{budget_category.avg_monthly_expense_money.format(precision: 0)}/m avg", class: "text-secondary"))
          end
        )

        # Disabled input field
        concat(
          content_tag(:div, class: "ml-auto") do
            content_tag(:div, class: "form-field w-[120px]") do
              content_tag(:div, class: "flex items-center") do
                # Currency symbol
                concat(content_tag(:span, budget_category.budgeted_spending_money.currency.symbol, class: "text-subdued text-sm mr-2"))
                
                # Input field (disabled)
                concat(
                  text_field_tag(:uncategorized, 
                    budget_category.budgeted_spending_money.amount, 
                    autocomplete: "off", 
                    class: "form-field__input text-right bg-muted [appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none", 
                    disabled: true
                  )
                )
              end
            end
          end
        )
      end
    end

    private

    def dom_id(record, prefix = nil)
      if record.respond_to?(:to_key) && record.to_key
        id = record.to_key.join('_')
        prefix ? "#{prefix}_#{id}" : id
      else
        id = record.id.to_s
        prefix ? "#{prefix}_#{id}" : id
      end
    end
  end
end