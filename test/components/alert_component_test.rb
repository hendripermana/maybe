# frozen_string_literal: true
require "test_helper"

class AlertComponentTest < ComponentTestCase
  
  test "renders alert with default options" do
    render_inline(AlertComponent.new(message: "Alert Content"))
    
    assert_selector ".flex.items-start.gap-3.p-4.rounded-lg.border"
    assert_text "Alert Content"
  end
  
  test "renders alert with different variants" do
    # Info variant (default)
    render_inline(AlertComponent.new(message: "Info Alert", variant: :info))
    assert_selector ".bg-blue-50"
    assert_text "Info Alert"
    
    # Success variant
    render_inline(AlertComponent.new(message: "Success Alert", variant: :success))
    assert_selector ".bg-green-50"
    assert_text "Success Alert"
    
    # Warning variant
    render_inline(AlertComponent.new(message: "Warning Alert", variant: :warning))
    assert_selector ".bg-yellow-50"
    assert_text "Warning Alert"
    
    # Error variant
    render_inline(AlertComponent.new(message: "Error Alert", variant: :error))
    assert_selector ".bg-red-50"
    assert_text "Error Alert"
    
    # Destructive variant
    render_inline(AlertComponent.new(message: "Destructive Alert", variant: :destructive))
    assert_selector ".bg-red-50"
    assert_text "Destructive Alert"
  end
  
  test "renders alert with proper icon" do
    render_inline(AlertComponent.new(message: "Info Alert", variant: :info))
    assert_selector "svg"
    
    render_inline(AlertComponent.new(message: "Success Alert", variant: :success))
    assert_selector "svg"
    
    render_inline(AlertComponent.new(message: "Warning Alert", variant: :warning))
    assert_selector "svg"
    
    render_inline(AlertComponent.new(message: "Error Alert", variant: :error))
    assert_selector "svg"
  end
  
  test "renders alert with proper theme awareness" do
    render_inline(AlertComponent.new(message: "Theme Alert"))
    
    assert_selector ".flex.items-start.gap-3.p-4.rounded-lg.border"
    assert_text "Theme Alert"
  end
end