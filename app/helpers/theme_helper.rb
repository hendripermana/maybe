module ThemeHelper
  # Renders a theme toggle button that can be used in headers or other UI areas
  def theme_toggle(size: :md, with_label: false)
    render Ui::ThemeToggleComponent.new(size: size, with_label: with_label)
  end
  
  # Renders a theme preview for the specified theme
  def theme_preview(theme:)
    render Ui::ThemePreviewComponent.new(theme: theme)
  end
  
  # Returns the current theme based on user preference or default
  def current_theme
    return "system" unless current_user
    current_user.theme || "system"
  end
  
  # Returns true if the current theme is dark mode
  def dark_mode?
    current_theme == "dark"
  end
  
  # Returns true if the current theme is light mode
  def light_mode?
    current_theme == "light"
  end
  
  # Returns true if the current theme is system preference
  def system_theme?
    current_theme == "system"
  end
end