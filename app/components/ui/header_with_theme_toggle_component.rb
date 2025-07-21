module Ui
  # Header component with theme toggle button
  # Can be used in any page that needs a header with theme switching functionality
  class HeaderWithThemeToggleComponent < ViewComponent::Base
    attr_reader :title, :subtitle, :back_url

    def initialize(title:, subtitle: nil, back_url: nil)
      @title = title
      @subtitle = subtitle
      @back_url = back_url
    end
  end
end