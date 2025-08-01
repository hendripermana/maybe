# frozen_string_literal: true

module Ui
  # Responsive grid system for budget categories
  # Provides consistent layout across all screen sizes with proper spacing and hierarchy
  class ResponsiveBudgetGridComponent < BaseComponent
    attr_reader :budget, :budget_categories

    def initialize(
      budget:,
      budget_categories:,
      **options
    )
      super(**options)
      @budget = budget
      @budget_categories = budget_categories
    end

    def call
      content_tag(:div, class: "responsive-budget-grid") do
        # Allocation progress at the top
        concat(render_allocation_progress)

        # Budget categories grid
        concat(
          content_tag(:div, class: "budget-categories-container space-y-4 mb-4") do
            # Group categories
            BudgetCategory::Group.for(budget_categories).sort_by(&:name).each do |group|
              concat(render_category_group(group))
            end

            # Uncategorized budget category
            concat(render_uncategorized_category)
          end
        )

        # Confirm button at the bottom
        concat(render_confirm_button)
      end
    end

    private

      def render_allocation_progress
        content_tag(:div, id: dom_id(budget, :allocation_progress), class: "allocation-progress-container mb-6") do
          render partial: "budget_categories/allocation_progress", locals: { budget: budget }
        end
      end

      def render_category_group(group)
        content_tag(:div, class: "category-group space-y-4", role: "group", "aria-label": "#{group.name} budget category") do
          # Parent category
          concat(
            render(Ui::BudgetCategoryFormComponent.new(budget_category: group.budget_category))
          )

          # Subcategories with proper indentation
          unless group.budget_subcategories.empty?
            concat(
              content_tag(:div, class: "subcategories-container space-y-4 pl-4 sm:pl-6", role: "group", "aria-label": "Subcategories for #{group.name}") do
                group.budget_subcategories.each do |budget_subcategory|
                  concat(
                    content_tag(:div, class: "subcategory-item flex items-center gap-2 sm:gap-4") do
                      # Indentation indicator with proper aria-hidden
                      concat(
                        content_tag(:div, class: "flex items-center justify-center text-subdued", "aria-hidden": "true") do
                          tag(:svg, xmlns: "http://www.w3.org/2000/svg", width: "16", height: "16", viewBox: "0 0 24 24", fill: "none", stroke: "currentColor", stroke_width: "2", stroke_linecap: "round", stroke_linejoin: "round", class: "corner-down-right-icon") do
                            concat(tag(:polyline, points: "15 10 20 15 15 20"))
                            concat(tag(:path, d: "M4 4v7a4 4 0 0 0 4 4h12"))
                          end
                        end
                      )

                      # Subcategory form
                      concat(
                        render(Ui::BudgetCategoryFormComponent.new(budget_category: budget_subcategory))
                      )
                    end
                  )
                end
              end
            )
          end
        end
      end

      def render_uncategorized_category
        content_tag(:div, class: "uncategorized-category-container") do
          render(Ui::UncategorizedBudgetCategoryFormComponent.new(budget: budget))
        end
      end

      def render_confirm_button
        content_tag(:div, id: dom_id(budget, :confirm_button), class: "confirm-button-container mt-6") do
          render(ButtonComponent.new(
            text: "Confirm",
            variant: "primary",
            full_width: true,
            href: budget_path(budget),
            method: :get,
            disabled: !budget.allocations_valid?
          ))
        end
      end

      def dom_id(record, prefix = nil)
        if record.respond_to?(:to_key) && record.to_key
          id = record.to_key.join("_")
          prefix ? "#{prefix}_#{id}" : id
        else
          id = record.id.to_s
          prefix ? "#{prefix}_#{id}" : id
        end
      end

      def budget_path(budget)
        "/budgets/#{budget.to_param}"
      end
  end
end
