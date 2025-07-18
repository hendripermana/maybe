require "test_helper"

class FilterBadgeComponentTest < ViewComponent::TestCase
  test "renders filter badge with label" do
    render_inline(FilterBadgeComponent.new(
      label: "Category: Food",
      param_key: "categories",
      param_value: "Food",
      clear_url: "/transactions/clear_filter?param_key=categories&param_value=Food"
    ))
    
    assert_selector ".inline-flex.items-center"
    assert_text "Category: Food"
    assert_selector "a[href='/transactions/clear_filter?param_key=categories&param_value=Food']"
  end

  test "renders filter badge with proper accessibility attributes" do
    render_inline(FilterBadgeComponent.new(
      label: "Date: Today",
      param_key: "date",
      param_value: "today",
      clear_url: "/transactions/clear_filter?param_key=date&param_value=today"
    ))
    
    assert_selector "a[aria-label='Remove Date: Today filter']"
  end
end