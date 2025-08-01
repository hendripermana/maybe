# frozen_string_literal: true

module ComponentVisualRegressionHelper
  # Visual regression testing utilities specifically for UI components
  # Extends the base VisualRegressionHelper with component-specific functionality

  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def visual_regression_test_for(component_class, variants = nil, themes = ThemeTestHelper::THEMES)
      component_name = component_class.name.demodulize.underscore.sub(/_component$/, "")

      define_method("test_visual_regression_#{component_name}") do
        setup_visual_regression

        if variants.present?
          variants.each do |variant|
            themes.each do |theme|
              component = component_class.new(variant: variant)
              render_component_with_theme(component, theme: theme)

              screenshot_name = "#{component_name}_#{variant}_#{theme}"
              take_screenshot(screenshot_name)
              compare_with_baseline(screenshot_name)
            end
          end
        else
          themes.each do |theme|
            component = component_class.new
            render_component_with_theme(component, theme: theme)

            screenshot_name = "#{component_name}_default_#{theme}"
            take_screenshot(screenshot_name)
            compare_with_baseline(screenshot_name)
          end
        end
      end
    end
  end

  def render_component_with_theme(component, theme: "light", &block)
    # For component tests, we need to render the component in a div with theme data attribute
    @rendered_content = render_in_view_context do
      content_tag :div, data: { theme: theme }, class: "p-4" do
        if block_given?
          render_inline(component, &block)
        else
          render_inline(component)
        end
      end
    end
  end

  def take_screenshot(name)
    # For component tests, we use html_snapshot instead of page screenshot
    snapshot_path = @visual_test_dir.join("#{name}.html")
    File.write(snapshot_path, @rendered_content)

    # Store metadata
    store_screenshot_metadata(name, {
      timestamp: Time.current,
      component: name.split("_").first,
      variant: name.split("_")[1],
      theme: name.split("_").last
    })

    snapshot_path
  end

  def compare_with_baseline(name)
    current_path = @visual_test_dir.join("#{name}.html")
    baseline_path = @visual_test_dir.join("baseline", "#{name}.html")

    if File.exist?(baseline_path)
      # Compare HTML content (simplified comparison)
      current_content = File.read(current_path)
      baseline_content = File.read(baseline_path)

      # Normalize whitespace for comparison
      current_normalized = normalize_html(current_content)
      baseline_normalized = normalize_html(baseline_content)

      assert_equal baseline_normalized, current_normalized,
                 "Visual regression detected for #{name}"
    else
      # First run - create baseline
      FileUtils.mkdir_p(baseline_path.dirname)
      FileUtils.cp(current_path, baseline_path)
      puts "Created baseline for #{name}"
    end
  end

  private

    def normalize_html(html)
      # Simple normalization to ignore whitespace differences
      html.gsub(/\s+/, " ").strip
    end

    def render_in_view_context(&block)
      # Create a view context for rendering
      view_context = ApplicationController.new.view_context
      view_context.instance_eval(&block).to_s
    end
end
