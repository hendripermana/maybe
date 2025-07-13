# frozen_string_literal: true

# Dashboard Balance Sheet Component with modern ShadCN styling
class Dashboard::BalanceSheetComponent < ViewComponent::Base
  def initialize(balance_sheet:, **html_options)
    @balance_sheet = balance_sheet
    @html_options = html_options
  end

  private

    attr_reader :balance_sheet

    def css_classes
      classes = [
        "space-y-6"
      ]
      classes << @html_options[:class] if @html_options[:class]
      classes.compact.join(" ")
    end

    def html_options
      @html_options.except(:class).merge(class: css_classes)
    end

    def render_balance_sheet_content
      helpers.render(partial: "pages/dashboard/balance_sheet", locals: { balance_sheet: balance_sheet })
    end
end
