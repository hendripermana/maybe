# frozen_string_literal: true

module Ui
  # Modern form component that replaces the styled_form_builder
  # Provides consistent styling and accessibility for form elements
  class FormComponent < BaseComponent
    renders_one :actions

    attr_reader :model, :url, :method, :html_options

    def initialize(model: nil, url: nil, method: :post, **options)
      super(**options)
      @model = model
      @url = url
      @method = method
      @html_options = options.except(:class)
    end

    def form_options
      {
        model: @model,
        url: @url,
        method: @method,
        class: build_classes("space-y-6"),
        **@html_options
      }.compact
    end

    def auto_submit?
      @html_options[:data]&.key?(:controller) && 
      @html_options[:data][:controller].to_s.include?("auto-submit-form")
    end
  end
end