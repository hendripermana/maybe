module Ui
  # Compact theme toggle component for switching between light and dark themes
  # Can be used in headers, navigation bars, or other compact UI areas
  class ThemeToggleComponent < ViewComponent::Base
    attr_reader :size, :with_label

    def initialize(size: :md, with_label: false)
      @size = size
      @with_label = with_label
    end

    private

    def toggle_classes
      base_classes = "theme-toggle relative rounded-full transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2"
      
      size_classes = case size
      when :sm
        "w-8 h-4"
      when :md
        "w-10 h-5"
      when :lg
        "w-12 h-6"
      else
        "w-10 h-5"
      end
      
      "#{base_classes} #{size_classes}"
    end

    def container_classes
      "inline-flex items-center gap-2"
    end
  end
end