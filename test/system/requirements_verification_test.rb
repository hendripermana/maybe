require "application_system_test_case"

class RequirementsVerificationTest < ApplicationSystemTestCase
  setup do
    @user = users(:family_admin)
    sign_in @user
    @requirements_status = {}
  end

  # Verify all requirements have been met
  test "verify all requirements have been met" do
    # Define requirements to verify
    requirements = [
      { id: "4.6", description: "The system SHALL provide consistent user experience across the entire application", verification_method: :verify_consistent_user_experience },
      { id: "7.1", description: "The system SHALL ensure all modernized components work together seamlessly", verification_method: :verify_component_integration },
      { id: "8.1", description: "The system SHALL pass all integration tests before deployment", verification_method: :verify_integration_tests }
    ]
    
    # Verify each requirement
    requirements.each do |requirement|
      puts "\nVerifying requirement #{requirement[:id]}: #{requirement[:description]}"
      
      # Call the verification method
      send(requirement[:verification_method])
      
      # Record requirement status
      @requirements_status[requirement[:id]] = {
        description: requirement[:description],
        status: @current_requirement_status || "Not Verified",
        issues: @current_requirement_issues || []
      }
      
      # Reset current requirement status
      @current_requirement_status = nil
      @current_requirement_issues = []
    end
    
    # Report requirements status
    report_requirements_status
    
    # Assert all requirements are met
    assert @requirements_status.values.all? { |r| r[:status] == "Met" }, "All requirements should be met"
  end
  
  private
  
  def verify_consistent_user_experience
    # Define pages to test
    pages = [
      { path: root_path, name: "Dashboard" },
      { path: transactions_path, name: "Transactions" },
      { path: budgets_path, name: "Budgets" },
      { path: settings_preferences_path, name: "Settings" }
    ]
    
    issues = []
    
    # Test theme consistency across pages
    theme_consistent = true
    
    # Start with light theme
    ensure_theme("light")
    
    pages.each do |page|
      visit page[:path]
      
      unless current_theme == "light"
        theme_consistent = false
        issues << "Theme not consistent on #{page[:name]} page (expected light, got #{current_theme})"
      end
    end
    
    # Switch to dark theme
    toggle_theme
    
    pages.each do |page|
      visit page[:path]
      
      unless current_theme == "dark"
        theme_consistent = false
        issues << "Theme not consistent on #{page[:name]} page (expected dark, got #{current_theme})"
      end
    end
    
    # Test component styling consistency across pages
    styling_consistent = true
    
    pages.each do |page|
      visit page[:path]
      
      # Check buttons for consistent styling
      all("button", visible: true).each do |button|
        unless button[:class].include?("btn-modern")
          styling_consistent = false
          issues << "Button on #{page[:name]} page missing modern styling class"
        end
      end
      
      # Check cards for consistent styling
      all(".card", visible: true).each do |card|
        unless card[:class].include?("card-modern")
          styling_consistent = false
          issues << "Card on #{page[:name]} page missing modern styling class"
        end
      end
      
      # Check inputs for consistent styling
      all("input[type='text'], input[type='email'], input[type='password'], select", visible: true).each do |input|
        unless input[:class].include?("input-modern")
          styling_consistent = false
          issues << "Input on #{page[:name]} page missing modern styling class"
        end
      end
    end
    
    # Test navigation consistency across pages
    navigation_consistent = true
    
    pages.each do |page|
      visit page[:path]
      
      # Check for navigation
      unless has_selector?("nav")
        navigation_consistent = false
        issues << "Navigation missing on #{page[:name]} page"
      end
      
      # Check for active state
      unless has_selector?("nav a[aria-current='page'], nav a.active")
        navigation_consistent = false
        issues << "Navigation active state missing on #{page[:name]} page"
      end
    end
    
    # Set requirement status
    if theme_consistent && styling_consistent && navigation_consistent
      @current_requirement_status = "Met"
    else
      @current_requirement_status = "Not Met"
      @current_requirement_issues = issues
    end
  end
  
  def verify_component_integration
    issues = []
    
    # Test modal integration
    visit root_path
    
    if has_selector?("[data-modal-trigger]")
      find("[data-modal-trigger]", match: :first).click
      
      # Verify modal opens
      unless has_selector?(".modal-dialog")
        issues << "Modal does not open when trigger is clicked"
      else
        # Verify modal can be closed
        find(".modal-close").click
        
        unless has_no_selector?(".modal-dialog")
          issues << "Modal does not close when close button is clicked"
        end
      end
    end
    
    # Test form integration
    visit new_transaction_path rescue visit transactions_path
    
    if has_selector?("form")
      # Verify form has submit button
      unless has_selector?("button[type='submit'], input[type='submit']")
        issues << "Form missing submit button"
      end
      
      # Verify form has proper validation
      if has_selector?("button[type='submit'], input[type='submit']")
        click_on "Save"
        
        unless has_selector?(".form-error, .field_with_errors")
          issues << "Form validation not working"
        end
      end
    end
    
    # Test chart integration
    visit root_path
    
    if has_selector?(".chart, [data-chart]")
      # Verify chart has content
      unless has_selector?(".chart svg, .chart canvas, [data-chart] svg, [data-chart] canvas")
        issues << "Chart missing content"
      end
    end
    
    # Test navigation integration
    visit root_path
    
    if has_selector?("nav a", text: "Transactions")
      click_link "Transactions"
      
      # Verify navigation works
      unless current_path == transactions_path
        issues << "Navigation link does not navigate to correct page"
      end
      
      # Verify active state updates
      unless has_selector?("nav a[aria-current='page'], nav a.active", text: "Transactions")
        issues << "Navigation active state does not update"
      end
    end
    
    # Set requirement status
    if issues.empty?
      @current_requirement_status = "Met"
    else
      @current_requirement_status = "Not Met"
      @current_requirement_issues = issues
    end
  end
  
  def verify_integration_tests
    # Run integration tests
    output = `bundle exec ruby -I test test/system/modernized_pages_integration_test.rb 2>&1`
    
    # Parse test results
    test_count = output.scan(/(\d+) tests, (\d+) assertions/).first
    
    if test_count
      total_tests = test_count[0].to_i
      
      failures = output.scan(/(\d+) failures, (\d+) errors/).first
      total_failures = failures ? failures[0].to_i + failures[1].to_i : 0
      
      if total_failures == 0
        @current_requirement_status = "Met"
      else
        @current_requirement_status = "Not Met"
        
        # Extract failure messages
        failure_sections = output.scan(/\d+\) Error:\n([^\n]+):\n(.*?)(?=\n\d+\) |\n$)/m)
        
        failure_sections.each do |section|
          test_name = section[0]
          error_message = section[1].strip
          
          @current_requirement_issues << "#{test_name}: #{error_message}"
        end
      end
    else
      @current_requirement_status = "Not Met"
      @current_requirement_issues << "Failed to run integration tests"
    end
  end
  
  def report_requirements_status
    puts "\n=== Requirements Verification Report ==="
    
    @requirements_status.each do |id, status|
      puts "\nRequirement #{id}: #{status[:description]}"
      puts "Status: #{status[:status]}"
      
      if status[:issues].any?
        puts "Issues:"
        status[:issues].each do |issue|
          puts "- #{issue}"
        end
      end
    end
    
    # Calculate overall status
    total_requirements = @requirements_status.size
    met_requirements = @requirements_status.values.count { |r| r[:status] == "Met" }
    
    puts "\nOverall Status: #{met_requirements}/#{total_requirements} requirements met"
    
    if met_requirements == total_requirements
      puts "All requirements have been met!"
    else
      puts "Some requirements have not been met. Please address the issues listed above."
    end
  end
end