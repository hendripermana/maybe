# frozen_string_literal: true

module Ui
  # Modern select component for dropdown menus
  # Provides consistent styling and accessibility for select fields
  class SelectComponent < BaseComponent
    attr_reader :form, :field, :collection, :value_method, :text_method, :options, :include_blank, :prompt, :disabled, :required

    def initialize(
      form:, 
      field:, 
      collection: nil,
      value_method: :id,
      text_method: :name,
      options: nil,
      include_blank: false,
      prompt: nil,
      disabled: false,
      required: false,
      **html_options
    )
      super(**html_options)
      @form = form
      @field = field
      @collection = collection
      @value_method = value_method
      @text_method = text_method
      @options = options
      @include_blank = include_blank
      @prompt = prompt
      @disabled = disabled
      @required = required
    end

    def select_options
      {
        include_blank: @include_blank,
        prompt: @prompt,
        disabled: @disabled,
        required: @required
      }.compact
    end

    def select_html_options
      {
        class: select_classes,
        **@options.except(:class)
      }.compact
    end

    def select_classes
      build_classes(
        "form-select w-full rounded-md border border-input bg-background px-3 py-2 pr-8",
        "text-sm text-primary",
        "focus:outline-none focus:ring-2 focus:ring-ring focus:border-input",
        "disabled:cursor-not-allowed disabled:opacity-50",
        has_error? ? "border-destructive focus:ring-destructive" : nil
      )
    end

    def has_error?
      form.object&.errors&.include?(field)
    end

    def collection_select?
      @collection.present?
    end
  end
end