# frozen_string_literal: true

require "test_helper"

module Ui
  class NavigationComponentTest < ViewComponent::TestCase
    def test_renders_desktop_navigation
      render_inline(NavigationComponent.new(current_path: "/", variant: :desktop))
      
      assert_selector "nav.sidebar-modern"
      assert_selector "ul[role='menubar']"
      assert_selector "a[aria-current='page']", text: "Home"
    end
    
    def test_renders_mobile_navigation
      render_inline(NavigationComponent.new(current_path: "/", variant: :mobile))
      
      assert_selector "nav[aria-label='Mobile Navigation']"
      assert_selector "nav[aria-label='Mobile Bottom Navigation']"
    end
    
    def test_renders_sidebar_navigation
      render_inline(NavigationComponent.new(current_path: "/", variant: :sidebar))
      
      assert_selector "nav[aria-label='Sidebar Navigation']"
    end
    
    def test_marks_active_item
      render_inline(NavigationComponent.new(current_path: "/transactions", variant: :desktop))
      
      assert_selector "a[aria-current='page']", text: "Transactions"
      refute_selector "a[aria-current='page']", text: "Home"
    end
    
    def test_includes_all_navigation_items
      render_inline(NavigationComponent.new(current_path: "/", variant: :desktop))
      
      assert_text "Home"
      assert_text "Transactions"
      assert_text "Budgets"
      
      # Assistant should not be in desktop navigation
      refute_text "Assistant"
    end
    
    def test_includes_assistant_in_mobile_navigation
      render_inline(NavigationComponent.new(current_path: "/", variant: :mobile))
      
      assert_text "Home"
      assert_text "Transactions"
      assert_text "Budgets"
      assert_text "Assistant"
    end
  end
end