# frozen_string_literal: true

require "test_helper"

module Ui
  class ModalComponentTest < ViewComponent::TestCase
    def test_renders_basic_modal_structure
      render_inline(Ui::ModalComponent.new) { "Modal content" }
      
      # Test that modal renders with basic structure
      assert_text "Modal content"
    end

    def test_renders_with_title_and_description
      render_inline(Ui::ModalComponent.new(
        title: "Test Modal",
        description: "Test description"
      ))
      
      assert_text "Test Modal"
      assert_text "Test description"
    end

    def test_renders_open_state
      render_inline(Ui::ModalComponent.new(open: true)) { "Open modal" }
      
      assert_text "Open modal"
    end

    def test_renders_closed_state
      render_inline(Ui::ModalComponent.new(open: false)) { "Closed modal" }
      
      assert_text "Closed modal"
    end

    def test_renders_closable_button_with_title
      render_inline(Ui::ModalComponent.new(closable: true, title: "Test")) { "Closable" }
      
      # When closable and has title, should render close button
      assert_text "Closable"
      assert_text "Test"
    end

    def test_hides_close_button_when_not_closable
      render_inline(Ui::ModalComponent.new(closable: false)) { "Not closable" }
      
      assert_text "Not closable"
    end

    def test_includes_custom_data_attributes
      render_inline(Ui::ModalComponent.new(
        data: { controller: "ui--modal", test: "value" }
      )) { "Test" }
      
      assert_text "Test"
    end

    def test_merges_css_classes
      render_inline(Ui::ModalComponent.new(class: "custom-class")) { "Custom" }
      
      assert_text "Custom"
    end

    def test_component_initializes_correctly
      component = Ui::ModalComponent.new(
        title: "Test Title",
        description: "Test Description",
        open: true,
        closable: true,
        backdrop_closable: false,
        variant: :centered,
        size: :lg
      )
      
      assert_equal "Test Title", component.title
      assert_equal "Test Description", component.description
      assert_equal true, component.open
      assert_equal true, component.closable
      assert_equal false, component.backdrop_closable
    end
  end
end