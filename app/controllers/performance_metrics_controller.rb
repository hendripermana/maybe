# frozen_string_literal: true

class PerformanceMetricsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [ :create ]

  def create
    # Log the metric
    metric = params.require(:metric).permit(:name, :value, :path, :user_agent)

    Rails.logger.info "Performance Metric: #{metric[:name]} = #{metric[:value]} (#{metric[:path]})"

    # Store metric in database or monitoring service
    # This is a placeholder - in a real implementation, you would store this data

    head :ok
  end
end
