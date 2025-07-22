module ResponsiveTestHelper
  # Helper method to set viewport size
  def set_viewport_size(width, height)
    page.driver.browser.manage.window.resize_to(width, height)
  end
  
  # Helper method to check if element is visible and within viewport
  def assert_visible_in_viewport(selector)
    element = find(selector)
    assert element.visible?
    
    rect = evaluate_script <<-JS
      (function() {
        var el = document.querySelector('#{selector}');
        if (!el) return null;
        var rect = el.getBoundingClientRect();
        return {
          top: rect.top,
          right: rect.right,
          bottom: rect.bottom,
          left: rect.left,
          width: rect.width,
          height: rect.height
        };
      })()
    JS
    
    viewport_width = evaluate_script("window.innerWidth")
    viewport_height = evaluate_script("window.innerHeight")
    
    assert rect["right"] <= viewport_width, "Element extends beyond right edge of viewport"
    assert rect["bottom"] <= viewport_height, "Element extends beyond bottom edge of viewport"
  end
  
  # Helper method to check minimum touch target size
  def assert_minimum_touch_target_size(selector, min_size = 44)
    element = find(selector)
    rect = evaluate_script <<-JS
      (function() {
        var el = document.querySelector('#{selector}');
        if (!el) return null;
        var rect = el.getBoundingClientRect();
        return {
          width: rect.width,
          height: rect.height
        };
      })()
    JS
    
    assert rect["width"] >= min_size, "Touch target width is too small: #{rect["width"]}px (minimum: #{min_size}px)"
    assert rect["height"] >= min_size, "Touch target height is too small: #{rect["height"]}px (minimum: #{min_size}px)"
  end
  
  # Helper method to check for horizontal scrolling
  def assert_no_horizontal_scrolling
    scroll_width = evaluate_script("document.documentElement.scrollWidth")
    client_width = evaluate_script("document.documentElement.clientWidth")
    
    assert scroll_width <= client_width, "Page has horizontal scrolling: scroll width #{scroll_width}px > client width #{client_width}px"
  end
  
  # Helper method to simulate orientation change
  def simulate_orientation_change
    width = evaluate_script("window.innerWidth")
    height = evaluate_script("window.innerHeight")
    
    # Swap width and height to simulate orientation change
    set_viewport_size(height, width)
  end
  
  # Helper method to check text readability
  def assert_readable_text(selector)
    element = find(selector)
    styles = evaluate_script <<-JS
      (function() {
        var el = document.querySelector('#{selector}');
        if (!el) return null;
        var style = window.getComputedStyle(el);
        return {
          fontSize: parseFloat(style.fontSize),
          lineHeight: parseFloat(style.lineHeight)
        };
      })()
    JS
    
    min_font_size = 12 # Minimum readable font size in pixels
    assert styles["fontSize"] >= min_font_size, "Font size is too small: #{styles["fontSize"]}px (minimum: #{min_font_size}px)"
  end
end