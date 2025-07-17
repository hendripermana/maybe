module BalanceSheetHelper
  # Build rows for Ui::DataTableComponent.
  # This version is simplified to only render the accounts for a single account group.
  def account_table_rows(accounts, total:, group_color:)
    rows = []
    total_amount = total.amount

    accounts.each do |account|
      pct = total_amount.zero? ? 0 : (account.converted_balance / total_amount) * 100

      # Account row: Logo/Name, Weight Bar/%, and Balance
      rows << [
        content_tag(:div, class: "flex items-center gap-2") do
          concat render("accounts/logo", account: account, size: "sm", color: group_color)
          concat link_to(account.name, account_path(account),
                          class: "text-sm text-primary dark:text-white truncate hover:text-blue-500")
        end,
        render("pages/dashboard/group_weight", weight: pct, color: group_color, justify: "end"),
        content_tag(:span, format_money(account.balance_money), class: "text-sm font-mono text-right whitespace-nowrap")
      ]
    end

    rows
  end
end
