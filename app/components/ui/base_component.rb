# frozen_string_literal: true

module Ui
  # Base class for all Shadcn-inspired UI components
  # Provides common functionality and consistent styling patterns using CSS variables
  class BaseComponent < ViewComponent::Base
    # Common size variants following Shadcn patterns
    SIZES = {
      sm: "sm",
      md: "md", 
      lg: "lg",
      xl: "xl"
    }.freeze

    # Common variant types following Shadcn patterns
    VARIANTS = {
      default: "default",
      primary: "primary",
      secondary: "secondary",
      destructive: "destructive",
      outline: "outline",
      ghost: "ghost",
      muted: "muted"
    }.freeze

    attr_reader :size, :variant, :class_name, :data_attributes, :options

    def initialize(size: :md, variant: :default, class: nil, data: {}, **options)
      @size = size.to_sym
      @variant = variant.to_sym
      @class_name = binding.local_variable_get(:class) # Handle 'class' keyword
      @data_attributes = data || {}
      @options = options || {}
    end

    protected

    # Build CSS classes with proper precedence
    def build_classes(*base_classes)
      class_names(
        *base_classes.compact,
        size_classes,
        variant_classes,
        @class_name
      )
    end

    # Override in subclasses to provide size-specific styling
    def size_classes
      case @size
      when :sm then "text-sm"
      when :md then "text-sm"
      when :lg then "text-base"
      when :xl then "text-lg"
      else "text-sm"
      end
    end

    # Override in subclasses to provide variant-specific styling
    def variant_classes
      ""
    end

    # Build data attributes hash
    def build_data_attributes(additional_data = {})
      (@data_attributes || {}).merge(additional_data || {})
    end

    # Merge additional options with component options
    def build_options(additional_options = {})
      (@options || {}).merge(additional_options || {})
    end

    # Helper method to check if component should be disabled
    def disabled?
      @options[:disabled] == true
    end

    # Helper method to get theme-aware classes
    def theme_classes(light_class, dark_class = nil)
      if dark_class
        "#{light_class} [data-theme=dark]:#{dark_class}"
      else
        light_class
      end
    end
  end
end