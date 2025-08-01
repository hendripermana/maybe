require "test_helper"
require "application_system_test_case"

class ComponentAccessibilityAudit < ApplicationSystemTestCase
  include AccessibilityTestHelper

  # List of all components to test
  COMPONENTS_TO_TEST = [
    # Base components
    "ButtonComponent",
    "AlertComponent",
    "CardComponent",
    "DialogComponent",
    "DisclosureComponent",
    "LinkComponent",
    "MenuComponent",
    "SearchInputComponent",
    "TabsComponent",
    "ToggleComponent",
    "TransactionItemComponent",

    # UI components
    "Ui::AccountCardComponent",
    "Ui::AlertComponent",
    "Ui::AvatarComponent",
    "Ui::BadgeComponent",
    "Ui::BalanceDisplayComponent",
    "Ui::BudgetCardComponent",
    "Ui::ButtonComponent",
    "Ui::CardComponent",
    "Ui::CheckboxComponent",
    "Ui::DataTableComponent",
    "Ui::FormComponent",
    "Ui::FormFieldComponent",
    "Ui::IconComponent",
    "Ui::InputComponent",
    "Ui::ModalComponent",
    "Ui::ProgressBarComponent",
    "Ui::RadioButtonComponent",
    "Ui::RadioGroupComponent",
    "Ui::SelectComponent",
    "Ui::SeparatorComponent",
    "Ui::SettingsNavComponent",
    "Ui::SkeletonComponent",
    "Ui::TextareaComponent",
    "Ui::ThemeToggleComponent",
    "Ui::TooltipComponent",
    "Ui::TransactionBadgeComponent",
    "Ui::TransactionFormComponent"
  ]

  # Test each component for accessibility in both themes
  def test_component_accessibility
    visit lookbook_path

    # Test each component
    COMPONENTS_TO_TEST.each do |component_name|
      # Navigate to component preview
      component_slug = component_name.underscore.tr("/", "_")
      visit "/lookbook/inspect/#{component_slug}/default"

      # Test in light theme
      assert_no_accessibility_violations

      # Test in dark theme
      if page.has_selector?('[data-testid="theme-toggle"]')
        find('[data-testid="theme-toggle"]').click
        assert_no_accessibility_violations
      end

      # Log successful test
      puts "✓ #{component_name} passes accessibility tests"
    end
  end

  # Test color contrast for all components
  def test_component_color_contrast
    visit lookbook_path

    COMPONENTS_TO_TEST.each do |component_name|
      # Navigate to component preview
      component_slug = component_name.underscore.tr("/", "_")
      visit "/lookbook/inspect/#{component_slug}/default"

      # Test in light theme
      test_color_contrast_on_page

      # Test in dark theme
      if page.has_selector?('[data-testid="theme-toggle"]')
        find('[data-testid="theme-toggle"]').click
        test_color_contrast_on_page
      end

      # Log successful test
      puts "✓ #{component_name} passes color contrast tests"
    end
  end

  # Test keyboard navigation for all components
  def test_component_keyboard_navigation
    visit lookbook_path

    COMPONENTS_TO_TEST.each do |component_name|
      # Navigate to component preview
      component_slug = component_name.underscore.tr("/", "_")
      visit "/lookbook/inspect/#{component_slug}/default"

      # Find all interactive elements
      interactive_elements = page.all("button, a, [role='button'], input, select, textarea, [tabindex='0']")

      # Test keyboard navigation
      interactive_elements.each do |element|
        assert_keyboard_navigable(element)
      end

      # Log successful test
      puts "✓ #{component_name} passes keyboard navigation tests"
    end
  end

  # Test ARIA attributes for all components
  def test_component_aria_attributes
    visit lookbook_path

    COMPONENTS_TO_TEST.each do |component_name|
      # Navigate to component preview
      component_slug = component_name.underscore.tr("/", "_")
      visit "/lookbook/inspect/#{component_slug}/default"

      # Find all elements with ARIA attributes
      aria_elements = page.all("[aria-label], [aria-labelledby], [aria-describedby], [aria-hidden], [aria-expanded], [aria-haspopup], [aria-controls]")

      # Test ARIA attributes
      aria_elements.each do |element|
        assert_proper_aria_attributes(element)
      end

      # Log successful test
      puts "✓ #{component_name} passes ARIA attribute tests"
    end
  end

  private

    def test_color_contrast_on_page
      # Find all text elements
      text_elements = page.all("p, h1, h2, h3, h4, h5, h6, span, a, button, label, input, select, textarea")

      # Test color contrast for each element
      text_elements.each do |element|
        begin
          assert_sufficient_contrast(element)
        rescue Minitest::Assertion => e
          puts "Color contrast issue in #{element.tag_name} with text: #{element.text.truncate(30)}"
          raise e
        end
      end
    end

    def lookbook_path
      "/lookbook"
    end
end
