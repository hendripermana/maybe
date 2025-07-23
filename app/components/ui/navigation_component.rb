# frozen_string_literal: true

module Ui
  # Modern navigation component with consistent styling and active state indicators
  # Provides unified navigation experience across all pages
  class NavigationComponent < ViewComponent::Base
    attr_reader :current_path, :items, :variant

    VARIANTS = {
      desktop: "desktop",
      mobile: "mobile",
      sidebar: "sidebar"
    }.freeze

    def initialize(current_path:, variant: :desktop, **options)
      super(**options)
      @current_path = current_path
      @variant = VARIANTS[variant.to_sym] || VARIANTS[:desktop]
      @items = []
    end

    def before_render
      @items = build_navigation_items
    end

    private

    def build_navigation_items
      [
        { 
          name: "Home", 
          path: helpers.root_path, 
          icon: "pie-chart", 
          icon_custom: false, 
          active: active?(helpers.root_path),
          color: "blue"
        },
        { 
          name: "Transactions", 
          path: helpers.transactions_path, 
          icon: "credit-card", 
          icon_custom: false, 
          active: active?(helpers.transactions_path),
          color: "green"
        },
        { 
          name: "Budgets", 
          path: helpers.budgets_path, 
          icon: "map", 
          icon_custom: false, 
          active: active?(helpers.budgets_path),
          color: "purple"
        },
        { 
          name: "Assistant", 
          path: helpers.chats_path, 
          icon: "icon-assistant", 
          icon_custom: true, 
          active: active?(helpers.chats_path),
          color: "amber",
          mobile_only: true
        }
      ]
    end

    def active?(path)
      helpers.page_active?(path)
    end

    def desktop_items
      items.reject { |item| item[:mobile_only] }
    end

    def mobile_items
      items
    end

    def sidebar_items
      items.reject { |item| item[:mobile_only] }
    end

    def color_classes(item)
      case item[:color]
      when "blue"
        {
          bg_active: "bg-blue-500",
          bg_inactive: "bg-blue-50 [data-theme=dark]:bg-blue-900/10", 
          text_active: "text-white",
          text_inactive: "text-blue-500 [data-theme=dark]:text-blue-400",
          text_inactive_label: "text-blue-600 [data-theme=dark]:text-blue-400",
          hover: "hover:bg-blue-100 [data-theme=dark]:hover:bg-blue-900/20",
          shadow_active: "shadow-blue-500/30",
          shadow_inactive: "shadow-blue-200/20 [data-theme=dark]:shadow-blue-800/10"
        }
      when "green"
        {
          bg_active: "bg-green-500",
          bg_inactive: "bg-green-50 [data-theme=dark]:bg-green-900/10",
          text_active: "text-white", 
          text_inactive: "text-green-500 [data-theme=dark]:text-green-400",
          text_inactive_label: "text-green-600 [data-theme=dark]:text-green-400",
          hover: "hover:bg-green-100 [data-theme=dark]:hover:bg-green-900/20",
          shadow_active: "shadow-green-500/30",
          shadow_inactive: "shadow-green-200/20 [data-theme=dark]:shadow-green-800/10"
        }
      when "purple"
        {
          bg_active: "bg-purple-500",
          bg_inactive: "bg-purple-50 [data-theme=dark]:bg-purple-900/10",
          text_active: "text-white",
          text_inactive: "text-purple-500 [data-theme=dark]:text-purple-400", 
          text_inactive_label: "text-purple-600 [data-theme=dark]:text-purple-400",
          hover: "hover:bg-purple-100 [data-theme=dark]:hover:bg-purple-900/20",
          shadow_active: "shadow-purple-500/30",
          shadow_inactive: "shadow-purple-200/20 [data-theme=dark]:shadow-purple-800/10"
        }
      when "amber"
        {
          bg_active: "bg-amber-500",
          bg_inactive: "bg-amber-50 [data-theme=dark]:bg-amber-900/10",
          text_active: "text-white",
          text_inactive: "text-amber-500 [data-theme=dark]:text-amber-400", 
          text_inactive_label: "text-amber-600 [data-theme=dark]:text-amber-400",
          hover: "hover:bg-amber-100 [data-theme=dark]:hover:bg-amber-900/20",
          shadow_active: "shadow-amber-500/30",
          shadow_inactive: "shadow-amber-200/20 [data-theme=dark]:shadow-amber-800/10"
        }
      else
        {
          bg_active: "bg-gray-500",
          bg_inactive: "bg-gray-50 [data-theme=dark]:bg-gray-900/10",
          text_active: "text-white",
          text_inactive: "text-gray-500 [data-theme=dark]:text-gray-400",
          text_inactive_label: "text-gray-600 [data-theme=dark]:text-gray-400",
          hover: "hover:bg-gray-100 [data-theme=dark]:hover:bg-gray-900/20",
          shadow_active: "shadow-gray-500/30",
          shadow_inactive: "shadow-gray-200/20 [data-theme=dark]:shadow-gray-800/10"
        }
      end
    end
  end
end