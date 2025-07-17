# frozen_string_literal: true

module Ui
  # Shadcn-inspired Input component using CSS variables for theme consistency
  # Provides consistent form input styling across light and dark themes
  class InputComponent < BaseComponent
    VARIANTS = {
      default: "input-modern",
      outline: "border border-input bg-background",
      ghost: "border-0 bg-transparent",
      filled: "bg-muted border-0"
    }.freeze

    SIZES = {
      sm: "h-8 px-3 py-1 text-xs",
      md: "h-10 px-3 py-2 text-sm",
      lg: "h-12 px-4 py-3 text-base",
      xl: "h-14 px-5 py-4 text-lg"
    }.freeze

    attr_reader :type, :placeholder, :value, :name, :id, :required, :disabled, :readonly, :label, :error, :help_text

    def initialize(
      type: "text",
      placeholder: nil,
      value: nil,
      name: nil,
      id: nil,
      required: false,
      disabled: false,
      readonly: false,
      label: nil,
      error: nil,
      help_text: nil,
      variant: :default,
      size: :md,
      **options
    )
      super(variant: variant, size: size, **options)
      @type = type
      @placeholder = placeholder
      @value = value
      @name = name
      @id = id || name
      @required = required
      @disabled = disabled
      @readonly = readonly
      @label = label
      @error = error
      @help_text = help_text
    end

    def call
      content_tag(:div, class: "space-y-2") do
        concat(render_label) if @label.present?
        concat(render_input)
        concat(render_help_text) if @help_text.present?
        concat(render_error) if @error.present?
      end
    end

    private

    def render_label
      content_tag(:label, @label, 
        for: @id,
        class: "text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70"
      )
    end

    def render_input
      if @type == "textarea"
        content_tag(:textarea, @value, **textarea_attributes)
      elsif @type == "select"
        content_tag(:select, **select_attributes) do
          content
        end
      else
        tag(:input, **input_attributes)
      end
    end

    def render_help_text
      content_tag(:p, @help_text, class: "text-sm text-muted-foreground")
    end

    def render_error
      content_tag(:p, @error, class: "text-sm font-medium text-destructive")
    end

    def input_attributes
      {
        type: @type,
        placeholder: @placeholder,
        value: @value,
        name: @name,
        id: @id,
        required: @required,
        disabled: @disabled,
        readonly: @readonly,
        class: input_classes,
        data: build_data_attributes,
        **build_options.except(:class, :data, :type, :placeholder, :value, :name, :id, :required, :disabled, :readonly)
      }.compact
    end

    def textarea_attributes
      {
        placeholder: @placeholder,
        name: @name,
        id: @id,
        required: @required,
        disabled: @disabled,
        readonly: @readonly,
        class: input_classes,
        data: build_data_attributes,
        **build_options.except(:class, :data, :placeholder, :name, :id, :required, :disabled, :readonly)
      }.compact
    end

    def select_attributes
      {
        name: @name,
        id: @id,
        required: @required,
        disabled: @disabled,
        class: input_classes,
        data: build_data_attributes,
        **build_options.except(:class, :data, :name, :id, :required, :disabled)
      }.compact
    end

    def input_classes
      base_classes = [
        "flex w-full rounded-md border border-input bg-background px-3 py-2 text-sm",
        "ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium",
        "placeholder:text-muted-foreground",
        "focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2",
        "disabled:cursor-not-allowed disabled:opacity-50"
      ]

      base_classes << "text-destructive border-destructive focus-visible:ring-destructive" if @error.present?

      build_classes(
        *base_classes,
        variant_classes,
        size_classes
      )
    end

    def variant_classes
      VARIANTS[@variant] || VARIANTS[:default]
    end

    def size_classes
      SIZES[@size] || SIZES[:md]
    end
  end
end