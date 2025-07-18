# frozen_string_literal: true

module BudgetTestHelper
  # Helper method to create a budget with a specified number of categories
  def create_test_budget_with_categories(family, count = 10)
    budget = Budget.create!(
      family: family,
      name: "Test Budget #{Time.current.to_i}",
      budgeted_spending: 5000,
      expected_income: 6000,
      month: Date.current.beginning_of_month
    )
    
    # Create categories
    count.times do |i|
      category = Category.create!(
        name: "Test Category #{i}",
        color: "##{SecureRandom.hex(3)}",
        family: family
      )
      
      budget.budget_categories.create!(
        category: category,
        budgeted_spending: rand(100..500)
      )
    end
    
    budget
  end
  
  # Helper method to extract numeric amount from formatted currency string
  def extract_amount_from_text(text)
    text.gsub(/[^\d.]/, '').to_f
  end
  
  # Helper method to verify budget calculations
  def verify_budget_calculations(budget)
    # Calculate total budgeted spending from budget categories
    total_from_categories = budget.budget_categories.sum(:budgeted_spending)
    
    # Calculate remaining amount
    remaining = budget.budgeted_spending - total_from_categories
    
    # Calculate allocation percentage
    allocation_percentage = (total_from_categories / budget.budgeted_spending) * 100
    
    {
      total_budgeted: total_from_categories,
      remaining: remaining,
      allocation_percentage: allocation_percentage
    }
  end
  
  # Helper method to simulate rapid budget category updates
  def perform_rapid_budget_updates(budget, count = 5)
    start_time = Time.current
    
    budget.budget_categories.limit(count).each_with_index do |category, index|
      category.update(budgeted_spending: (index + 1) * 100)
    end
    
    Time.current - start_time
  end
  
  # Helper method to check accessibility of budget elements
  def check_budget_accessibility(page)
    issues = []
    
    # Check for proper heading structure
    headings = page.all("h1, h2, h3, h4, h5, h6").map { |h| h.tag_name }
    previous_level = 0
    
    headings.each do |heading|
      current_level = heading[1].to_i
      if current_level > previous_level + 1
        issues << "Heading structure skips from h#{previous_level} to h#{current_level}"
      end
      previous_level = current_level
    end
    
    # Check inputs have labels
    page.all("input").each do |input|
      input_id = input[:id]
      
      # Skip hidden inputs
      next if input[:type] == "hidden"
      
      # Check if input has an associated label or aria-label
      has_label = page.has_css?("label[for='#{input_id}']")
      has_aria_label = input[:aria_label].present?
      
      if !has_label && !has_aria_label
        issues << "Input ##{input_id} has no associated label or aria-label"
      end
    end
    
    issues
  end
end