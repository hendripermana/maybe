require "application_system_test_case"

class ModernizedPagesAccessibilityTest < ApplicationSystemTestCase
  setup do
    @user = users(:family_admin)
    sign_in @user
  end

  # Test color contrast on all modernized pages
  test "all modernized pages have sufficient color contrast" do
    # Define all modernized pages to test
    modernized_pages = [
      { path: root_path, name: "Dashboard" },
      { path: transactions_path, name: "Transactions" },
      { path: budgets_path, name: "Budgets" },
      { path: settings_preferences_path, name: "Settings" }
    ]
    
    # Test each page in both themes
    modernized_pages.each do |page|
      # Test in light theme
      ensure_theme("light")
      visit page[:path]
      
      # Check text elements for sufficient contrast
      check_text_elements_contrast
      
      # Test in dark theme
      ensure_theme("dark")
      visit page[:path]
      
      # Check text elements for sufficient contrast
      check_text_elements_contrast
    end
  end
  
  # Test keyboard navigation on all modernized pages
  test "all modernized pages are keyboard navigable" do
    # Define all modernized pages to test
    modernized_pages = [
      { path: root_path, name: "Dashboard" },
      { path: transactions_path, name: "Transactions" },
      { path: budgets_path, name: "Budgets" },
      { path: settings_preferences_path, name: "Settings" }
    ]
    
    # Test each page for keyboard navigation
    modernized_pages.each do |page|
      visit page[:path]
      
      # Press Tab key multiple times to navigate through all interactive elements
      interactive_elements = all("a, button, input, select, textarea", visible: true)
      
      # Skip if no interactive elements
      next if interactive_elements.empty?
      
      # Focus the first element
      interactive_elements.first.send_keys(:tab)
      
      # Tab through all elements and ensure focus is visible
      (interactive_elements.size - 1).times do
        # Send tab key
        page.driver.browser.action.send_keys(:tab).perform
        
        # Check that exactly one element has focus
        assert_selector ":focus", count: 1, message: "Focus should be visible on #{page[:name]} page"
        
        # Get focused element
        focused_element = find(:focus)
        
        # Check for visible focus indicator
        assert_visible_focus_indicator(focused_element)
      end
    end
  end
  
  # Test screen reader compatibility on all modernized pages
  test "all modernized pages are screen reader compatible" do
    # Define all modernized pages to test
    modernized_pages = [
      { path: root_path, name: "Dashboard" },
      { path: transactions_path, name: "Transactions" },
      { path: budgets_path, name: "Budgets" },
      { path: settings_preferences_path, name: "Settings" }
    ]
    
    # Test each page for screen reader compatibility
    modernized_pages.each do |page|
      visit page[:path]
      
      # Check for proper ARIA landmarks
      assert_selector "[role='main']", "Page should have main landmark"
      assert_selector "header, [role='banner']", "Page should have header landmark"
      assert_selector "nav, [role='navigation']", "Page should have navigation landmark"
      
      # Check for proper heading hierarchy
      assert_proper_heading_hierarchy
      
      # Check images have alt text
      all("img").each do |img|
        assert img[:alt].present?, "Image should have alt text on #{page[:name]} page"
      end
      
      # Check buttons have accessible names
      all("button").each do |button|
        assert_accessible_name(button)
      end
      
      # Check links have accessible names
      all("a").each do |link|
        assert_accessible_name(link)
      end
      
      # Check form controls have labels
      assert_proper_form_labels
    end
  end
  
  # Test reduced motion preference on all modernized pages
  test "all modernized pages respect reduced motion preference" do
    # Define all modernized pages to test
    modernized_pages = [
      { path: root_path, name: "Dashboard" },
      { path: transactions_path, name: "Transactions" },
      { path: budgets_path, name: "Budgets" },
      { path: settings_preferences_path, name: "Settings" }
    ]
    
    # Test each page with reduced motion preference
    modernized_pages.each do |page|
      visit page[:path]
      
      # Enable reduced motion preference
      with_reduced_motion do
        # Reload page to apply preference
        visit page[:path]
        
        # Check that reduced motion class is applied
        assert_selector "body.reduce-motion", "Reduced motion class should be applied on #{page[:name]} page"
        
        # Check CSS variables
        reduced_motion_value = page.evaluate_script(
          "getComputedStyle(document.documentElement).getPropertyValue('--motion-reduce')"
        ).strip
        
        assert_equal "reduce", reduced_motion_value, "Reduced motion CSS variable should be set on #{page[:name]} page"
      end
    end
  end
  
  # Test high contrast mode on all modernized pages
  test "all modernized pages support high contrast mode" do
    # Define all modernized pages to test
    modernized_pages = [
      { path: root_path, name: "Dashboard" },
      { path: transactions_path, name: "Transactions" },
      { path: budgets_path, name: "Budgets" },
      { path: settings_preferences_path, name: "Settings" }
    ]
    
    # Test each page with high contrast mode
    modernized_pages.each do |page|
      visit page[:path]
      
      # Enable high contrast mode
      with_high_contrast do
        # Reload page to apply preference
        visit page[:path]
        
        # Check that high contrast class is applied
        assert_selector "body.high-contrast", "High contrast class should be applied on #{page[:name]} page"
        
        # Check text elements for sufficient contrast
        check_text_elements_contrast(level: :aaa)
      end
    end
  end
  
  private
  
  def check_text_elements_contrast(level: :aa)
    # Check headings
    all("h1, h2, h3, h4, h5, h6", visible: true).each do |heading|
      assert_sufficient_color_contrast(heading, level: level)
    end
    
    # Check paragraphs
    all("p", visible: true).each do |paragraph|
      assert_sufficient_color_contrast(paragraph, level: level)
    end
    
    # Check links
    all("a", visible: true).each do |link|
      assert_sufficient_color_contrast(link, level: level)
    end
    
    # Check buttons
    all("button", visible: true).each do |button|
      assert_sufficient_color_contrast(button, level: level)
    end
    
    # Check form labels
    all("label", visible: true).each do |label|
      assert_sufficient_color_contrast(label, level: level)
    end
  end
  
  def assert_visible_focus_indicator(element)
    # Get computed styles for the element
    styles = page.evaluate_script(
      "window.getComputedStyle(arguments[0])",
      element.native
    )
    
    # Check for visible focus styles
    has_outline = styles["outline"] != "none" && styles["outline-width"] != "0px"
    has_box_shadow = styles["box-shadow"] != "none"
    has_border = styles["border"] != "none" && styles["border-width"] != "0px"
    
    assert(has_outline || has_box_shadow || has_border,
           "Element should have visible focus indicator")
  end
end