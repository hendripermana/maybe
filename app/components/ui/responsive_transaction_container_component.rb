# frozen_string_literal: true

module Ui
  # Responsive transaction container component
  # Provides responsive layout and touch-friendly interactions for the transactions page
  class ResponsiveTransactionContainerComponent < ViewComponent::Base
    renders_one :header
    renders_one :filters
    renders_one :content
    renders_one :pagination
    renders_one :empty_state
    renders_one :loading_state

    def initialize(loading: false)
      @loading = loading
    end

    def loading?
      @loading
    end
  end
end