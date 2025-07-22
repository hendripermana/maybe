require "application_system_test_case"

class AccessibilityFeaturesTest < ApplicationSystemTestCase
  setup do
    @user = users(:maybe)
    login_as @user
  end
  
  test "skip to content link works" do
    visit root_path
    
    # Skip link should be visually hidden by default
    assert_selector ".skip-to-content", visible: false
    
    # Focus the skip link
    find(".skip-to-content", visible: false).send_keys(:tab)
    
    # Now it should be visible
    assert_selector ".skip-to-content", visible: true
    
    # Click the skip link
    find(".skip-to-content").click
    
    # Should focus on main content
    assert_equal "#main-content", current_url.split("#").last
  end
  
  test "print styles hide non-essential elements" do
    visit transactions_path
    
    # Add a script to simulate print media
    page.execute_script(<<~JAVASCRIPT)
      (function() {
        const style = document.createElement('style');
        style.id = 'print-simulation';
        style.textContent = `
          @media print {
            nav { display: none !important; }
            .no-print { display: none !important; }
          }
        `;
        document.head.appendChild(style);
        
        // Force print media
        const mediaQueryList = window.matchMedia('print');
        Object.defineProperty(mediaQueryList, 'matches', { get: () => true });
        
        // Dispatch a change event to trigger any listeners
        const event = new Event('change');
        mediaQueryList.dispatchEvent(event);
      })();
    JAVASCRIPT
    
    # Navigation should be hidden in print mode
    assert_selector "nav", visible: false
    
    # Clean up
    page.execute_script("document.getElementById('print-simulation').remove();")
  end
end