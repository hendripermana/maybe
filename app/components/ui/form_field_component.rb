# frozen_string_literal: true

module Ui
  # Modern form field component for text inputs, selects, etc.
  # Provides consistent styling and accessibility for form fields
  class FormFieldComponent < BaseComponent
    renders_one :hint
    renders_one :error
    renders_one :actions

    attr_reader :form, :field, :label, :required, :tooltip, :help_text

    def initialize(form:, field:, label: nil, required: false, tooltip: nil, help_text: nil, **options)
      super(**options)
      @form = form
      @field = field
      @label = label || field.to_s.humanize
      @required = required
      @tooltip = tooltip
      @help_text = help_text
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
    
    def field_classes
      build_classes(
        "form-field space-y-2",
        "form-field-error" => has_error?
      )
    end
    
    def label_classes
      build_classes(
        "form-field-label text-sm font-medium text-primary",
        "text-destructive" => has_error?
      )
    end
  end
end