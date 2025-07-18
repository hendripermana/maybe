# frozen_string_literal: true

module Ui
  # Modern textarea component for multiline text input
  # Provides consistent styling and accessibility for textarea fields
  class TextareaComponent < BaseComponent
    attr_reader :form, :field, :placeholder, :rows, :disabled, :readonly, :required, :autocomplete

    def initialize(
      form:, 
      field:, 
      placeholder: nil, 
      rows: 3,
      disabled: false, 
      readonly: false, 
      required: false,
      autocomplete: nil,
      **options
    )
      super(**options)
      @form = form
      @field = field
      @placeholder = placeholder
      @rows = rows
      @disabled = disabled
      @readonly = readonly
      @required = required
      @autocomplete = autocomplete
    end

    def textarea_options
      {
        class: textarea_classes,
        placeholder: @placeholder,
        rows: @rows,
        disabled: @disabled,
        readonly: @readonly,
        required: @required,
        autocomplete: @autocomplete,
        **@options.except(:class)
      }.compact
    end

    def textarea_classes
      build_classes(
        "form-textarea w-full rounded-md border border-input bg-background px-3 py-2",
        "text-sm text-primary placeholder:text-muted",
        "focus:outline-none focus:ring-2 focus:ring-ring focus:border-input",
        "disabled:cursor-not-allowed disabled:opacity-50",
        has_error? ? "border-destructive focus:ring-destructive" : nil
      )
    end

    def has_error?
      form.object&.errors&.include?(field)
    end
  end
end