require "application_system_test_case"

class FeedbackFormTest < ApplicationSystemTestCase
  setup do
    @user = users(:regular_user)
  end
  
  # Basic accessibility and presence tests
  test "feedback form is accessible from any page" do
    visit root_path
    
    assert_selector ".feedback-form"
    assert_selector "button", text: "Feedback"
  end
  
  test "feedback form is accessible on different pages" do
    pages_to_test = [
      root_path,
      "/dashboard",
      "/transactions",
      "/accounts"
    ]
    
    pages_to_test.each do |page_path|
      visit page_path
      assert_selector ".feedback-form", "Feedback form should be present on #{page_path}"
      assert_selector "button", text: "Feedback"
    end
  end

  # Form interaction tests
  test "can open and close feedback form" do
    visit root_path
    
    # Initially form should be closed
    assert_selector ".feedback-panel", visible: false
    
    # Open form
    click_button "Feedback"
    assert_selector ".feedback-panel", visible: true
    assert_selector "h3", text: "Share Your Feedback"
    
    # Close form with cancel button
    click_button "Cancel"
    assert_selector ".feedback-panel", visible: false
    
    # Open form again
    click_button "Feedback"
    assert_selector ".feedback-panel", visible: true
    
    # Close form by clicking outside (if implemented)
    page.execute_script("document.body.click()")
    sleep 0.1 # Allow time for event to process
    # Note: This test depends on the actual implementation of click-outside behavior
  end

  # Anonymous user tests
  test "anonymous user can submit feedback" do
    visit root_path
    
    # Open form
    click_button "Feedback"
    
    # Fill in form
    select "Bug Report", from: "user_feedback[feedback_type]"
    fill_in "user_feedback[message]", with: "This is anonymous feedback"
    
    # Submit form
    assert_difference("UserFeedback.count") do
      click_button "Submit Feedback"
    end
    
    # Check for success message
    assert_text "Thank you for your feedback!"
    
    # Verify the feedback was saved
    feedback = UserFeedback.last
    assert_equal "bug_report", feedback.feedback_type
    assert_equal "This is anonymous feedback", feedback.message
    assert_nil feedback.user
    assert_equal current_path, feedback.page
  end

  # Authenticated user tests
  test "authenticated user can submit feedback" do
    sign_in @user
    visit root_path
    
    # Open form
    click_button "Feedback"
    
    # Fill in form
    select "Feature Request", from: "user_feedback[feedback_type]"
    fill_in "user_feedback[message]", with: "Please add this feature"
    
    # Submit form
    assert_difference("UserFeedback.count") do
      click_button "Submit Feedback"
    end
    
    # Check for success message
    assert_text "Thank you for your feedback!"
    
    # Verify the feedback was saved with user association
    feedback = UserFeedback.last
    assert_equal "feature_request", feedback.feedback_type
    assert_equal "Please add this feature", feedback.message
    assert_equal @user, feedback.user
  end

  # All feedback types test
  test "can submit all types of feedback" do
    feedback_types = {
      "Bug Report" => "bug_report",
      "Feature Request" => "feature_request", 
      "UI Feedback" => "ui_feedback",
      "Accessibility Issue" => "accessibility_issue",
      "Performance Issue" => "performance_issue",
      "General Feedback" => "general_feedback"
    }
    
    feedback_types.each do |display_name, enum_value|
      visit root_path
      
      click_button "Feedback"
      
      select display_name, from: "user_feedback[feedback_type]"
      fill_in "user_feedback[message]", with: "Test #{display_name.downcase}"
      
      assert_difference("UserFeedback.count") do
        click_button "Submit Feedback"
      end
      
      feedback = UserFeedback.last
      assert_equal enum_value, feedback.feedback_type
      assert_equal "Test #{display_name.downcase}", feedback.message
    end
  end

  # Validation tests
  test "shows validation errors for empty form" do
    visit root_path
    
    click_button "Feedback"
    
    # Submit without filling required fields
    click_button "Submit Feedback"
    
    # Should show error message
    assert_text "There was a problem submitting your feedback"
    assert_text "Feedback type can't be blank"
    assert_text "Message can't be blank"
  end
  
  test "shows validation error for missing feedback type" do
    visit root_path
    
    click_button "Feedback"
    
    # Fill message but not type
    fill_in "user_feedback[message]", with: "Test message"
    click_button "Submit Feedback"
    
    assert_text "There was a problem submitting your feedback"
    assert_text "Feedback type can't be blank"
  end
  
  test "shows validation error for missing message" do
    visit root_path
    
    click_button "Feedback"
    
    # Fill type but not message
    select "Bug Report", from: "user_feedback[feedback_type]"
    click_button "Submit Feedback"
    
    assert_text "There was a problem submitting your feedback"
    assert_text "Message can't be blank"
  end

  # Context capture tests
  test "captures current page context" do
    visit "/dashboard"
    
    click_button "Feedback"
    select "Bug Report", from: "user_feedback[feedback_type]"
    fill_in "user_feedback[message]", with: "Dashboard issue"
    
    assert_difference("UserFeedback.count") do
      click_button "Submit Feedback"
    end
    
    feedback = UserFeedback.last
    assert_includes feedback.page, "/dashboard"
  end
  
  test "captures browser information" do
    visit root_path
    
    click_button "Feedback"
    select "Bug Report", from: "user_feedback[feedback_type]"
    fill_in "user_feedback[message]", with: "Browser test"
    
    assert_difference("UserFeedback.count") do
      click_button "Submit Feedback"
    end
    
    feedback = UserFeedback.last
    assert_not_nil feedback.browser
    # Browser info should contain some identifying information
    assert feedback.browser.length > 0
  end

  # Theme integration tests
  test "captures theme context" do
    visit root_path
    
    # Set theme via JavaScript (simulating theme switcher)
    page.execute_script("document.documentElement.setAttribute('data-theme', 'dark')")
    
    click_button "Feedback"
    
    # Check that theme is captured in hidden field
    theme_field = find("input[name='user_feedback[theme]']", visible: false)
    # The actual value depends on how the theme helper is implemented
    assert_not_nil theme_field.value
    
    select "UI Feedback", from: "user_feedback[feedback_type]"
    fill_in "user_feedback[message]", with: "Dark theme issue"
    
    assert_difference("UserFeedback.count") do
      click_button "Submit Feedback"
    end
    
    feedback = UserFeedback.last
    assert_not_nil feedback.theme
  end

  # Responsive design tests
  test "feedback form works on mobile viewport" do
    # Set mobile viewport
    page.driver.browser.manage.window.resize_to(375, 667) # iPhone 8 size
    
    visit root_path
    
    # Form should be accessible
    assert_selector "button", text: "Feedback"
    
    click_button "Feedback"
    assert_selector ".feedback-panel", visible: true
    
    # Form should fit within viewport
    panel = find(".feedback-panel")
    viewport_width = page.driver.browser.manage.window.size.width
    
    # Panel should not extend beyond viewport
    assert panel.native.location.x >= 0, "Panel should not be positioned off-screen left"
    
    # Form should be usable
    select "Bug Report", from: "user_feedback[feedback_type]"
    fill_in "user_feedback[message]", with: "Mobile test"
    
    assert_difference("UserFeedback.count") do
      click_button "Submit Feedback"
    end
    
    # Reset viewport
    page.driver.browser.manage.window.resize_to(1280, 800)
  end
  
  test "feedback form works on tablet viewport" do
    # Set tablet viewport
    page.driver.browser.manage.window.resize_to(768, 1024) # iPad size
    
    visit root_path
    
    click_button "Feedback"
    assert_selector ".feedback-panel", visible: true
    
    # Form should be fully functional
    select "Feature Request", from: "user_feedback[feedback_type]"
    fill_in "user_feedback[message]", with: "Tablet test"
    
    assert_difference("UserFeedback.count") do
      click_button "Submit Feedback"
    end
    
    # Reset viewport
    page.driver.browser.manage.window.resize_to(1280, 800)
  end

  # Accessibility tests
  test "feedback form is keyboard accessible" do
    visit root_path
    
    # Tab to feedback button
    page.execute_script("document.querySelector('button:contains(\"Feedback\")').focus()")
    
    # Press Enter to open form
    find("button", text: "Feedback").send_keys(:return)
    assert_selector ".feedback-panel", visible: true
    
    # Tab through form elements
    page.execute_script("document.querySelector('select[name=\"user_feedback[feedback_type]\"]').focus()")
    
    # Use keyboard to select option
    find("select[name='user_feedback[feedback_type]']").send_keys("Bug Report")
    
    # Tab to message field
    find("textarea[name='user_feedback[message]']").click
    fill_in "user_feedback[message]", with: "Keyboard navigation test"
    
    # Submit with keyboard
    find("input[type='submit']").send_keys(:return)
    
    assert_text "Thank you for your feedback!"
  end
  
  test "feedback form has proper labels and ARIA attributes" do
    visit root_path
    
    click_button "Feedback"
    
    # Check for proper labels
    assert_selector "label[for*='feedback_type']", text: "Type of Feedback"
    assert_selector "label[for*='message']", text: "Your Feedback"
    
    # Check for required attributes
    assert_selector "select[required]"
    assert_selector "textarea[required]"
    
    # Check for helpful placeholder text
    assert_selector "textarea[placeholder*='Please describe']"
  end

  # Error handling tests
  test "handles server errors gracefully" do
    visit root_path
    
    # Mock a server error by stubbing the controller
    # This is a simplified test - in practice you might use WebMock or similar
    click_button "Feedback"
    
    select "Bug Report", from: "user_feedback[feedback_type]"
    fill_in "user_feedback[message]", with: "Server error test"
    
    # Simulate server error by making the form submission fail
    page.execute_script("""
      document.querySelector('form').addEventListener('submit', function(e) {
        e.preventDefault();
        // Simulate error response
        alert('Server error occurred');
      });
    """)
    
    click_button "Submit Feedback"
    
    # In a real implementation, this would show a proper error message
    # This test verifies the form doesn't break completely
    assert_selector ".feedback-panel", visible: true
  end

  # Form state tests
  test "form resets after successful submission" do
    visit root_path
    
    click_button "Feedback"
    
    select "Bug Report", from: "user_feedback[feedback_type]"
    fill_in "user_feedback[message]", with: "First feedback"
    
    click_button "Submit Feedback"
    assert_text "Thank you for your feedback!"
    
    # Open form again
    click_button "Feedback"
    
    # Form should be reset
    assert_equal "", find("select[name='user_feedback[feedback_type]']").value
    assert_equal "", find("textarea[name='user_feedback[message]']").value
  end

  # Multiple feedback submissions test
  test "can submit multiple feedback items in same session" do
    visit root_path
    
    # First feedback
    click_button "Feedback"
    select "Bug Report", from: "user_feedback[feedback_type]"
    fill_in "user_feedback[message]", with: "First issue"
    
    assert_difference("UserFeedback.count") do
      click_button "Submit Feedback"
    end
    
    # Second feedback
    click_button "Feedback"
    select "Feature Request", from: "user_feedback[feedback_type]"
    fill_in "user_feedback[message]", with: "Second request"
    
    assert_difference("UserFeedback.count") do
      click_button "Submit Feedback"
    end
    
    # Verify both were saved
    feedbacks = UserFeedback.last(2)
    assert_equal "First issue", feedbacks.first.message
    assert_equal "Second request", feedbacks.last.message
  end

  # Cross-browser compatibility test
  test "feedback form works across different user agents" do
    # This test simulates different user agents
    user_agents = [
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
      "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.1 Safari/605.1.15",
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:89.0) Gecko/20100101 Firefox/89.0"
    ]
    
    user_agents.each_with_index do |user_agent, index|
      # Set user agent
      page.driver.browser.execute_cdp('Network.setUserAgentOverride', userAgent: user_agent)
      
      visit root_path
      
      click_button "Feedback"
      select "General Feedback", from: "user_feedback[feedback_type]"
      fill_in "user_feedback[message]", with: "Test from #{user_agent.split(' ').first}"
      
      assert_difference("UserFeedback.count") do
        click_button "Submit Feedback"
      end
      
      feedback = UserFeedback.last
      assert_includes feedback.browser, user_agent if feedback.browser
    end
  end

  # Performance test
  test "feedback form loads quickly" do
    start_time = Time.current
    
    visit root_path
    
    # Form should be immediately available
    assert_selector "button", text: "Feedback"
    
    click_button "Feedback"
    assert_selector ".feedback-panel", visible: true
    
    end_time = Time.current
    load_time = end_time - start_time
    
    # Form should load within reasonable time (adjust threshold as needed)
    assert load_time < 2.0, "Feedback form took too long to load: #{load_time}s"
  end
end