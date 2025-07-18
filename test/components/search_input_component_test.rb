require "test_helper"

class SearchInputComponentTest < ViewComponent::TestCase
  include ActionView::Helpers::FormHelper
  
  setup do
    @form = ActionView::Helpers::FormBuilder.new(
      :q, 
      nil, 
      ActionView::Base.new, 
      {}
    )
  end

  test "renders search input with default placeholder" do
    render_inline(SearchInputComponent.new(form: @form, name: :search))
    
    assert_selector "input[placeholder='Search...']"
    assert_selector "input[data-auto-submit-form-target='auto']"
  end

  test "renders search input with custom placeholder" do
    render_inline(SearchInputComponent.new(
      form: @form, 
      name: :search, 
      placeholder: "Find transactions..."
    ))
    
    assert_selector "input[placeholder='Find transactions...']"
  end

  test "renders search input with value" do
    render_inline(SearchInputComponent.new(
      form: @form, 
      name: :search, 
      value: "groceries"
    ))
    
    assert_selector "input[value='groceries']"
  end

  test "renders search input without auto-submit" do
    render_inline(SearchInputComponent.new(
      form: @form, 
      name: :search, 
      auto_submit: false
    ))
    
    assert_no_selector "input[data-auto-submit-form-target='auto']"
  end
end