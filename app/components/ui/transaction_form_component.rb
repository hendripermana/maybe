# frozen_string_literal: true

module Ui
  # Modern transaction form component with theme-aware styling
  # Provides consistent form styling and validation across light and dark themes
  class TransactionFormComponent < BaseComponent
    attr_reader :entry, :income_categories, :expense_categories, :url, :method

    def initialize(
      entry:,
      income_categories:,
      expense_categories:,
      url: nil,
      method: :post,
      **options
    )
      super(**options)
      @entry = entry
      @income_categories = income_categories
      @expense_categories = expense_categories
      @url = url || (entry.new_record? ? "/transactions" : "/transactions/#{entry.id}")
      @method = method
    end

    def call
      content_tag(:div, class: "transaction-form-container") do
        form_with(
          model: entry,
          url: url,
          method: method,
          class: "space-y-6",
          data: { controller: "transaction-form" }
        ) do |f|
          concat(render_errors(f))
          concat(render_transaction_type(f))
          concat(render_basic_fields(f))
          concat(render_advanced_fields(f))
          concat(render_submit_button(f))
        end
      end
    end

    private

      def render_errors(form)
        return unless entry.errors.any?

        content_tag(:div, class: "rounded-lg border border-destructive bg-destructive/10 p-4") do
          content_tag(:div, class: "font-medium text-destructive") do
            "Please correct the following errors:"
          end +
          content_tag(:ul, class: "mt-2 list-disc pl-5 text-sm text-destructive") do
            entry.errors.full_messages.map do |message|
              content_tag(:li, message)
            end.join.html_safe
          end
        end
      end

      def render_transaction_type(form)
        content_tag(:section) do
          # Hidden fields
          concat(form.hidden_field(:nature, value: params[:nature] || "outflow"))
          concat(form.hidden_field(:entryable_type, value: "Transaction"))

          # Transaction type tabs
          content_tag(:div, class: "flex border-b border-border") do
            [
              { id: "expense", text: "Expense", active: params[:nature] != "inflow", value: "outflow" },
              { id: "income", text: "Income", active: params[:nature] == "inflow", value: "inflow" }
            ].map do |tab|
              content_tag(:button,
                tab[:text],
                type: "button",
                class: class_names(
                  "px-4 py-2 text-sm font-medium transition-colors",
                  "border-b-2 -mb-px",
                  tab[:active] ? "border-primary text-primary" : "border-transparent text-muted-foreground hover:text-foreground"
                ),
                data: {
                  action: "click->transaction-form#changeType",
                  type: tab[:value]
                }
              )
            end.join.html_safe
          end
        end
      end

      def render_basic_fields(form)
        content_tag(:section, class: "space-y-4") do
          # Description field
          concat(
            render(Ui::InputComponent.new(
              type: "text",
              name: "entry[name]",
              id: "entry_name",
              label: "Description",
              placeholder: "Enter transaction description",
              value: entry.name,
              required: true,
              error: entry.errors[:name].first
            ))
          )

          # Account field
          if entry.account_id
            concat(form.hidden_field(:account_id))
          else
            concat(
              render_account_select(form)
            )
          end

          # Amount field
          concat(
            render_amount_field(form)
          )

          # Category field
          concat(
            render_category_field(form)
          )

          # Date field
          concat(
            render(Ui::InputComponent.new(
              type: "date",
              name: "entry[date]",
              id: "entry_date",
              label: "Date",
              value: entry.date || Date.current,
              required: true,
              min: Entry.min_supported_date,
              max: Date.current,
              error: entry.errors[:date].first
            ))
          )
        end
      end

      def render_account_select(form)
        accounts = Current.family.accounts.manual.alphabetically

        content_tag(:div, class: "space-y-2") do
          content_tag(:label, "Account", for: "entry_account_id", class: "text-sm font-medium leading-none") +
          content_tag(:select,
            name: "entry[account_id]",
            id: "entry_account_id",
            required: true,
            class: "flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
          ) do
            concat(content_tag(:option, "Select an account", value: ""))
            accounts.each do |account|
              concat(content_tag(:option, account.name, value: account.id, selected: entry.account_id == account.id))
            end
          end
        end
      end

      def render_amount_field(form)
        content_tag(:div, class: "space-y-2") do
          content_tag(:label, "Amount", for: "entry_amount", class: "text-sm font-medium leading-none") +
          content_tag(:div, class: "relative") do
            content_tag(:span, Current.family.currency_symbol, class: "absolute left-3 top-1/2 -translate-y-1/2 text-muted-foreground") +
            content_tag(:input,
              nil,
              type: "number",
              name: "entry[amount]",
              id: "entry_amount",
              value: entry.amount.to_s,
              step: "0.01",
              required: true,
              class: "flex h-10 w-full rounded-md border border-input bg-background pl-8 pr-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
            )
          end
        end
      end

      def render_category_field(form)
        categories = params[:nature] == "inflow" ? income_categories : expense_categories

        content_tag(:div, class: "space-y-2") do
          content_tag(:label, "Category", for: "entry_entryable_attributes_category_id", class: "text-sm font-medium leading-none") +
          content_tag(:select,
            name: "entry[entryable_attributes][category_id]",
            id: "entry_entryable_attributes_category_id",
            class: "flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50",
            data: { "transaction-form-target": "categorySelect" }
          ) do
            concat(content_tag(:option, "Select a category", value: ""))
            categories.each do |category|
              selected = entry.entryable.try(:category_id) == category.id
              concat(content_tag(:option, category.name, value: category.id, selected: selected))
            end
          end
        end
      end

      def render_advanced_fields(form)
        content_tag(:div, class: "border border-border rounded-lg") do
          content_tag(:div, class: "flex items-center justify-between p-4 cursor-pointer", data: { action: "click->transaction-form#toggleAdvanced" }) do
            content_tag(:h3, "Additional Details", class: "text-sm font-medium") +
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
                class: "chevron-down",
                data: { "transaction-form-target": "chevron" }
              ) do
                tag(:polyline, points: "6 9 12 15 18 9")
              end
            end
          end +
          content_tag(:div, class: "p-4 border-t border-border hidden", data: { "transaction-form-target": "advancedFields" }) do
            content_tag(:div, class: "space-y-4") do
              # Tags field
              concat(
                render_tags_field(form)
              )

              # Notes field
              concat(
                render(Ui::InputComponent.new(
                  type: "textarea",
                  name: "entry[notes]",
                  id: "entry_notes",
                  label: "Notes",
                  placeholder: "Add notes about this transaction",
                  value: entry.notes,
                  rows: 5,
                  error: entry.errors[:notes].first
                ))
              )
            end
          end
        end
      end

      def render_tags_field(form)
        tags = Current.family.tags.alphabetically

        content_tag(:div, class: "space-y-2") do
          content_tag(:label, "Tags", for: "entry_entryable_attributes_tag_ids", class: "text-sm font-medium leading-none") +
          content_tag(:select,
            name: "entry[entryable_attributes][tag_ids][]",
            id: "entry_entryable_attributes_tag_ids",
            multiple: true,
            class: "flex h-40 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
          ) do
            tags.each do |tag|
              selected = entry.entryable.try(:tag_ids)&.include?(tag.id)
              concat(content_tag(:option, tag.name, value: tag.id, selected: selected))
            end
          end
        end
      end

      def render_submit_button(form)
        content_tag(:div, class: "flex justify-end") do
          content_tag(:button,
            entry.new_record? ? "Create Transaction" : "Update Transaction",
            type: "submit",
            class: "inline-flex items-center justify-center rounded-md bg-primary px-4 py-2 text-sm font-medium text-primary-foreground hover:bg-primary/90 focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50"
          )
        end
      end
  end
end
