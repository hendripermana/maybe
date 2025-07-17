# frozen_string_literal: true

module VisualRegressionHelper
  # Visual regression testing utilities for UI components
  # Uses Capybara's screenshot functionality with organized storage
  
  def self.included(base)
    base.extend(ClassMethods)
  end
  
  module ClassMethods
    def visual_regression_test(test_name, &block)
      define_method("test_visual_regression_#{test_name}") do
        setup_visual_regression
        instance_eval(&block)
      end
    end
  end
  
  private
  
  def setup_visual_regression
    @visual_test_dir = Rails.root.join("test", "visual_regression", "screenshots")
    FileUtils.mkdir_p(@visual_test_dir)
  end
  
  def take_component_screenshot(component_name, variant: "default", theme: "light")
    screenshot_name = "#{component_name}_#{variant}_#{theme}"
    screenshot_path = @visual_test_dir.join("#{screenshot_name}.png")
    
    page.save_screenshot(screenshot_path)
    
    # Store metadata for comparison
    store_screenshot_metadata(screenshot_name, {
      component: component_name,
      variant: variant,
      theme: theme,
      timestamp: Time.current,
      viewport: page.current_window.size
    })
    
    screenshot_path
  end
  
  def compare_screenshots(baseline_path, current_path, threshold: 0.01)
    # Simple file comparison for now - in production you'd use image comparison
    return false unless File.exist?(baseline_path) && File.exist?(current_path)
    
    baseline_size = File.size(baseline_path)
    current_size = File.size(current_path)
    
    size_diff = (baseline_size - current_size).abs.to_f / baseline_size
    size_diff <= threshold
  end
  
  def assert_visual_regression(component_name, variant: "default", theme: "light")
    screenshot_name = "#{component_name}_#{variant}_#{theme}"
    current_path = take_component_screenshot(component_name, variant: variant, theme: theme)
    baseline_path = @visual_test_dir.join("baseline", "#{screenshot_name}.png")
    
    if File.exist?(baseline_path)
      assert compare_screenshots(baseline_path, current_path),
             "Visual regression detected for #{screenshot_name}"
    else
      # First run - create baseline
      FileUtils.mkdir_p(baseline_path.dirname)
      FileUtils.cp(current_path, baseline_path)
      puts "Created baseline screenshot for #{screenshot_name}"
    end
  end
  
  def store_screenshot_metadata(name, metadata)
    metadata_file = @visual_test_dir.join("#{name}_metadata.json")
    File.write(metadata_file, JSON.pretty_generate(metadata))
  end
  
  def with_viewport(width, height)
    original_size = page.current_window.size
    page.current_window.resize_to(width, height)
    yield
  ensure
    page.current_window.resize_to(*original_size) if original_size
  end
  
  def with_reduced_motion
    page.execute_script("document.documentElement.style.setProperty('--motion-reduce', 'reduce')")
    yield
  ensure
    page.execute_script("document.documentElement.style.removeProperty('--motion-reduce')")
  end
end