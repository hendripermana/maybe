# frozen_string_literal: true

module Ui
  # Modern transaction bulk update form component with theme-aware styling
  # Provides consistent form styling and validation across light and dark themes
  class TransactionBulkUpdateComponent < BaseComponent
    attr_reader :url, :method

    def initialize(
      url: nil,
      method: :post,
      **options
    )
      super(**options)
      @url = url || '/transactions/bulk_update'
      @method = method
    end

    def call
      content_tag(:div, class: "transaction-bulk-update-container") do
        form_with(
          url: url,
          scope: "bulk_update",
          method: method,
          class: "h-full flex flex-col justify-between gap-4",
          data: { turbo_frame: "_top" }
        ) do |f|
          concat(render_form_sections(f))
          concat(render_form_actions)
        end
      end
    end

    private

    def render_form_sections(form)
      content_tag(:div, class: "space-y-4") do
        concat(render_overview_section(form))
        concat(render_transactions_section(form))
      end
    end

    def render_overview_section(form)
      content_tag(:div, class: "border border-border rounded-lg") do
        content_tag(:div, class: "flex items-center justify-between p-4 cursor-pointer", data: { controller: "disclosure", action: "click->disclosure#toggle" }) do
          content_tag(:h3, "Overview", class: "text-sm font-medium") +
          content_tag(:div, class: "text-muted-foreground") do
            tag(:svg, 
              xmlns: "http://www.w3.org/2000/svg", 
              width: "16", 
              height: "16", 
              viewBox: "0 0 24 24", 
              fill: "none", 
              stroke: "currentColor", 
              "stroke-width": "2", 
              "stroke-linecap": "round", 
              "stroke-linejoin": "round",
              class: "chevron-down transition-transform",
              data: { "disclosure-target": "chevron" }
            ) do
              tag(:polyline, points: "6 9 12 15 18 9")
            end
          end
        end +
        content_tag(:div, class: "p-4 border-t border-border", data: { "disclosure-target": "content" }) do
          content_tag(:div, class: "pb-6 space-y-2") do
            render(Ui::InputComponent.new(
              type: "date",
              name: "bulk_update[date]",
              id: "bulk_update_date",
              label: "Date",
              max: Date.current
            ))
          end
        end
      end
    end

    def render_transactions_section(form)
      content_tag(:div, class: "border border-border rounded-lg") do
        content_tag(:div, class: "flex items-center justify-between p-4 cursor-pointer", data: { controller: "disclosure", action: "click->disclosure#toggle" }) do
          content_tag(:h3, "Transactions", class: "text-sm font-medium") +
          content_tag(:div, class: "text-muted-foreground") do
            tag(:svg, 
              xmlns: "http://www.w3.org/2000/svg", 
              width: "16", 
              height: "16", 
              viewBox: "0 0 24 24", 
              fill: "none", 
              stroke: "currentColor", 
              "stroke-width": "2", 
              "stroke-linecap": "round", 
              "stroke-linejoin": "round",
              class: "chevron-down transition-transform",
              data: { "disclosure-target": "chevron" }
            ) do
              tag(:polyline, points: "6 9 12 15 18 9")
            end
          end
        end +
        content_tag(:div, class: "p-4 border-t border-border", data: { "disclosure-target": "content" }) do
          content_tag(:div, class: "space-y-4") do
            # Category select
            concat(
              render_category_select(form)
            )
            
            # Merchant select
            concat(
              render_merchant_select(form)
            )
            
            # Tags select
            concat(
              render_tags_select(form)
            )
            
            # Notes textarea
            concat(
              render(Ui::InputComponent.new(
                type: "textarea",
                name: "bulk_update[notes]",
                id: "bulk_update_notes",
                label: "Notes",
                placeholder: "Enter a note that will be applied to selected transactions",
                rows: 5
              ))
            )
          end
        end
      end
    end

    def render_category_select(form)
      content_tag(:div, class: "space-y-2") do
        content_tag(:label, "Category", for: "bulk_update_category_id", class: "text-sm font-medium leading-none") +
        content_tag(:select,
          name: "bulk_update[category_id]",
          id: "bulk_update_category_id",
          class: "flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
        ) do
          concat(content_tag(:option, "Select a category", value: ""))
          Current.family.categories.alphabetically.each do |category|
            concat(content_tag(:option, category.name, value: category.id))
          end
        end
      end
    end

    def render_merchant_select(form)
      content_tag(:div, class: "space-y-2") do
        content_tag(:label, "Merchant", for: "bulk_update_merchant_id", class: "text-sm font-medium leading-none") +
        content_tag(:select,
          name: "bulk_update[merchant_id]",
          id: "bulk_update_merchant_id",
          class: "flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
        ) do
          concat(content_tag(:option, "Select a merchant", value: ""))
          Current.family.merchants.alphabetically.each do |merchant|
            concat(content_tag(:option, merchant.name, value: merchant.id))
          end
        end
      end
    end

    def render_tags_select(form)
      content_tag(:div, class: "space-y-2") do
        content_tag(:label, "Tags", for: "bulk_update_tag_ids", class: "text-sm font-medium leading-none") +
        content_tag(:select,
          name: "bulk_update[tag_ids][]",
          id: "bulk_update_tag_ids",
          multiple: true,
          class: "flex h-40 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
        ) do
          Current.family.tags.alphabetically.each do |tag|
            concat(content_tag(:option, tag.name, value: tag.id))
          end
        end
      end
    end

    def render_form_actions
      content_tag(:div, class: "flex justify-end gap-2 mt-auto") do
        concat(
          content_tag(:button,
            "Cancel",
            type: "button",
            class: "inline-flex items-center justify-center rounded-md border border-input bg-background px-4 py-2 text-sm font-medium text-foreground shadow-sm hover:bg-accent hover:text-accent-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2",
            data: { action: "click->dialog#close" }
          )
        )
        concat(
          content_tag(:button,
            "Save",
            type: "button",
            class: "inline-flex items-center justify-center rounded-md bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50",
            data: { bulk_select_scope_param: "bulk_update", action: "bulk-select#submitBulkRequest" }
          )
        )
      end
    end
  end
end