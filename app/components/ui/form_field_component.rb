# frozen_string_literal: true

module Ui
  # Modern form field component for text inputs, selects, etc.
  # Provides consistent styling and accessibility for form fields
  class FormFieldComponent < BaseComponent
    renders_one :hint
    renders_one :error
    renders_one :actions

    attr_reader :form, :field, :label, :required, :tooltip

    def initialize(form:, field:, label: nil, required: false, tooltip: nil, **options)
      super(**options)
      @form = form
      @field = field
      @label = label || field.to_s.humanize
      @required = required
      @tooltip = tooltip
    end

    def field_id
      "#{form.object_name}_#{field}"
    end

    def has_error?
      form.object&.errors&.include?(field)
    end

    def error_message
      form.object.errors[field].first if has_error?
    end

    def label_text
      if required
        safe_join([
          label,
          tag.span("*", class: "text-destructive ml-0.5")
        ])
      else
        label
      end
    end
  end
end