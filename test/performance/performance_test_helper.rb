# frozen_string_literal: true

# Helper module for performance testing
module PerformanceTestHelper
  # Measures page load time
  def measure_page_load(path)
    start_time = Time.current
    visit path
    end_time = Time.current
    load_time = (end_time - start_time) * 1000 # Convert to milliseconds
    
    Rails.logger.info "Page load time for #{path}: #{load_time.round(2)}ms"
    load_time
  end
  
  # Measures theme switching time
  def measure_theme_switch
    start_time = Time.current
    execute_script("document.documentElement.setAttribute('data-theme', document.documentElement.getAttribute('data-theme') === 'dark' ? 'light' : 'dark')")
    end_time = Time.current
    switch_time = (end_time - start_time) * 1000 # Convert to milliseconds
    
    Rails.logger.info "Theme switch time: #{switch_time.round(2)}ms"
    switch_time
  end
  
  # Detects layout shifts
  def detect_layout_shifts
    # Store initial positions of key elements
    elements = all('.layout-shift-monitor')
    initial_positions = elements.map { |el| [el, el.rect] }
    
    # Trigger potential layout shift (e.g., load images, toggle visibility)
    execute_script("window.dispatchEvent(new Event('resize'))")
    sleep 0.5 # Allow time for any shifts to occur
    
    # Check if positions changed
    shifts = []
    initial_positions.each do |el, initial_rect|
      current_rect = el.rect
      if initial_rect.top != current_rect.top || initial_rect.left != current_rect.left
        shifts << {
          element: el[:class],
          top_shift: (current_rect.top - initial_rect.top).round(2),
          left_shift: (current_rect.left - initial_rect.left).round(2)
        }
      end
    end
    
    shifts
  end
  
  # Adds layout shift monitoring class to elements
  def monitor_elements_for_shifts(selectors)
    selectors.each do |selector|
      execute_script("document.querySelectorAll('#{selector}').forEach(el => el.classList.add('layout-shift-monitor'))")
    end
  end
end