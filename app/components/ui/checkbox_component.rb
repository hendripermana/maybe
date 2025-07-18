# frozen_string_literal: true

module Ui
  # Modern checkbox component
  # Provides consistent styling and accessibility for checkbox inputs
  class CheckboxComponent < BaseComponent
    attr_reader :form, :field, :label_text, :checked, :disabled, :required

    def initialize(
      form:, 
      field:, 
      label_text: nil,
      checked: false,
      disabled: false,
      required: false,
      **options
    )
      super(**options)
      @form = form
      @field = field
      @label_text = label_text || field.to_s.humanize
      @checked = checked
      @disabled = disabled
      @required = required
    end

    def field_id
      "#{form.object_name}_#{field}"
    end

    def checkbox_options
      {
        class: checkbox_classes,
        disabled: @disabled,
        required: @required,
        **@options.except(:class)
      }.compact
    end

    def checkbox_classes
      build_classes(
        "form-checkbox h-4 w-4 rounded border-input bg-background",
        "text-primary focus:ring-2 focus:ring-ring focus:ring-offset-2",
        "disabled:cursor-not-allowed disabled:opacity-50"
      )
    end

    def label_classes
      build_classes(
        "ml-2 text-sm font-medium text-primary",
        "disabled:cursor-not-allowed disabled:opacity-50" => @disabled
      )
    end
  end
end