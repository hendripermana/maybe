class UI::BudgetCardComponentPreview < ViewComponent::Preview
  def default
    budget_category = BudgetCategory.first

    # If no budget categories exist in the database, create a mock one
    if budget_category.nil?
      budget = OpenStruct.new(id: 1)
      category = OpenStruct.new(
        id: 1,
        name: "Groceries",
        color: "#4CAF50",
        lucide_icon: "shopping-cart",
        parent_id: nil
      )

      budget_category = OpenStruct.new(
        id: 1,
        budget: budget,
        category: category,
        budgeted_spending: 20000,
        actual_spending: 15000,
        available_to_spend: 5000,
        initialized?: true,
        percent_of_budget_spent: 75,
        budgeted_spending_money: Money.new(20000, "USD"),
        actual_spending_money: Money.new(15000, "USD"),
        available_to_spend_money: Money.new(5000, "USD"),
        median_monthly_expense_money: Money.new(18000, "USD")
      )

      def budget_category.subcategory?
        false
      end
    end

    render UI::BudgetCardComponent.new(budget_category: budget_category)
  end

  def status_variants
    render_with_template(locals: {})
  end

  def with_subcategories
    render_with_template(locals: {})
  end

  def uninitialized_budget
    render_with_template(locals: {})
  end
end
