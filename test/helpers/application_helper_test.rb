# frozen_string_literal: true

require "test_helper"

class ApplicationHelperTest < ActionView::TestCase
  test "page_active? returns true for exact current page" do
    def request
      @request ||= OpenStruct.new(path: "/transactions")
    end

    def current_page?(path)
      path == request.path
    end

    assert page_active?("/transactions")
  end

  test "page_active? returns true for parent path" do
    def request
      @request ||= OpenStruct.new(path: "/transactions/123")
    end

    def current_page?(path)
      path == request.path
    end

    assert page_active?("/transactions")
    refute page_active?("/transactions", true) # exact match
  end

  test "page_active? returns false for unrelated path" do
    def request
      @request ||= OpenStruct.new(path: "/transactions")
    end

    def current_page?(path)
      path == request.path
    end

    refute page_active?("/budgets")
  end

  test "page_active? handles root path correctly" do
    def request
      @request ||= OpenStruct.new(path: "/")
    end

    def current_page?(path)
      path == request.path
    end

    assert page_active?("/")
    
    # Change to a different path
    def request
      @request ||= OpenStruct.new(path: "/transactions")
    end
    
    refute page_active?("/")
  end
end