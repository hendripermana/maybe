# frozen_string_literal: true

require "test_helper"

class Ui::CheckboxComponentTest < ViewComponent::TestCase
  include ComponentTestingSuiteHelper

  def test_renders_checkbox
    render_inline(Ui::CheckboxComponent.new(name: "terms"))

    assert_selector "input[type='checkbox'][name='terms']"
  end

  def test_renders_checkbox_with_label
    render_inline(Ui::CheckboxComponent.new(name: "terms", label: "Accept terms"))

    assert_selector "input[type='checkbox'][name='terms']"
    assert_selector "label", text: "Accept terms"
  end

  def test_renders_checked_checkbox
    render_inline(Ui::CheckboxComponent.new(name: "terms", checked: true))

    assert_selector "input[type='checkbox'][name='terms'][checked]"
  end

  def test_renders_disabled_checkbox
    render_inline(Ui::CheckboxComponent.new(name: "terms", disabled: true))

    assert_selector "input[type='checkbox'][name='terms'][disabled]"
  end

  def test_renders_checkbox_with_value
    render_inline(Ui::CheckboxComponent.new(name: "terms", value: "accepted"))

    assert_selector "input[type='checkbox'][name='terms'][value='accepted']"
  end

  def test_renders_checkbox_with_help_text
    render_inline(Ui::CheckboxComponent.new(
      name: "terms",
      label: "Accept terms",
      help_text: "You must accept the terms to continue"
    ))

    assert_selector "input[type='checkbox'][name='terms']"
    assert_selector "label", text: "Accept terms"
    assert_text "You must accept the terms to continue"
  end

  def test_renders_checkbox_with_error
    render_inline(Ui::CheckboxComponent.new(
      name: "terms",
      label: "Accept terms",
      error: "You must accept the terms"
    ))

    assert_selector "input[type='checkbox'][name='terms']"
    assert_selector ".text-destructive", text: "You must accept the terms"
  end

  def test_renders_required_checkbox
    render_inline(Ui::CheckboxComponent.new(
      name: "terms",
      label: "Accept terms",
      required: true
    ))

    assert_selector "input[type='checkbox'][name='terms'][required]"
    assert_selector "label", text: /Accept terms \*/
  end

  def test_theme_switching
    test_component_comprehensively(
      Ui::CheckboxComponent.new(name: "terms", label: "Accept terms"),
      interactions: [ :hover, :focus ]
    )
  end

  def test_accessibility
    render_inline(Ui::CheckboxComponent.new(
      name: "terms",
      label: "Accept terms",
      aria: { describedby: "terms-description" }
    ))

    assert_selector "input[type='checkbox'][aria-describedby='terms-description']"
  end

  def test_renders_with_custom_class
    render_inline(Ui::CheckboxComponent.new(
      name: "terms",
      class: "custom-class"
    ))

    assert_selector ".custom-class"
  end

  def test_renders_with_custom_id
    render_inline(Ui::CheckboxComponent.new(
      name: "terms",
      id: "custom-id"
    ))

    assert_selector "#custom-id"
  end
end
