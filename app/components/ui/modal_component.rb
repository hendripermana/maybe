# frozen_string_literal: true

module Ui
  # Shadcn-inspired Modal/Dialog component using CSS variables for theme consistency
  # Provides accessible modal dialogs with consistent styling across themes
  class ModalComponent < BaseComponent
    VARIANTS = {
      default: "modal-modern",
      centered: "modal-modern",
      fullscreen: "w-full h-full max-w-none max-h-none m-0 rounded-none"
    }.freeze

    SIZES = {
      sm: "max-w-md",
      md: "max-w-lg",
      lg: "max-w-2xl",
      xl: "max-w-4xl",
      full: "max-w-7xl"
    }.freeze

    attr_reader :title, :description, :open, :closable, :backdrop_closable

    def initialize(
      title: nil,
      description: nil,
      open: false,
      closable: true,
      backdrop_closable: true,
      variant: :default,
      size: :md,
      **options
    )
      super(variant: variant, size: size, **options)
      @title = title
      @description = description
      @open = open
      @closable = closable
      @backdrop_closable = backdrop_closable
    end

    def call
      content_tag(:div, **overlay_attributes) do
        content_tag(:div, **modal_attributes) do
          concat(render_header) if has_header?
          concat(render_content)
          concat(render_footer) if has_footer?
        end
      end
    end

    private

      def overlay_attributes
        {
          class: overlay_classes,
          data: build_data_attributes({
            modal_target: "overlay",
            action: @backdrop_closable ? "click->modal#closeOnBackdrop" : nil
          }.compact),
          style: (@open ? "display: flex;" : "display: none;")
        }
      end

      def modal_attributes
        {
          class: modal_classes,
          data: { modal_target: "dialog" },
          role: "dialog",
          "aria-modal": "true",
          "aria-labelledby": (@title.present? ? "modal-title" : nil),
          "aria-describedby": (@description.present? ? "modal-description" : nil),
          **build_options.except(:class, :data)
        }.compact
      end

      def overlay_classes
        [
          "fixed inset-0 z-50 flex items-center justify-center",
          "bg-background/80 backdrop-blur-sm",
          "data-[state=open]:animate-in data-[state=closed]:animate-out",
          "data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0"
        ].join(" ")
      end

      def modal_classes
        base_classes = [
          "relative w-full max-h-[85vh] overflow-auto",
          "bg-background border border-border rounded-lg shadow-lg",
          "data-[state=open]:animate-in data-[state=closed]:animate-out",
          "data-[state=closed]:fade-out-0 data-[state=open]:fade-in-0",
          "data-[state=closed]:zoom-out-95 data-[state=open]:zoom-in-95",
          "data-[state=closed]:slide-out-to-left-1/2 data-[state=closed]:slide-out-to-top-[48%]",
          "data-[state=open]:slide-in-from-left-1/2 data-[state=open]:slide-in-from-top-[48%]"
        ]

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

      def has_header?
        @title.present? || @description.present? || content_for?(:header)
      end

      def has_footer?
        content_for?(:footer)
      end

      def render_header
        content_tag(:div, class: "flex flex-col space-y-1.5 text-center sm:text-left p-6") do
          if content_for?(:header)
            content_for(:header)
          else
            concat(render_title) if @title.present?
            concat(render_description) if @description.present?
          end
          concat(render_close_button) if @closable
        end
      end

      def render_title
        content_tag(:h2, @title,
          id: "modal-title",
          class: "text-lg font-semibold leading-none tracking-tight"
        )
      end

      def render_description
        content_tag(:p, @description,
          id: "modal-description",
          class: "text-sm text-muted-foreground"
        )
      end

      def render_close_button
        content_tag(:button,
          class: "absolute right-4 top-4 rounded-sm opacity-70 ring-offset-background transition-opacity hover:opacity-100 focus:outline-none focus:ring-2 focus:ring-ring focus:ring-offset-2 disabled:pointer-events-none",
          data: { action: "modal#close" },
          type: "button"
        ) do
          content_tag(:svg,
            class: "h-4 w-4",
            xmlns: "http://www.w3.org/2000/svg",
            width: "24",
            height: "24",
            viewBox: "0 0 24 24",
            fill: "none",
            stroke: "currentColor",
            "stroke-width": "2",
            "stroke-linecap": "round",
            "stroke-linejoin": "round"
          ) do
            concat(content_tag(:path, nil, d: "m18 6-12 12"))
            concat(content_tag(:path, nil, d: "m6 6 12 12"))
          end
        end
      end

      def render_content
        content_tag(:div, class: "p-6 pt-0") do
          content
        end
      end

      def render_footer
        content_tag(:div, class: "flex flex-col-reverse sm:flex-row sm:justify-end sm:space-x-2 p-6 pt-0") do
          content_for(:footer)
        end
      end
  end
end
