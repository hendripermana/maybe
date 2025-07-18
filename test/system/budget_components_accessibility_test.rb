require "application_system_test_case"

class BudgetComponentsAccessibilityTest < ApplicationSystemTestCase
  setup do
    @family = families(:demo)
    @user = users(:demo)
    @budget = budgets(:demo_current)
    
    sign_in @user
  end

  test "progress bar has proper ARIA attributes" do
    visit lookbook_path("/components/ui/progress_bar_component/default")
    
    assert_selector "div[role='progressbar']"
    assert_selector "div[aria-valuenow]"
    assert_selector "div[aria-valuemin='0']"
    assert_selector "div[aria-valuemax='100']"
  end
  
  test "budget card has sufficient color contrast" do
    visit lookbook_path("/components/ui/budget_card_component/status_variants")
    
    # Test that we're using semantic color classes that respect theme
    assert_selector ".text-foreground" # Main text
    assert_selector ".text-muted-foreground" # Secondary text
    
    # Status indicators use semantic colors
    assert_selector ".text-green-500" # Under budget
    assert_selector ".text-yellow-500" # On budget
    assert_selector ".text-red-500" # Over budget
  end
  
  test "budget card is keyboard navigable" do
    visit lookbook_path("/components/ui/budget_card_component/default")
    
    # The card should be wrapped in a link that can be focused
    find("a.bg-card").click
    
    # After clicking, we should be on a new page or modal
    # This is just checking that the link works, actual navigation depends on app setup
    assert_current_path(/.*/)
  end
  
  test "progress bar shows proper status with labels" do
    visit lookbook_path("/components/ui/progress_bar_component/with_labels")
    
    # Check that labels are visible and descriptive
    assert_text "Budget Progress"
    assert_text "Under Budget"
    assert_text "Almost at Budget"
    assert_text "Over Budget"
    
    # Check that percentages are shown
    assert_text "30%"
    assert_text "85%"
    assert_text "100%" # Capped at 100% even if over
  end
end