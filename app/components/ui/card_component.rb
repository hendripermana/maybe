# frozen_string_literal: true

module Ui
  # Shadcn-inspired Card component using CSS variables for theme consistency
  # Provides flexible card layouts with consistent styling across themes
  class CardComponent < BaseComponent
    renders_one :header
    renders_one :footer

    VARIANTS = {
      default: "card-modern",
      elevated: "card-modern shadow-floating hover:shadow-modal",
      outlined: "bg-card text-card-foreground border border-border",
      ghost: "bg-transparent border-0 shadow-none",
      interactive: "card-modern hover:shadow-floating cursor-pointer"
    }.freeze

    SIZES = {
      sm: "p-4",
      md: "p-6", 
      lg: "p-8",
      xl: "p-10"
    }.freeze

    attr_reader :title, :subtitle, :description, :href, :target, :frame

    def initialize(
      variant: :default, 
      size: :md, 
      title: nil,
      subtitle: nil,
      description: nil,
      href: nil,
      target: nil,
      frame: nil,
      **options
    )
      super(variant: variant, size: size, **options)
      @title = title
      @subtitle = subtitle
      @description = description
      @href = href
      @target = target
      @frame = frame
    end

    private

    def wrapper_tag
      @href ? :a : :div
    end

    def wrapper_options
      base_options = {
        class: card_classes,
        data: build_data_attributes
      }.merge(build_options.except(:class, :data))

      if @href
        base_options.merge!(
          href: @href,
          target: @target
        )
        
        if @frame
          base_options[:data] = base_options[:data].merge(turbo_frame: @frame)
        end
      end

      base_options
    end

    def card_classes
      build_classes(
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

    def has_header?
      @title.present? || @subtitle.present? || header?
    end

    def has_content?
      @description.present? || content.present?
    end

    def has_footer?
      footer
    end

    def title_classes
      "text-2xl font-semibold leading-none tracking-tight"
    end

    def subtitle_classes
      "text-sm text-muted-foreground"
    end

    def description_classes
      "text-sm text-muted-foreground"
    end
  end
end