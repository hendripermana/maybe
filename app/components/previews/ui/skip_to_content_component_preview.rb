module Ui
  class SkipToContentComponentPreview < ViewComponent::Preview
    # @!group Accessibility

    # @label Default
    # @description The default skip to content link that becomes visible when focused
    def default
      render(Ui::SkipToContentComponent.new)
    end

    # @label With Custom Target
    # @description Skip to content link with a custom target
    def with_custom_target
      render(Ui::SkipToContentComponent.new(target: "#dashboard"))
    end

    # @label With Custom Text
    # @description Skip to content link with custom text
    def with_custom_text
      render(Ui::SkipToContentComponent.new(text: "Skip to main content"))
    end

    # @!endgroup
  end
end
