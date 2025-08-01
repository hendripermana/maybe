# frozen_string_literal: true

require "test_helper"

module Ui
  class ButtonComponentTest < ComponentTestCase
    def test_renders_default_button
      render_inline(Ui::ButtonComponent.new) { "Click me" }

      assert_selector "button", text: "Click me"
      assert_selector "button.btn-modern-secondary"
    end

    def test_renders_primary_variant
      render_inline(Ui::ButtonComponent.new(variant: :primary)) { "Primary" }

      assert_selector "button.btn-modern-primary", text: "Primary"
    end

    def test_renders_different_sizes
      render_inline(Ui::ButtonComponent.new(size: :sm)) { "Small" }
      assert_selector "button.h-9"

      render_inline(Ui::ButtonComponent.new(size: :lg)) { "Large" }
      assert_selector "button.h-11"
    end

    def test_renders_disabled_state
      render_inline(Ui::ButtonComponent.new(disabled: true)) { "Disabled" }

      assert_selector "button[disabled]"
      assert_selector "button.disabled\\:pointer-events-none"
    end

    def test_renders_loading_state
      render_inline(Ui::ButtonComponent.new(loading: true)) { "Loading" }

      assert_selector "button[disabled]"
      assert_selector "svg.animate-spin"
    end

    def test_renders_full_width
      render_inline(Ui::ButtonComponent.new(full_width: true)) { "Full Width" }

      assert_selector "button.w-full"
    end

    def test_renders_as_link
      render_inline(Ui::ButtonComponent.new(href: "/test")) { "Link" }

      assert_selector "a[href='/test']", text: "Link"
      assert_no_selector "button"
    end

    def test_includes_data_attributes
      render_inline(Ui::ButtonComponent.new(data: { test: "value" })) { "Test" }

      assert_selector "button[data-test='value']"
    end

    def test_merges_css_classes
      render_inline(Ui::ButtonComponent.new(class: "custom-class")) { "Custom" }

      assert_selector "button.custom-class"
      assert_selector "button.btn-modern-secondary"
    end

    def test_theme_awareness
      component = Ui::ButtonComponent.new(variant: :primary)
      assert_component_theme_aware(component) { "Theme Test" }
    end

    def test_no_hardcoded_colors
      render_inline(Ui::ButtonComponent.new(variant: :primary)) { "Primary" }
      assert_no_hardcoded_theme_classes
    end

    def test_uses_css_variables
      render_inline(Ui::ButtonComponent.new(variant: :primary)) { "Primary" }
      assert_css_variables_used
    end

    def test_renders_in_both_themes
      component = Ui::ButtonComponent.new(variant: :primary)

      # Test light theme
      render_component_with_theme(component, theme: "light") { "Light Theme" }
      assert_selector "button.btn-modern-primary"

      # Test dark theme
      render_component_with_theme(component, theme: "dark") { "Dark Theme" }
      assert_selector "button.btn-modern-primary"
    end
  end
end
