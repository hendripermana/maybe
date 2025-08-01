# frozen_string_literal: true

module Ui
  # Preview for the Alert component
  class AlertComponentPreview < ViewComponent::Preview
    # @!group Variants

    # @label Default
    def default
      render(Ui::AlertComponent.new) do
        "This is a default alert"
      end
    end

    # @label Info
    def info
      render(Ui::AlertComponent.new(variant: :info)) do
        "This is an info alert"
      end
    end

    # @label Success
    def success
      render(Ui::AlertComponent.new(variant: :success)) do
        "This is a success alert"
      end
    end

    # @label Warning
    def warning
      render(Ui::AlertComponent.new(variant: :warning)) do
        "This is a warning alert"
      end
    end

    # @label Destructive
    def destructive
      render(Ui::AlertComponent.new(variant: :destructive)) do
        "This is a destructive alert"
      end
    end

    # @!endgroup

    # @!group Sizes

    # @label Small
    def small
      render(Ui::AlertComponent.new(size: :sm)) do
        "This is a small alert"
      end
    end

    # @label Medium (Default)
    def medium
      render(Ui::AlertComponent.new(size: :md)) do
        "This is a medium alert"
      end
    end

    # @label Large
    def large
      render(Ui::AlertComponent.new(size: :lg)) do
        "This is a large alert"
      end
    end

    # @!endgroup

    # @!group Features

    # @label With Title
    def with_title
      render(Ui::AlertComponent.new(title: "Alert Title")) do
        "This is an alert with a title"
      end
    end

    # @label Dismissible
    def dismissible
      render(Ui::AlertComponent.new(dismissible: true)) do
        "This is a dismissible alert"
      end
    end

    # @!endgroup
  end
end
