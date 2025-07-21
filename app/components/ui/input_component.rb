# frozen_string_literal: true

module Ui
  # Modern input component for text fields, email inputs, etc.
  # Provides consistent styling and accessibility for input fields
  class InputComponent < BaseComponent
    TYPES = %i[text email password number tel url search date time datetime-local month week].freeze
    
    attr_reader :form, :field, :type, :placeholder, :value, :disabled, :readonly, :required, 
                :autocomplete, :min, :max, :step, :prefix, :suffix, :description

    def initialize(
      form:, 
      field:, 
      type: :text, 
      placeholder: nil, 
      value: nil, 
      disabled: false, 
      readonly: false, 
      required: false,
      autocomplete: nil,
      min: nil,
      max: nil,
      step: nil,
      prefix: nil,
      suffix: nil,
      description: nil,
      **options
    )
      super(**options)
      @form = form
      @field = field
      @type = type.to_sym
      @placeholder = placeholder
      @value = value
      @disabled = disabled
      @readonly = readonly
      @required = required
      @autocomplete = autocomplete
      @min = min
      @max = max
      @step = step
      @prefix = prefix
      @suffix = suffix
      @description = description
      
      raise ArgumentError, "Invalid input type: #{type}" unless TYPES.include?(@type)
    end

    def input_options
      {
        class: input_classes,
        placeholder: @placeholder,
        disabled: @disabled,
        readonly: @readonly,
        required: @required,
        autocomplete: @autocomplete,
        min: @min,
        max: @max,
        step: @step,
        value: @value,
        aria: { 
          invalid: has_error? ? "true" : "false",
          describedby: description ? "#{field_id}_description" : nil
        },
        **@options.except(:class)
      }.compact
    end

    def input_classes
      build_classes(
        "form-input w-full rounded-md border border-input bg-background px-3 py-2",
        "text-sm text-primary placeholder:text-muted",
        "focus:outline-none focus:ring-2 focus:ring-ring focus:border-input",
        "disabled:cursor-not-allowed disabled:opacity-50",
        "transition-colors duration-200",
        has_error? ? "border-destructive focus:ring-destructive" : nil,
        prefix ? "rounded-l-none" : nil,
        suffix ? "rounded-r-none" : nil
      )
    end

    def has_error?
      form.object&.errors&.include?(field)
    end
    
    def field_id
      "#{form.object_name}_#{field}"
    end
    
    def has_addon?
      prefix.present? || suffix.present?
    end
  end
end