# frozen_string_literal: true

class PerformanceMetricsComponent < ViewComponent::Base
  def initialize(show_in_ui: false)
    @show_in_ui = show_in_ui
  end
end
