# frozen_string_literal: true

require "test_helper"

module Ui
  class NavigationItemComponentTest < ViewComponent::TestCase
    def test_renders_default_navigation_item
      color_classes = {
        bg_active: "bg-blue-500",
        bg_inactive: "bg-blue-50",
        text_active: "text-white",
        text_inactive: "text-blue-500",
        text_inactive_label: "text-blue-600",
        hover: "hover:bg-blue-100",
        shadow_active: "shadow-blue-500/30",
        shadow_inactive: "shadow-blue-200/20"
      }

      render_inline(NavigationItemComponent.new(
        name: "Home",
        path: "/",
        icon: "home",
        icon_custom: false,
        active: false,
        color_classes: color_classes
      ))

      assert_selector "a[role='menuitem']"
      assert_selector ".nav-item-modern"
      assert_text "Home"
      refute_selector "a[aria-current='page']"
    end

    def test_renders_active_navigation_item
      color_classes = {
        bg_active: "bg-blue-500",
        bg_inactive: "bg-blue-50",
        text_active: "text-white",
        text_inactive: "text-blue-500",
        text_inactive_label: "text-blue-600",
        hover: "hover:bg-blue-100",
        shadow_active: "shadow-blue-500/30",
        shadow_inactive: "shadow-blue-200/20"
      }

      render_inline(NavigationItemComponent.new(
        name: "Home",
        path: "/",
        icon: "home",
        icon_custom: false,
        active: true,
        color_classes: color_classes
      ))

      assert_selector "a[role='menuitem'][aria-current='page']"
      assert_selector ".nav-item-modern"
      assert_text "Home"
    end

    def test_renders_sidebar_navigation_item
      color_classes = {
        bg_active: "bg-blue-500",
        bg_inactive: "bg-blue-50",
        text_active: "text-white",
        text_inactive: "text-blue-500",
        text_inactive_label: "text-blue-600",
        hover: "hover:bg-blue-100",
        shadow_active: "shadow-blue-500/30",
        shadow_inactive: "shadow-blue-200/20"
      }

      render_inline(NavigationItemComponent.new(
        name: "Home",
        path: "/",
        icon: "home",
        icon_custom: false,
        active: false,
        color_classes: color_classes,
        variant: "sidebar"
      ))

      assert_selector "a[role='menuitem']"
      refute_selector ".nav-item-modern"
      assert_text "Home"
    end
  end
end
