# frozen_string_literal: true

module ThemeTestHelper
  # Theme testing utilities for UI components
  # Provides helpers for testing light/dark theme switching

  THEMES = %w[light dark].freeze

  def with_theme(theme_name)
    original_theme = current_theme
    set_theme(theme_name)
    yield
  ensure
    set_theme(original_theme) if original_theme
  end

  def test_both_themes(&block)
    THEMES.each do |theme|
      with_theme(theme) do
        instance_eval(&block)
      end
    end
  end

  def assert_theme_aware_colors(selector)
    THEMES.each do |theme|
      with_theme(theme) do
        element = page.find(selector)

        # Check that element doesn't have hardcoded colors
        computed_styles = page.evaluate_script(
          "window.getComputedStyle(arguments[0])",
          element.native
        )

        # Assert no hardcoded light colors in dark theme
        if theme == "dark"
          refute_hardcoded_light_colors(computed_styles, selector)
        else
          refute_hardcoded_dark_colors(computed_styles, selector)
        end
      end
    end
  end

  def assert_theme_consistency(component_selector)
    light_styles = nil
    dark_styles = nil

    with_theme("light") do
      light_styles = get_computed_styles(component_selector)
    end

    with_theme("dark") do
      dark_styles = get_computed_styles(component_selector)
    end

    # Verify that colors actually change between themes
    assert_not_equal light_styles["background-color"], dark_styles["background-color"],
                     "Background color should differ between themes for #{component_selector}"

    assert_not_equal light_styles["color"], dark_styles["color"],
                     "Text color should differ between themes for #{component_selector}"
  end

  def assert_no_hardcoded_colors(selector)
    element = page.find(selector)
    classes = element[:class].to_s.split

    # Check for hardcoded Tailwind color classes
    hardcoded_patterns = [
      /bg-white/, /bg-black/, /bg-gray-\d+/, /bg-slate-\d+/,
      /text-white/, /text-black/, /text-gray-\d+/, /text-slate-\d+/,
      /border-white/, /border-black/, /border-gray-\d+/, /border-slate-\d+/
    ]

    hardcoded_classes = classes.select do |css_class|
      hardcoded_patterns.any? { |pattern| css_class.match?(pattern) }
    end

    assert_empty hardcoded_classes,
                 "Found hardcoded color classes in #{selector}: #{hardcoded_classes.join(', ')}"
  end

  def toggle_theme
    # Simulate theme toggle button click
    if page.has_selector?('[data-testid="theme-toggle"]')
      page.find('[data-testid="theme-toggle"]').click
    elsif page.has_selector?(".theme-toggle")
      page.find(".theme-toggle").click
    else
      # Fallback: directly manipulate data attribute
      page.execute_script("document.documentElement.setAttribute('data-theme',
                          document.documentElement.getAttribute('data-theme') === 'dark' ? 'light' : 'dark')")
    end

    # Wait for theme transition to complete
    sleep 0.1
  end

  def current_theme
    if respond_to?(:page) && page.present?
      page.evaluate_script("document.documentElement.getAttribute('data-theme')") || "light"
    else
      @current_theme || "light"
    end
  end

  def set_theme(theme_name)
    return unless THEMES.include?(theme_name.to_s)

    if respond_to?(:page) && page.present?
      page.execute_script("document.documentElement.setAttribute('data-theme', '#{theme_name}')")
      # Wait for CSS variables to update
      sleep 0.05
    else
      @current_theme = theme_name.to_s
    end
  end

  def assert_theme_applied(expected_theme)
    actual_theme = current_theme
    assert_equal expected_theme.to_s, actual_theme,
                 "Expected theme '#{expected_theme}' but got '#{actual_theme}'"
  end

  def assert_css_variable_defined(variable_name, selector: ":root")
    value = page.evaluate_script(
      "getComputedStyle(document.querySelector('#{selector}')).getPropertyValue('#{variable_name}')"
    ).strip

    assert_not_empty value, "CSS variable #{variable_name} is not defined or empty"
  end

  def get_css_variable_value(variable_name, selector: ":root")
    page.evaluate_script(
      "getComputedStyle(document.querySelector('#{selector}')).getPropertyValue('#{variable_name}')"
    ).strip
  end

  def assert_theme_variables_different(variable_name)
    light_value = nil
    dark_value = nil

    with_theme("light") do
      light_value = get_css_variable_value(variable_name)
    end

    with_theme("dark") do
      dark_value = get_css_variable_value(variable_name)
    end

    assert_not_equal light_value, dark_value,
                     "CSS variable #{variable_name} should have different values in light and dark themes"
  end

  private

    def get_computed_styles(selector)
      element = page.find(selector)
      page.evaluate_script(
        "Object.fromEntries(Array.from(getComputedStyle(arguments[0])).map(prop => [prop, getComputedStyle(arguments[0])[prop]]))",
        element.native
      )
    end

    def refute_hardcoded_light_colors(styles, selector)
      light_colors = [ "rgb(255, 255, 255)", "#ffffff", "#fff", "white" ]

      light_colors.each do |color|
        refute_equal color.downcase, styles["background-color"]&.downcase,
                     "Found hardcoded light background in dark theme for #{selector}"
        refute_equal color.downcase, styles["color"]&.downcase,
                     "Found hardcoded light text in dark theme for #{selector}"
      end
    end

    def refute_hardcoded_dark_colors(styles, selector)
      dark_colors = [ "rgb(0, 0, 0)", "#000000", "#000", "black" ]

      dark_colors.each do |color|
        refute_equal color.downcase, styles["background-color"]&.downcase,
                     "Found hardcoded dark background in light theme for #{selector}"
        refute_equal color.downcase, styles["color"]&.downcase,
                     "Found hardcoded dark text in light theme for #{selector}"
      end
    end
end
