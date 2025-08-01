# frozen_string_literal: true

module Ui
  # Responsive transaction list component that adapts to different screen sizes
  # Provides touch-friendly interactions for mobile devices and proper column prioritization
  class ResponsiveTransactionListComponent < ViewComponent::Base
    attr_reader :entries, :view_ctx, :balance_trends

    def initialize(entries:, view_ctx: "global", balance_trends: nil)
      @entries = entries
      @view_ctx = view_ctx
      @balance_trends = balance_trends
    end

    def call
      content_tag(:div, class: "responsive-transaction-list") do
        if entries.any?
          render_transaction_list
        else
          render_empty_state
        end
      end
    end

    private

      def render_transaction_list
        content_tag(:div, class: "space-y-2") do
          # Header row - only visible on tablet and larger screens
          concat(render_header_row)

          # Transaction items
          entries.each do |entry|
            balance_trend = balance_trends&.dig(entry.id)
            concat(render(TransactionItemComponent.new(
              entry: entry,
              view_ctx: view_ctx,
              balance_trend: balance_trend
            )))
          end
        end
      end

      def render_header_row
        content_tag(:div, class: "hidden md:grid md:grid-cols-12 text-xs font-medium text-muted-foreground px-4 py-2") do
          # Transaction column header
          concat(content_tag(:div, "Transaction", class: "col-span-6"))

          # Category column header - only visible on large screens
          concat(content_tag(:div, "Category", class: "hidden lg:block col-span-2"))

          # Amount column header
          concat(content_tag(:div, "Amount", class: "col-span-2 text-right"))

          # Balance column header - only visible on large screens and when not in global view
          if view_ctx != "global"
            concat(content_tag(:div, "Balance", class: "hidden lg:block col-span-2 text-right"))
          end
        end
      end

      def render_empty_state
        content_tag(:div, class: "flex flex-col items-center justify-center p-8 text-center border border-dashed border-border rounded-lg bg-muted/50") do
          concat(content_tag(:div, class: "mb-4 rounded-full bg-primary/10 p-3") do
            content_tag(:svg, class: "h-6 w-6 text-primary", xmlns: "http://www.w3.org/2000/svg", fill: "none", viewBox: "0 0 24 24", stroke: "currentColor") do
              tag(:path, stroke_linecap: "round", stroke_linejoin: "round", stroke_width: "2", d: "M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z")
            end
          end)
          concat(content_tag(:h3, "No transactions found", class: "text-lg font-medium"))
          concat(content_tag(:p, "Try adjusting your filters or create a new transaction.", class: "text-sm text-muted-foreground mt-2"))
        end
      end
  end
end
