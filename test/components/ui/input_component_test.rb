# frozen_string_literal: true

require "test_helper"

module Ui
  class InputComponentTest < ViewComponent::TestCase
    def test_renders_default_input
      render_inline(Ui::InputComponent.new(name: "test"))
      
      assert_selector "input[name='test']"
      assert_selector "input.input-modern"
    end

    def test_renders_with_label
      render_inline(Ui::InputComponent.new(
        name: "test",
        label: "Test Label"
      ))
      
      assert_selector "label", text: "Test Label"
      assert_selector "label[for='test']"
    end

    def test_renders_different_types
      render_inline(Ui::InputComponent.new(type: "email", name: "email"))
      assert_selector "input[type='email']"
      
      render_inline(Ui::InputComponent.new(type: "password", name: "password"))
      assert_selector "input[type='password']"
      
      render_inline(Ui::InputComponent.new(type: "number", name: "number"))
      assert_selector "input[type='number']"
    end

    def test_renders_textarea
      render_inline(Ui::InputComponent.new(type: "textarea", name: "description"))
      
      assert_selector "textarea[name='description']"
      assert_no_selector "input"
    end

    def test_renders_select
      render_inline(Ui::InputComponent.new(type: "select", name: "category")) do
        "<option value='1'>Option 1</option>".html_safe
      end
      
      assert_selector "select[name='category']"
      assert_selector "option", text: "Option 1"
    end

    def test_renders_different_variants
      render_inline(Ui::InputComponent.new(variant: :outline, name: "test"))
      assert_selector "input.border-input"
      
      render_inline(Ui::InputComponent.new(variant: :ghost, name: "test"))
      assert_selector "input.border-0"
    end

    def test_renders_different_sizes
      render_inline(Ui::InputComponent.new(size: :sm, name: "test"))
      assert_selector "input.h-8"
      
      render_inline(Ui::InputComponent.new(size: :lg, name: "test"))
      assert_selector "input.h-12"
    end

    def test_renders_required_state
      render_inline(Ui::InputComponent.new(name: "test", required: true))
      
      assert_selector "input[required]"
    end

    def test_renders_disabled_state
      render_inline(Ui::InputComponent.new(name: "test", disabled: true))
      
      assert_selector "input[disabled]"
      assert_selector "input.disabled\\:cursor-not-allowed"
    end

    def test_renders_readonly_state
      render_inline(Ui::InputComponent.new(name: "test", readonly: true))
      
      assert_selector "input[readonly]"
    end

    def test_renders_with_error
      render_inline(Ui::InputComponent.new(
        name: "test",
        error: "This field is required"
      ))
      
      assert_selector "p.text-destructive", text: "This field is required"
      assert_selector "input.text-destructive"
    end

    def test_renders_with_help_text
      render_inline(Ui::InputComponent.new(
        name: "test",
        help_text: "Enter your information here"
      ))
      
      assert_selector "p.text-muted-foreground", text: "Enter your information here"
    end

    def test_includes_data_attributes
      render_inline(Ui::InputComponent.new(
        name: "test",
        data: { test: "value" }
      ))
      
      assert_selector "input[data-test='value']"
    end

    def test_merges_css_classes
      render_inline(Ui::InputComponent.new(
        name: "test",
        class: "custom-class"
      ))
      
      assert_selector "input.custom-class"
      assert_selector "input.input-modern"
    end

    def test_sets_placeholder
      render_inline(Ui::InputComponent.new(
        name: "test",
        placeholder: "Enter text here"
      ))
      
      assert_selector "input[placeholder='Enter text here']"
    end

    def test_sets_value
      render_inline(Ui::InputComponent.new(
        name: "test",
        value: "test value"
      ))
      
      assert_selector "input[value='test value']"
    end
  end
end