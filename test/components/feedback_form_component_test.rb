require "test_helper"

class FeedbackFormComponentTest < ViewComponent::TestCase
  test "renders feedback form" do
    render_inline(FeedbackFormComponent.new(current_page: "/dashboard"))
    
    assert_selector "form.space-y-4"
    assert_selector "select[name='user_feedback[feedback_type]']"
    assert_selector "textarea[name='user_feedback[message]']"
    assert_selector "input[type='hidden'][name='user_feedback[page]'][value='/dashboard']"
  end
  
  test "includes current theme in hidden field" do
    component = FeedbackFormComponent.new(current_page: "/dashboard")
    allow(component).to receive(:current_theme).and_return("dark")
    
    render_inline(component)
    
    assert_selector "input[type='hidden'][name='user_feedback[theme]'][value='dark']"
  end
  
  test "includes browser info in hidden field" do
    component = FeedbackFormComponent.new(current_page: "/dashboard")
    allow(component).to receive(:browser_info).and_return("Mozilla/5.0")
    
    render_inline(component)
    
    assert_selector "input[type='hidden'][name='user_feedback[browser]'][value='Mozilla/5.0']"
  end
  
  test "renders feedback types from model" do
    render_inline(FeedbackFormComponent.new(current_page: "/dashboard"))
    
    UserFeedback.feedback_types.keys.each do |type|
      assert_selector "option[value='#{type}']"
    end
  end
end