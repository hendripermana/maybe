module Ui
  class SkipToContentComponent < ViewComponent::Base
    def initialize(target: "#main", text: "Skip to content")
      @target = target
      @text = text
    end
  end
end
