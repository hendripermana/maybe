# frozen_string_literal: true

require "test_helper"

module Ui
  class BreadcrumbsComponentTest < ViewComponent::TestCase
    def test_renders_breadcrumbs
      breadcrumbs = [
        ["Home", "/"],
        ["Transactions", "/transactions"],
        ["Details", nil]
      ]
      
      render_inline(BreadcrumbsComponent.new(breadcrumbs: breadcrumbs))
      
      assert_selector "nav[aria-label='Breadcrumb']"
      assert_selector "ol li", count: 3
      assert_selector "a", text: "Home"
      assert_selector "a", text: "Transactions"
      assert_selector "span[aria-current='page']", text: "Details"
    end
    
    def test_renders_empty_breadcrumbs
      render_inline(BreadcrumbsComponent.new(breadcrumbs: []))
      
      assert_selector "nav[aria-label='Breadcrumb']"
      assert_selector "ol"
      refute_selector "li"
    end
    
    def test_renders_single_breadcrumb
      breadcrumbs = [["Home", nil]]
      
      render_inline(BreadcrumbsComponent.new(breadcrumbs: breadcrumbs))
      
      assert_selector "nav[aria-label='Breadcrumb']"
      assert_selector "ol li", count: 1
      assert_selector "span[aria-current='page']", text: "Home"
    end
    
    def test_renders_chevron_separators
      breadcrumbs = [
        ["Home", "/"],
        ["Transactions", nil]
      ]
      
      render_inline(BreadcrumbsComponent.new(breadcrumbs: breadcrumbs))
      
      # The second item should have a chevron before it
      assert_selector "li:nth-child(2) svg"
    end
  end
end