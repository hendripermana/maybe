# frozen_string_literal: true

module Ui
  class BreadcrumbsComponentPreview < ViewComponent::Preview
    def default
      render Ui::BreadcrumbsComponent.new(
        breadcrumbs: [
          [ "Home", "/" ],
          [ "Transactions", "/transactions" ],
          [ "Details", nil ]
        ]
      )
    end

    def with_multiple_levels
      render Ui::BreadcrumbsComponent.new(
        breadcrumbs: [
          [ "Home", "/" ],
          [ "Settings", "/settings" ],
          [ "Security", "/settings/security" ],
          [ "Two-Factor Authentication", nil ]
        ]
      )
    end

    def empty
      render Ui::BreadcrumbsComponent.new(
        breadcrumbs: []
      )
    end
  end
end
