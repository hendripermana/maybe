# frozen_string_literal: true

module Ui
  # Modern budget form component with theme-aware styling
  # Provides consistent form styling and validation across light and dark themes
  class BudgetFormComponent < BaseComponent
    attr_reader :budget, :url, :method

    def initialize(
      budget:,
      url: nil,
      method: :patch,
      **options
    )
      super(**options)
      @budget = budget
      @url = url || "/budgets/#{budget.to_param}"
      @method = method
    end

    def call
      content_tag(:div, class: "budget-form-container") do
        form_with(
          model: budget,
          url: url,
          method: method,
          class: "space-y-6",
          data: { controller: "budget-form" }
        ) do |f|
          concat(render_errors(f))
          concat(render_form_fields(f))
          concat(render_auto_suggest(f))
          concat(render_submit_button(f))
        end
      end
    end

    private

      def render_errors(form)
        return unless budget.errors.any?

        content_tag(:div, class: "rounded-lg border border-destructive bg-destructive/10 p-4") do
          content_tag(:div, class: "font-medium text-destructive") do
            "Please correct the following errors:"
          end +
          content_tag(:ul, class: "mt-2 list-disc pl-5 text-sm text-destructive") do
            budget.errors.full_messages.map do |message|
              content_tag(:li, message)
            end.join.html_safe
          end
        end
      end

      def render_form_fields(form)
        content_tag(:section, class: "space-y-4") do
          # Budgeted spending field
          concat(
            render(Ui::InputComponent.new(
              type: "number",
              name: "budget[budgeted_spending]",
              id: "budget_budgeted_spending",
              label: "Budgeted spending",
              placeholder: "Enter your monthly budget",
              value: budget.budgeted_spending,
              required: true,
              step: "0.01",
              min: "0",
              error: budget.errors[:budgeted_spending].first,
              help_text: "The total amount you plan to spend this month"
            ))
          )

          # Expected income field
          concat(
            render(Ui::InputComponent.new(
              type: "number",
              name: "budget[expected_income]",
              id: "budget_expected_income",
              label: "Expected income",
              placeholder: "Enter your expected monthly income",
              value: budget.expected_income,
              required: true,
              step: "0.01",
              min: "0",
              error: budget.errors[:expected_income].first,
              help_text: "The total income you expect to receive this month"
            ))
          )
        end
      end

      def render_auto_suggest(form)
        return unless budget.estimated_income && budget.estimated_spending

        content_tag(:div, class: "border border-border rounded-lg p-4 flex items-center justify-between") do
          content_tag(:div, class: "flex items-start") do
            # Icon
            content_tag(:div, class: "text-primary mr-3") do
              tag(:svg,
                xmlns: "http://www.w3.org/2000/svg",
                width: "20",
                height: "20",
                viewBox: "0 0 24 24",
                fill: "none",
                stroke: "currentColor",
                "stroke-width": "2",
                "stroke-linecap": "round",
                "stroke-linejoin": "round"
              ) do
                concat(tag(:path, d: "M15 14c.2-1 .7-1.7 1.5-2.5 1-.9 1.5-2.2 1.5-3.5A6 6 0 0 0 6 8c0 1 .2 2.2 1.5 3.5.7.7 1.3 1.5 1.5 2.5"))
                concat(tag(:path, d: "M9 18h6"))
                concat(tag(:path, d: "M10 22h4"))
              end
            end +
            # Text content
            content_tag(:div, class: "space-y-1") do
              content_tag(:h4, "Autosuggest income & spending budget", class: "text-sm font-medium text-primary") +
              content_tag(:p, "This will be based on transaction history. AI can make mistakes, verify before continuing.", class: "text-xs text-muted-foreground")
            end
          end +
          # Toggle component
          content_tag(:div) do
            content_tag(:label, class: "relative inline-flex items-center cursor-pointer") do
              tag(:input,
                type: "checkbox",
                id: "auto_fill",
                class: "sr-only peer",
                data: {
                  action: "change->budget-form#toggleAutoFill",
                  budget_form_income_param: { key: "budget_expected_income", value: sprintf("%.2f", budget.estimated_income) }.to_json,
                  budget_form_spending_param: { key: "budget_budgeted_spending", value: sprintf("%.2f", budget.estimated_spending) }.to_json
                }
              ) +
              content_tag(:div, "", class: "w-11 h-6 bg-muted rounded-full peer peer-focus:ring-2 peer-focus:ring-ring peer-checked:after:translate-x-full rtl:peer-checked:after:translate-x-[-100%] peer-checked:after:border-white after:content-[''] after:absolute after:top-0.5 after:start-[2px] after:bg-white after:border-gray-300 after:border after:rounded-full after:h-5 after:w-5 after:transition-all peer-checked:bg-primary")
            end
          end
        end
      end

      def render_submit_button(form)
        content_tag(:div, class: "flex justify-end") do
          content_tag(:button,
            "Continue",
            type: "submit",
            class: "inline-flex items-center justify-center rounded-md bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50"
          )
        end
      end
  end
end
