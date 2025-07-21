# frozen_string_literal: true

module Ui
  # Modern form feedback component for showing success/error messages
  # Provides consistent styling for form feedback messages
  class FormFeedbackComponent < BaseComponent
    VARIANTS = {
      success: "bg-success-light text-success border-success",
      error: "bg-destructive-light text-destructive border-destructive",
      info: "bg-info-light text-info border-info",
      warning: "bg-warning-light text-warning border-warning"
    }.freeze

    attr_reader :message, :icon, :dismissible

    def initialize(message:, variant: :info, icon: nil, dismissible: false, **options)
      super(variant: variant, **options)
      @message = message
      @icon = icon || default_icon
      @dismissible = dismissible
    end

    private

    def default_icon
      case @variant
      when :success
        "check-circle"
      when :error
        "alert-circle"
      when :info
        "info"
      when :warning
        "alert-triangle"
      else
        "info"
      end
    end

    def feedback_classes
      build_classes(
        "form-feedback flex items-center gap-2 p-3 rounded-md text-sm border",
        "animate-fadeIn",
        VARIANTS[@variant] || VARIANTS[:info]
      )
    end
  end
end