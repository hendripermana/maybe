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

    # Provide object method for form field components
    def object
      @model
    end

    def object_name
      @model&.model_name&.param_key || @model&.class&.name&.underscore
    end

    # Store the content block to be called with form builder
    def content_block
      @content_block
    end

    def content_block=(block)
      @content_block = block
    end
  end
end
