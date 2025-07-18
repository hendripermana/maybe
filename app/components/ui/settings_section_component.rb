# frozen_string_literal: true

module Ui
  # Modern settings section component using Card component
  # Provides consistent styling for settings sections with title and subtitle
  class SettingsSectionComponent < BaseComponent
    renders_one :actions

    attr_reader :title, :subtitle

    def initialize(title:, subtitle: nil, **options)
      super(**options)
      @title = title
      @subtitle = subtitle
    end
  end
end