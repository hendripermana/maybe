module MonitoringHelper
  def error_chart_data(error_summary)
    return [] if error_summary.blank?
    
    error_summary.map do |error|
      {
        name: error.error_type,
        value: error.count
      }
    end.to_json
  end
  
  def performance_chart_data(performance_metrics)
    return [] if performance_metrics.blank?
    
    performance_metrics.map do |metric|
      {
        name: metric.metric_name,
        value: metric.avg_value.to_f.round(2)
      }
    end.to_json
  end
  
  def feedback_chart_data(feedback_summary)
    return [] if feedback_summary.blank?
    
    feedback_summary.map do |feedback|
      {
        name: feedback.feedback_type.humanize,
        resolved: feedback.resolved_count,
        unresolved: feedback.count - feedback.resolved_count
      }
    end.to_json
  end
  
  def theme_performance_trend_data
    # Get theme switch performance data for the last 7 days
    data = []
    7.downto(0) do |days_ago|
      date = Date.today - days_ago.days
      avg = UiMonitoringEvent.where("data->>'event_name' = 'theme_switched'")
                            .where(created_at: date.beginning_of_day..date.end_of_day)
                            .select("AVG((data->>'duration')::float) as avg_duration")
                            .first&.avg_duration || 0
      
      data << {
        date: date.strftime("%m/%d"),
        value: avg.to_f.round(2)
      }
    end
    
    data.to_json
  end
  
  def error_trend_data
    # Get error count data for the last 7 days
    data = []
    7.downto(0) do |days_ago|
      date = Date.today - days_ago.days
      count = UiMonitoringEvent.where(event_type: 'ui_error')
                              .where(created_at: date.beginning_of_day..date.end_of_day)
                              .count
      
      data << {
        date: date.strftime("%m/%d"),
        value: count
      }
    end
    
    data.to_json
  end
  
  def status_badge(status, text)
    class_name = status ? "bg-green-100 text-green-800 dark:bg-green-800 dark:text-green-100" : "bg-yellow-100 text-yellow-800 dark:bg-yellow-800 dark:text-yellow-100"
    
    content_tag :span, text, class: "px-2 inline-flex text-xs leading-5 font-semibold rounded-full #{class_name}"
  end
end