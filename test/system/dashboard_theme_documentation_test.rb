require "application_system_test_case"

class DashboardThemeDocumentationTest < ApplicationSystemTestCase
  setup do
    sign_in @user = users(:family_admin)
  end

  test "document dashboard theme overrides and special cases" do
    visit root_path

    # This test documents theme overrides and special layout cases
    # It doesn't assert anything but captures the current state for documentation

    # Document theme variables used in dashboard
    theme_variables = UiTestingConfig::THEME_CONFIG[:css_variables]

    # Create documentation for both themes
    theme_documentation = {}

    test_both_themes do
      current_theme_name = current_theme
      theme_documentation[current_theme_name] = {
        variables: {},
        special_cases: []
      }

      # Document CSS variables
      theme_variables.each do |variable|
        value = get_css_variable_value(variable)
        theme_documentation[current_theme_name][:variables][variable] = value
      end

      # Document special layout cases

      # 1. Dashboard cards with special styling
      if has_selector?(".dashboard-card")
        cards = all(".dashboard-card")
        cards.each_with_index do |card, index|
          # Check for special styling
          if card[:class].include?("dashboard-card-special")
            theme_documentation[current_theme_name][:special_cases] << {
              element: ".dashboard-card:nth-child(#{index + 1})",
              special_class: "dashboard-card-special",
              description: "Special card styling with custom background"
            }
          end
        end
      end

      # 2. Chart containers with theme-specific styling
      if has_selector?(".chart-container")
        charts = all(".chart-container")
        charts.each_with_index do |chart, index|
          # Check for special chart styling
          if chart[:class].include?("chart-container-fullwidth")
            theme_documentation[current_theme_name][:special_cases] << {
              element: ".chart-container:nth-child(#{index + 1})",
              special_class: "chart-container-fullwidth",
              description: "Full-width chart container with special margin handling"
            }
          end
        end
      end

      # 3. Dashboard layout overrides
      if has_selector?(".dashboard-page")
        dashboard_page = find(".dashboard-page")
        if dashboard_page[:class].include?("dashboard-no-padding")
          theme_documentation[current_theme_name][:special_cases] << {
            element: ".dashboard-page",
            special_class: "dashboard-no-padding",
            description: "Dashboard page with padding removed to fix white space issues"
          }
        end
      end

      # 4. Sankey chart special handling
      if has_selector?("#sankey-chart")
        sankey = find("#sankey-chart")
        theme_documentation[current_theme_name][:special_cases] << {
          element: "#sankey-chart",
          description: "Sankey chart with theme-specific color handling via JavaScript"
        }
      end
    end

    # Output documentation to a file for reference
    output_dir = Rails.root.join("test", "documentation")
    FileUtils.mkdir_p(output_dir)

    File.write(
      output_dir.join("dashboard_theme_documentation.json"),
      JSON.pretty_generate(theme_documentation)
    )

    # Also create a markdown version for human readability
    markdown_content = "# Dashboard Theme Documentation\n\n"

    theme_documentation.each do |theme_name, data|
      markdown_content << "## #{theme_name.capitalize} Theme\n\n"

      markdown_content << "### CSS Variables\n\n"
      markdown_content << "| Variable | Value |\n"
      markdown_content << "|----------|-------|\n"

      data[:variables].each do |variable, value|
        markdown_content << "| `#{variable}` | `#{value}` |\n"
      end

      markdown_content << "\n### Special Cases\n\n"

      if data[:special_cases].any?
        data[:special_cases].each do |special_case|
          markdown_content << "#### #{special_case[:element]}\n\n"
          markdown_content << "- **Special Class:** #{special_case[:special_class]}\n" if special_case[:special_class]
          markdown_content << "- **Description:** #{special_case[:description]}\n\n"
        end
      else
        markdown_content << "No special cases documented.\n\n"
      end
    end

    File.write(
      output_dir.join("dashboard_theme_documentation.md"),
      markdown_content
    )
  end
end
