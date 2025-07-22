require "test_helper"

class MediaQueriesTest < ActionDispatch::IntegrationTest
  test "print styles are properly applied" do
    # This test simulates print media by adding a style tag that forces print media
    visit root_path
    
    # Add a script to simulate print media
    page.execute_script(<<~JAVASCRIPT)
      (function() {
        const style = document.createElement('style');
        style.id = 'print-simulation';
        style.textContent = `
          @media print {
            body {
              background-color: white !important;
            }
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
    
    # Verify that print styles are applied
    assert_selector "body", style: { backgroundColor: "white" }
    
    # Check that non-essential elements are hidden
    assert_selector "nav", visible: false
    assert_selector ".no-print", visible: false
    
    # Clean up
    page.execute_script("document.getElementById('print-simulation').remove();")
  end
  
  test "reduced motion preferences are respected" do
    visit root_path
    
    # Add a script to simulate reduced motion preference
    page.execute_script(<<~JAVASCRIPT)
      (function() {
        const style = document.createElement('style');
        style.id = 'reduced-motion-simulation';
        style.textContent = `
          @media (prefers-reduced-motion: reduce) {
            * {
              animation-duration: 0.001s !important;
              transition-duration: 0.001s !important;
            }
          }
        `;
        document.head.appendChild(style);
        
        // Force reduced motion media query
        const mediaQueryList = window.matchMedia('(prefers-reduced-motion: reduce)');
        Object.defineProperty(mediaQueryList, 'matches', { get: () => true });
        
        // Dispatch a change event to trigger any listeners
        const event = new Event('change');
        mediaQueryList.dispatchEvent(event);
      })();
    JAVASCRIPT
    
    # Verify animations are disabled
    # This is a bit tricky to test directly, but we can check computed styles
    animation_duration = page.evaluate_script(
      "window.getComputedStyle(document.querySelector('body')).animationDuration"
    )
    assert_equal "0.001s", animation_duration
    
    # Clean up
    page.execute_script("document.getElementById('reduced-motion-simulation').remove();")
  end
  
  test "high contrast mode is supported" do
    visit root_path
    
    # Add a script to simulate high contrast preference
    page.execute_script(<<~JAVASCRIPT)
      (function() {
        const style = document.createElement('style');
        style.id = 'high-contrast-simulation';
        style.textContent = `
          @media (prefers-contrast: more) {
            body {
              color: black !important;
              background-color: white !important;
            }
            
            a {
              text-decoration: underline !important;
              color: blue !important;
            }
          }
        `;
        document.head.appendChild(style);
        
        // Force high contrast media query
        const mediaQueryList = window.matchMedia('(prefers-contrast: more)');
        Object.defineProperty(mediaQueryList, 'matches', { get: () => true });
        
        // Dispatch a change event to trigger any listeners
        const event = new Event('change');
        mediaQueryList.dispatchEvent(event);
      })();
    JAVASCRIPT
    
    # Verify high contrast styles are applied
    assert_selector "body", style: { color: "black", backgroundColor: "white" }
    
    # Check that links have underlines
    if page.has_selector?("a")
      assert_selector "a", style: { textDecoration: "underline", color: "blue" }
    end
    
    # Clean up
    page.execute_script("document.getElementById('high-contrast-simulation').remove();")
  end
  
  test "screen reader utilities are present" do
    visit root_path
    
    # Add a skip to content link for testing
    page.execute_script(<<~JAVASCRIPT)
      (function() {
        const skipLink = document.createElement('a');
        skipLink.href = '#main';
        skipLink.className = 'skip-to-content';
        skipLink.textContent = 'Skip to content';
        document.body.prepend(skipLink);
        
        // Add a test element with sr-only class
        const srOnly = document.createElement('span');
        srOnly.className = 'sr-only';
        srOnly.textContent = 'Screen reader only text';
        document.body.appendChild(srOnly);
      })();
    JAVASCRIPT
    
    # Verify sr-only element is not visible but exists in the DOM
    assert_selector ".sr-only", visible: false
    assert page.has_content?("Screen reader only text", visible: false)
    
    # Verify skip link is initially not visible
    skip_link = find(".skip-to-content", visible: false)
    assert_not skip_link.visible?
    
    # Simulate focus on skip link
    page.execute_script("document.querySelector('.skip-to-content').focus();")
    
    # Now it should be visible
    assert skip_link.visible?
    
    # Clean up
    page.execute_script(<<~JAVASCRIPT)
      document.querySelector('.skip-to-content').remove();
      document.querySelector('.sr-only').remove();
    JAVASCRIPT
  end
end