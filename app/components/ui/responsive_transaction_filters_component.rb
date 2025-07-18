# frozen_string_literal: true

module Ui
  # Responsive transaction filters component
  # Provides touch-friendly filter controls that adapt to different screen sizes
  class ResponsiveTransactionFiltersComponent < ViewComponent::Base
    attr_reader :filters, :active_filters

    def initialize(filters: {}, active_filters: [])
      @filters = filters
      @active_filters = active_filters
    end

    def has_active_filters?
      active_filters.any?
    end
  end
end