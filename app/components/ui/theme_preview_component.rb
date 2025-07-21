module Ui
  # Theme preview component that shows a visual representation of a theme
  # Used to provide visual feedback when selecting themes
  class ThemePreviewComponent < ViewComponent::Base
    attr_reader :theme

    def initialize(theme:)
      @theme = theme
    end
  end
end