module ThemeHelper
  def current_theme
    cookies[:theme] || 'light'
  end
  
  def theme_switcher(options = {})
    # Render theme switcher component
    # Implementation depends on your existing theme switching mechanism
  end
  
  def feedback_form(options = {})
    # Render feedback form component
    render(FeedbackFormComponent.new(
      position: options[:position] || :bottom_right,
      theme: current_theme
    ))
  end
end