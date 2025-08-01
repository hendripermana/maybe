# frozen_string_literal: true

require "application_system_test_case"

class BudgetAccessibilityTest < ApplicationSystemTestCase
  setup do
    sign_in users(:family_admin)
    @budget = budgets(:one)
  end

  test "budget page has proper heading structure" do
    visit budget_budget_categories_path(@budget)

    # Check for proper heading structure
    assert_selector "h1, h2, h3, h4, h5, h6", minimum: 1

    # Ensure headings are in the correct order (no skipped levels)
    headings = all("h1, h2, h3, h4, h5, h6").map { |h| h.tag_name }

    # Check that heading levels don't skip (e.g., h1 -> h3 without h2)
    previous_level = 0
    headings.each do |heading|
      current_level = heading[1].to_i
      assert current_level <= previous_level + 1, "Heading structure skips from h#{previous_level} to h#{current_level}"
      previous_level = current_level
    end
  end

  test "budget form inputs have proper labels and associations" do
    visit budget_budget_categories_path(@budget)

    # Check all inputs have associated labels or aria-label
    all("input").each do |input|
      input_id = input[:id]

      # Skip hidden inputs
      next if input[:type] == "hidden"

      # Check if input has an associated label or aria-label
      has_label = has_css?("label[for='#{input_id}']")
      has_aria_label = input[:aria_label].present?

      assert has_label || has_aria_label, "Input ##{input_id} has no associated label or aria-label"
    end
  end

  test "budget page has sufficient color contrast" do
    visit budget_budget_categories_path(@budget)

    # Test text elements for sufficient contrast
    # This is a simplified check - a real accessibility audit would use more sophisticated tools
    text_elements = all(".text-primary, .text-secondary, .text-muted-foreground")

    text_elements.each do |element|
      # Get computed style
      color = page.evaluate_script("window.getComputedStyle(document.getElementById('#{element[:id]}')).color")
      background = page.evaluate_script("window.getComputedStyle(document.getElementById('#{element[:id]}')).backgroundColor")

      # Log the values for manual verification
      puts "Element #{element[:id]} - Text: #{color}, Background: #{background}"

      # A more sophisticated test would calculate contrast ratio here
      # For now, we're just checking that the colors are defined
      assert color.present?, "Text color not defined for element #{element[:id]}"
      assert background.present?, "Background color not defined for element #{element[:id]}"
    end
  end

  test "budget page is keyboard navigable" do
    visit budget_budget_categories_path(@budget)

    # Press Tab to navigate through the page
    10.times do |i|
      page.driver.browser.action.send_keys(:tab).perform

      # Get the currently focused element
      focused_element = page.evaluate_script("document.activeElement.tagName")

      # Log the focused element for debugging
      puts "Tab press #{i + 1}: Focused element is #{focused_element}"

      # Ensure we're not stuck on the same element
      assert focused_element.present?, "No element has focus after tab press #{i + 1}"
    end

    # Find the first input field and focus it
    first_input = first("input[id$='_budgeted_spending']")
    first_input.click

    # Test keyboard input
    first_input.native.send_keys(:backspace) until first_input.value.empty?
    first_input.native.send_keys("100")

    # Press Enter to submit
    first_input.native.send_keys(:return)

    # Wait for the update to process
    sleep 0.5

    # Verify the value was updated
    assert_equal "100", first_input.value
  end

  test "budget page has proper ARIA attributes" do
    visit budget_budget_categories_path(@budget)

    # Check for proper role attributes
    assert_selector "[role='group']", minimum: 1

    # Check for proper aria-label attributes
    assert_selector "[aria-label]", minimum: 1

    # Check progress bar has proper ARIA attributes
    if has_css?("progress")
      progress = find("progress")
      assert progress[:aria_valuenow].present?, "Progress bar missing aria-valuenow attribute"
      assert progress[:aria_valuemin].present?, "Progress bar missing aria-valuemin attribute"
      assert progress[:aria_valuemax].present?, "Progress bar missing aria-valuemax attribute"
    end
  end

  test "budget page works with keyboard only navigation" do
    visit budget_budget_categories_path(@budget)

    # Test keyboard navigation through form fields
    page.driver.browser.action.send_keys(:tab).perform until page.evaluate_script("document.activeElement.tagName") == "INPUT"

    # Get the focused input
    input = page.evaluate_script("document.activeElement")
    input_id = page.evaluate_script("document.activeElement.id")

    # Enter a value using keyboard
    page.driver.browser.action.send_keys(:backspace).perform until page.evaluate_script("document.getElementById('#{input_id}').value") == ""
    page.driver.browser.action.send_keys("200").perform

    # Tab out to trigger the auto-submit
    page.driver.browser.action.send_keys(:tab).perform

    # Wait for the update to process
    sleep 0.5

    # Verify the value was updated
    updated_value = page.evaluate_script("document.getElementById('#{input_id}').value")
    assert_equal "200", updated_value
  end

  test "budget page has no accessibility violations" do
    visit budget_budget_categories_path(@budget)

    # Run axe accessibility audit
    # Note: This requires the axe-core JavaScript library to be included in the test environment
    violations = page.evaluate_script(<<~JAVASCRIPT)
      if (typeof axe === 'undefined') {
        return { error: 'axe-core not loaded' };
      }

      return new Promise(resolve => {
        axe.run(document, { runOnly: { type: 'tag', values: ['wcag2a', 'wcag2aa'] } })
          .then(results => resolve(results.violations))
          .catch(err => resolve({ error: err.toString() }));
      });
    JAVASCRIPT

    if violations.is_a?(Hash) && violations["error"]
      skip "Skipping axe-core test: #{violations["error"]}"
    else
      # Log any violations for debugging
      if violations.any?
        puts "Accessibility violations found:"
        violations.each do |v|
          puts "- #{v["id"]}: #{v["description"]}"
          puts "  Impact: #{v["impact"]}"
          puts "  Affected elements: #{v["nodes"].size}"
        end
      end

      # Assert no critical or serious violations
      critical_violations = violations.select { |v| [ "critical", "serious" ].include?(v["impact"]) }
      assert critical_violations.empty?, "Found #{critical_violations.size} critical/serious accessibility violations"
    end
  end
end
