# frozen_string_literal: true

module Ui
  # Modern form feedback component for showing success/error messages
  # Provides consistent styling for form feedback messages
  class FormFeedbackComponent < BaseComponent
    VARIANTS = {
      success: "bg-success-light text-success",
      error: "bg-destructive-light text-destructive",
      info: "bg-info-light text-info",
      warning: "bg-warning-light text-warning"
    }.freeze

    attr_reader :message, :icon

    def initialize(message:, variant: :info, icon: nil, **options)
      super(variant: variant, **options)
      @message = message
      @icon = icon || default_icon
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
        "form-feedback flex items-center gap-2 p-3 rounded-md text-sm",
        VARIANTS[@variant] || VARIANTS[:info]
      )
    end
  end
end