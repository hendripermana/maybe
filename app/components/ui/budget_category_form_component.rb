# frozen_string_literal: true

module Ui
  # Modern budget category form component with theme-aware styling
  # Provides consistent form styling and validation across light and dark themes
  class BudgetCategoryFormComponent < BaseComponent
    attr_reader :budget_category, :url, :method

    def initialize(
      budget_category:,
      url: nil,
      method: :patch,
      **options
    )
      super(**options)
      @budget_category = budget_category
      @url = url || "/budgets/#{budget_category.budget.to_param}/budget_categories/#{budget_category.id}"
      @method = method
    end

    def call
      content_tag(:div, id: dom_id(budget_category, :form), class: "w-full flex flex-wrap sm:flex-nowrap gap-3 items-center") do
        # Category color indicator
        concat(
          content_tag(:div, "",
            class: "w-1 h-3 rounded-xl mt-1",
            style: "background-color: #{budget_category.category.color}"
          )
        )

        # Category name and average info
        concat(
          content_tag(:div, class: "text-sm mr-3 flex-grow min-w-[150px]") do
            concat(content_tag(:p, budget_category.category.name, class: "text-primary font-medium mb-0.5"))
            concat(content_tag(:p, "#{budget_category.median_monthly_expense_money.format(precision: 0)}/m avg", class: "text-secondary"))
          end
        )

        # Form input
        concat(
          content_tag(:div, class: "ml-auto") do
            form_with(
              model: [ budget_category.budget, budget_category ],
              data: { controller: "auto-submit-form preserve-focus budget-touch" }
            ) do |f|
              content_tag(:div, class: "form-field w-[120px]") do
                content_tag(:div, class: "flex items-center") do
                  # Currency symbol
                  concat(content_tag(:span, budget_category.budget.currency_symbol, class: "text-secondary text-sm mr-2"))

                  # Input field - enhanced for touch
                  concat(
                    f.number_field(:budgeted_spending,
                      class: "form-field__input text-right bg-background [appearance:textfield] [&::-webkit-outer-spin-button]:appearance-none [&::-webkit-inner-spin-button]:appearance-none focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 py-2 px-3 sm:py-1.5 sm:px-2 touch-manipulation",
                      placeholder: "0",
                      step: budget_category.budget.currency_symbol == "¥" ? "1" : "0.01",
                      id: dom_id(budget_category, :budgeted_spending),
                      min: 0,
                      max: budget_category.max_allocation,
                      data: {
                        auto_submit_form_target: "auto",
                        budget_touch_target: "input",
                        action: "touchstart->preserve-focus#preserveFocus touchstart->budget-touch#handleTouchStart touchend->budget-touch#handleTouchEnd"
                      }
                    )
                  )
                end
              end
            end
          end
        )
      end
    end

    private

      def dom_id(record, prefix = nil)
        if record.respond_to?(:to_key) && record.to_key
          id = record.to_key.join("_")
          prefix ? "#{prefix}_#{id}" : id
        else
          # Handle uncategorized budget category which doesn't have a real ID
          id = record.id.to_s
          prefix ? "#{prefix}_#{id}" : id
        end
      end
  end
end
