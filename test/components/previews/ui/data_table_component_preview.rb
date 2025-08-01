# frozen_string_literal: true

module Ui
  class DataTableComponentPreview < ViewComponent::Preview
    def default
      headers = {
        "Name" => "font-medium",
        "Email" => "",
        "Role" => "text-center",
        "Status" => "text-center"
      }

      rows = [
        [ "John Doe", "john@example.com", "Admin", "Active" ],
        [ "Jane Smith", "jane@example.com", "User", "Active" ],
        [ "Bob Johnson", "bob@example.com", "User", "Inactive" ]
      ]

      render Ui::DataTableComponent.new(
        headers: headers,
        rows: rows
      )
    end

    def empty_table
      headers = {
        "Name" => "",
        "Email" => "",
        "Role" => ""
      }

      render Ui::DataTableComponent.new(
        headers: headers,
        rows: [],
        empty_message: "No users found"
      )
    end

    def with_custom_cells
      headers = {
        "Account" => "font-medium",
        "Balance" => "text-right",
        "Status" => "text-center",
        "Actions" => "text-center"
      }

      rows = [
        {
          cells: [
            "Checking Account",
            "$2,500.00",
            content_tag(:span, "Active", class: "px-2 py-1 text-xs bg-green-100 text-green-800 rounded-full"),
            content_tag(:button, "Edit", class: "text-blue-600 hover:text-blue-800")
          ],
          class: "hover:bg-blue-50"
        },
        {
          cells: [
            "Savings Account",
            "$15,750.00",
            content_tag(:span, "Active", class: "px-2 py-1 text-xs bg-green-100 text-green-800 rounded-full"),
            content_tag(:button, "Edit", class: "text-blue-600 hover:text-blue-800")
          ]
        }
      ]

      render Ui::DataTableComponent.new(
        headers: headers,
        rows: rows
      )
    end
  end
end
