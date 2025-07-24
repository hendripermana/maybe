require "application_system_test_case"

class FeedbackFormTest < ApplicationSystemTestCase
  setup do
    @user = users(:regular_user)
    sign_in @user
  end
  
  test "feedback form is accessible from any page" do
    visit root_path
    
    assert_selector "button[data-action='click->feedback-form#toggleForm']"
  end
  
  test "can open and close feedback form" do
    visit root_path
    
    # Open form
    find("button[data-action='click->feedback-form#toggleForm']").click
    assert_selector "form[data-feedback-form-target='form']", visible: true
    
    # Close form with cancel button
    click_button "Cancel"
    assert_selector "form[data-feedback-form-target='form']", visible: false
    
    # Open form again
    find("button[data-action='click->feedback-form#toggleForm']").click
    assert_selector "form[data-feedback-form-target='form']", visible: true
    
    # Close form by clicking outside
    find("main").click
    assert_selector "form[data-feedback-form-target='form']", visible: false
  end
  
  test "can submit feedback" do
    visit root_path
    
    # Open form
    find("button[data-action='click->feedback-form#toggleForm']").click
    
    # Fill in form
    select "Bug Report", from: "feedback-type"
    fill_in "feedback-message", with: "This is a test feedback"
    
    # Submit form
    click_button "Submit Feedback"
    
    # Check for success message
    assert_selector "[data-feedback-form-target='successMessage']", text: "Thank you for your feedback!"
    
    # Verify the feedback was saved
    feedback = UserFeedback.last
    assert_equal "bug_report", feedback.feedback_type
    assert_equal "This is a test feedback", feedback.message
    assert_equal @user, feedback.user
  end
  
  test "shows validation errors" do
    visit root_path
    
    # Open form
    find("button[data-action='click->feedback-form#toggleForm']").click
    
    # Submit without filling required fields
    click_button "Submit Feedback"
    
    # Check for error message
    assert_selector "[data-feedback-form-target='errorMessage']", text: "Please select a feedback type"
    
    # Fill type but not message
    select "Bug Report", from: "feedback-type"
    click_button "Submit Feedback"
    
    # Check for error message
    assert_selector "[data-feedback-form-target='errorMessage']", text: "Please enter your feedback"
  end
  
  test "feedback form works in different themes" do
    # Test in light theme
    visit root_path
    page.execute_script("document.documentElement.setAttribute('data-theme', 'light')")
    
    find("button[data-action='click->feedback-form#toggleForm']").click
    assert_selector "form[data-feedback-form-target='form']", visible: true
    assert_equal "light", find("input[name='user_feedback[theme]']", visible: false).value
    
    click_button "Cancel"
    
    # Test in dark theme
    page.execute_script("document.documentElement.setAttribute('data-theme', 'dark')")
    
    find("button[data-action='click->feedback-form#toggleForm']").click
    assert_selector "form[data-feedback-form-target='form']", visible: true
    assert_equal "dark", find("input[name='user_feedback[theme]']", visible: false).value
  end
  
  test "feedback form is responsive" do
    # Test on mobile viewport
    page.driver.browser.manage.window.resize_to(375, 667) # iPhone 8 size
    
    visit root_path
    find("button[data-action='click->feedback-form#toggleForm']").click
    assert_selector "form[data-feedback-form-target='form']", visible: true
    
    # Form should fit within viewport
    form = find("div[data-feedback-form-target='panel']")
    form_right = form.rect.x + form.rect.width
    assert form_right <= page.driver.browser.manage.window.size.width, 
      "Form extends beyond viewport width"
    
    click_button "Cancel"
    
    # Test on tablet viewport
    page.driver.browser.manage.window.resize_to(768, 1024) # iPad size
    
    find("button[data-action='click->feedback-form#toggleForm']").click
    assert_selector "form[data-feedback-form-target='form']", visible: true
    
    # Form should fit within viewport
    form = find("div[data-feedback-form-target='panel']")
    form_right = form.rect.x + form.rect.width
    assert form_right <= page.driver.browser.manage.window.size.width, 
      "Form extends beyond viewport width"
    
    click_button "Cancel"
    
    # Reset to desktop size
    page.driver.browser.manage.window.resize_to(1280, 800)
  end
end