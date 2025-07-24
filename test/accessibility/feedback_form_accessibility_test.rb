require "test_helper"
require "capybara/rails"
require "axe/matchers"

class FeedbackFormAccessibilityTest < ActionDispatch::IntegrationTest
  include Capybara::DSL
  include Axe::Matchers
  
  setup do
    @user = users(:regular_user)
    sign_in @user
  end
  
  test "feedback form is accessible" do
    visit root_path
    
    # Open the feedback form
    find("button[data-action='click->feedback-form#toggleForm']").click
    
    # Run accessibility audit on the open form
    assert_accessible page, 
      :"best-practice" => { exclude: [:"duplicate-id"] },
      :wcag21a => true,
      :wcag21aa => true
  end
  
  test "feedback form button has accessible label" do
    visit root_path
    
    # Check that the feedback button has a proper accessible name
    button = find("button[data-action='click->feedback-form#toggleForm']")
    assert_not_empty button.find(".sr-only", visible: false).text
  end
  
  test "feedback form has proper focus management" do
    visit root_path
    
    # Open the form
    find("button[data-action='click->feedback-form#toggleForm']").click
    
    # Check that focus is trapped within the form
    select_element = find("select[name='user_feedback[feedback_type]']")
    textarea_element = find("textarea[name='user_feedback[message]']")
    cancel_button = find("button", text: "Cancel")
    submit_button = find("button", text: "Submit Feedback")
    
    # Tab through the form elements
    select_element.send_keys(:tab)
    assert_equal textarea_element, page.evaluate_script('document.activeElement')
    
    textarea_element.send_keys(:tab)
    assert_equal cancel_button, page.evaluate_script('document.activeElement')
    
    cancel_button.send_keys(:tab)
    assert_equal submit_button, page.evaluate_script('document.activeElement')
    
    # Tab should cycle back to the first element
    submit_button.send_keys(:tab)
    assert_equal select_element, page.evaluate_script('document.activeElement')
  end
  
  test "feedback form can be submitted with keyboard only" do
    visit root_path
    
    # Open the form
    find("button[data-action='click->feedback-form#toggleForm']").click
    
    # Fill the form using keyboard
    select_element = find("select[name='user_feedback[feedback_type]']")
    select_element.select "Bug Report"
    
    select_element.send_keys(:tab)
    page.evaluate_script('document.activeElement.value = "This is a keyboard test"')
    
    # Submit the form with Enter key
    page.evaluate_script('document.activeElement').send_keys(:tab, :tab)
    page.evaluate_script('document.activeElement').send_keys(:return)
    
    # Check for success message
    assert_selector "[data-feedback-form-target='successMessage']", text: "Thank you for your feedback!"
  end
end