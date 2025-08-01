# frozen_string_literal: true

require "test_helper"

class Ui::AlertComponentTest < ViewComponent::TestCase
  def test_renders_default_alert
    render_inline(Ui::AlertComponent.new) { "Alert message" }

    assert_text "Alert message"
    assert_selector ".bg-gray-50"
  end

  def test_renders_info_alert
    render_inline(Ui::AlertComponent.new(variant: :info)) { "Info message" }

    assert_text "Info message"
    assert_selector ".bg-blue-50"
  end

  def test_renders_success_alert
    render_inline(Ui::AlertComponent.new(variant: :success)) { "Success message" }

    assert_text "Success message"
    assert_selector ".bg-green-50"
  end

  def test_renders_warning_alert
    render_inline(Ui::AlertComponent.new(variant: :warning)) { "Warning message" }

    assert_text "Warning message"
    assert_selector ".bg-yellow-50"
  end

  def test_renders_destructive_alert
    render_inline(Ui::AlertComponent.new(variant: :destructive)) { "Error message" }

    assert_text "Error message"
    assert_selector ".bg-red-50"
  end

  def test_renders_with_title
    render_inline(Ui::AlertComponent.new(title: "Alert Title")) { "Alert message" }

    assert_text "Alert Title"
    assert_text "Alert message"
    assert_selector "h3", text: "Alert Title"
  end

  def test_renders_dismissible_alert
    render_inline(Ui::AlertComponent.new(dismissible: true)) { "Dismissible alert" }

    assert_text "Dismissible alert"
    assert_selector "button[aria-label='Dismiss']"
    assert_selector "[data-action='click->ui--alert#dismiss']"
  end

  def test_renders_different_sizes
    render_inline(Ui::AlertComponent.new(size: :sm)) { "Small alert" }
    assert_selector ".p-3"

    render_inline(Ui::AlertComponent.new(size: :md)) { "Medium alert" }
    assert_selector ".p-4"

    render_inline(Ui::AlertComponent.new(size: :lg)) { "Large alert" }
    assert_selector ".p-5"
  end
end
