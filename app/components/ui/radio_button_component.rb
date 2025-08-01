# frozen_string_literal: true

module Ui
  # Modern radio button component
  # Provides consistent styling and accessibility for radio button inputs
  class RadioButtonComponent < BaseComponent
    attr_reader :form, :field, :value, :label_text, :checked, :disabled, :required, :description

    def initialize(
      form:,
      field:,
      value:,
      label_text: nil,
      checked: false,
      disabled: false,
      required: false,
      description: nil,
      **options
    )
      super(**options)
      @form = form
      @field = field
      @value = value
      @label_text = label_text || value.to_s.humanize
      @checked = checked
      @disabled = disabled
      @required = required
      @description = description
    end

    def field_id
      "#{form.object_name}_#{field}_#{value}"
    end

    def radio_options
      {
        class: radio_classes,
        id: field_id,
        disabled: @disabled,
        required: @required,
        checked: @checked,
        aria: {
          describedby: description ? "#{field_id}_description" : nil
        },
        **@options.except(:class)
      }.compact
    end

    def radio_classes
      build_classes(
        "form-radio h-4 w-4 border-input bg-background",
        "text-primary focus:ring-2 focus:ring-ring focus:ring-offset-2",
        "disabled:cursor-not-allowed disabled:opacity-50",
        "transition-colors duration-200"
      )
    end

    def label_classes
      build_classes(
        "ml-2 text-sm font-medium text-primary",
        "disabled:cursor-not-allowed disabled:opacity-50" => @disabled
      )
    end

    def container_classes
      build_classes(
        "flex items-start",
        "opacity-50 cursor-not-allowed" => @disabled
      )
    end
  end
end
