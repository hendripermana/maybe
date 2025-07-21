# frozen_string_literal: true

module Ui
  # Modern textarea component for multiline text input
  # Provides consistent styling and accessibility for textarea fields
  class TextareaComponent < BaseComponent
    attr_reader :form, :field, :placeholder, :rows, :disabled, :readonly, :required, 
                :autocomplete, :description, :max_length, :counter

    def initialize(
      form:, 
      field:, 
      placeholder: nil, 
      rows: 3,
      disabled: false, 
      readonly: false, 
      required: false,
      autocomplete: nil,
      description: nil,
      max_length: nil,
      counter: false,
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
      @description = description
      @max_length = max_length
      @counter = counter || max_length.present?
    end

    def textarea_options
      {
        class: textarea_classes,
        id: field_id,
        placeholder: @placeholder,
        rows: @rows,
        disabled: @disabled,
        readonly: @readonly,
        required: @required,
        autocomplete: @autocomplete,
        maxlength: @max_length,
        aria: { 
          invalid: has_error? ? "true" : "false",
          describedby: description_id
        },
        data: counter ? { controller: "character-counter", character_counter_target: "input" } : {},
        **@options.except(:class)
      }.compact
    end

    def textarea_classes
      build_classes(
        "form-textarea w-full rounded-md border border-input bg-background px-3 py-2",
        "text-sm text-primary placeholder:text-muted",
        "focus:outline-none focus:ring-2 focus:ring-ring focus:border-input",
        "disabled:cursor-not-allowed disabled:opacity-50",
        "transition-colors duration-200",
        has_error? ? "border-destructive focus:ring-destructive" : nil
      )
    end

    def has_error?
      form.object&.errors&.include?(field)
    end
    
    def field_id
      "#{form.object_name}_#{field}"
    end
    
    def description_id
      parts = []
      parts << "#{field_id}_description" if description
      parts << "#{field_id}_counter" if counter
      parts.join(" ") if parts.any?
    end
  end
end