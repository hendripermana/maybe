# frozen_string_literal: true

module Ui
  # Modern radio group component
  # Provides consistent styling and accessibility for groups of radio buttons
  class RadioGroupComponent < BaseComponent
    renders_many :radio_buttons, "RadioButtonSlot"
    
    attr_reader :form, :field, :legend, :required, :orientation

    def initialize(
      form:, 
      field:,
      legend: nil,
      required: false,
      orientation: :vertical,
      **options
    )
      super(**options)
      @form = form
      @field = field
      @legend = legend || field.to_s.humanize
      @required = required
      @orientation = orientation.to_sym
    end

    def legend_text
      if required
        safe_join([
          legend,
          tag.span("*", class: "text-destructive ml-0.5")
        ])
      else
        legend
      end
    end

    def group_classes
      build_classes(
        "space-y-2" => orientation == :vertical,
        "flex flex-wrap gap-4" => orientation == :horizontal
      )
    end

    class RadioButtonSlot < ViewComponent::Slot
      attr_reader :value, :label, :checked, :disabled

      def initialize(value:, label: nil, checked: false, disabled: false)
        @value = value
        @label = label || value.to_s.humanize
        @checked = checked
        @disabled = disabled
      end
    end
  end
end