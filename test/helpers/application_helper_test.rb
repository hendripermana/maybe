# frozen_string_literal: true

require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "page_active? returns true for exact current page" do
    @request = OpenStruct.new(path: "/transactions")
    stubs(:request).returns(@request)
    stubs(:current_page?).with("/transactions").returns(true)

    assert page_active?("/transactions")
  end

  test "page_active? returns true for parent path" do
    @request = OpenStruct.new(path: "/transactions/123")
    stubs(:request).returns(@request)
    stubs(:current_page?).with("/transactions").returns(false)

    assert page_active?("/transactions")
    refute page_active?("/transactions", true) # exact match
  end

  test "page_active? returns false for unrelated path" do
    @request = OpenStruct.new(path: "/transactions")
    stubs(:request).returns(@request)
    stubs(:current_page?).with("/budgets").returns(false)

    refute page_active?("/budgets")
  end

  test "page_active? handles root path correctly" do
    @request = OpenStruct.new(path: "/")
    stubs(:request).returns(@request)
    stubs(:current_page?).with("/").returns(true)

    assert page_active?("/")

    # Change to a different path
    @request = OpenStruct.new(path: "/transactions")
    stubs(:request).returns(@request)
    stubs(:current_page?).with("/").returns(false)

    refute page_active?("/")
  end
end
