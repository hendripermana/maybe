# frozen_string_literal: true

module Ui
  # Modern toggle switch component for boolean inputs
  # Provides consistent styling and accessibility for toggle switches
  class ToggleSwitchComponent < BaseComponent
    attr_reader :form, :field, :checked_value, :unchecked_value, :disabled

    def initialize(
      form:, 
      field:, 
      checked_value: "1", 
      unchecked_value: "0", 
      disabled: false,
      **options
    )
      super(**options)
      @form = form
      @field = field
      @checked_value = checked_value
      @unchecked_value = unchecked_value
      @disabled = disabled
    end

    def field_id
      "#{form.object_name}_#{field}"
    end

    def checked?
      value = form.object.send(field) if form.object.respond_to?(field)
      ActiveModel::Type::Boolean.new.cast(value)
    end

    def toggle_classes
      build_classes(
        "relative inline-flex h-6 w-11 items-center rounded-full transition-colors",
        "focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2",
        "disabled:cursor-not-allowed disabled:opacity-50",
        checked? ? "bg-primary" : "bg-input"
      )
    end

    def toggle_switch_classes
      build_classes(
        "pointer-events-none inline-block h-5 w-5 transform rounded-full bg-background shadow-lg ring-0 transition-transform",
        checked? ? "translate-x-5" : "translate-x-0"
      )
    end
  end
end