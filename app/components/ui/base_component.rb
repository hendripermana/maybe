# frozen_string_literal: true

module Ui
  # Base component for all UI components
  # Provides common functionality for all UI components
  class BaseComponent < ViewComponent::Base
    attr_reader :variant, :size, :options

    def initialize(variant: :default, size: :md, **options)
      @variant = variant.to_sym
      @size = size.to_sym
      @options = options
    end

    def build_classes(*classes)
      class_names(
        *classes,
        @options[:class]
      )
    end

    def build_data_attributes
      @options[:data] || {}
    end

    def build_options
      @options
    end

    def class_names(*args)
      classes = []
      
      args.each do |arg|
        case arg
        when String
          classes << arg unless arg.blank?
        when Symbol
          classes << arg.to_s unless arg.blank?
        when Hash
          arg.each do |key, val|
            classes << key.to_s if val && !key.blank?
          end
        when Array
          classes.concat(class_names(*arg).split(" "))
        end
      end
      
      classes.uniq.join(" ")
    end
  end
end