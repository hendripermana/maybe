# frozen_string_literal: true

module Ui
  class NavigationComponentPreview < ViewComponent::Preview
    # @param variant select { choices: [desktop, mobile, sidebar] }
    def default(variant: :desktop)
      render Ui::NavigationComponent.new(
        current_path: "/",
        variant: variant
      )
    end

    # @param current_path select { choices: [/, /transactions, /budgets, /chats] }
    def with_active_item(current_path: "/")
      render Ui::NavigationComponent.new(
        current_path: current_path,
        variant: :desktop
      )
    end

    # Demonstrates keyboard navigation
    def keyboard_navigation
      render_with_template(locals: {
        component: Ui::NavigationComponent.new(
          current_path: "/",
          variant: :desktop
        )
      })
    end
  end
end
