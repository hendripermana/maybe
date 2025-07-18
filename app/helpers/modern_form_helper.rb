# frozen_string_literal: true

# Helper module for modern form components
module ModernFormHelper
  # Renders a modern form component
  # @param model [ActiveRecord::Base] The model to build the form for
  # @param url [String] The URL to submit the form to
  # @param method [Symbol] The HTTP method to use
  # @param options [Hash] Additional options for the form
  # @param block [Block] The block to render inside the form
  # @return [String] The rendered form
  def modern_form_with(model: nil, url: nil, method: :post, **options, &block)
    render Ui::FormComponent.new(
      model: model,
      url: url,
      method: method,
      **options
    ), &block
  end

  # Renders a modern form field component
  # @param form [ActionView::Helpers::FormBuilder] The form builder
  # @param field [Symbol] The field to build the input for
  # @param label [String] The label for the field
  # @param required [Boolean] Whether the field is required
  # @param tooltip [String] Optional tooltip text
  # @param options [Hash] Additional options for the field
  # @param block [Block] The block to render inside the field
  # @return [String] The rendered form field
  def modern_form_field(form:, field:, label: nil, required: false, tooltip: nil, **options, &block)
    render Ui::FormFieldComponent.new(
      form: form,
      field: field,
      label: label,
      required: required,
      tooltip: tooltip,
      **options
    ), &block
  end

  # Renders a modern input component
  # @param form [ActionView::Helpers::FormBuilder] The form builder
  # @param field [Symbol] The field to build the input for
  # @param type [Symbol] The type of input
  # @param options [Hash] Additional options for the input
  # @return [String] The rendered input
  def modern_input(form:, field:, type: :text, **options)
    render Ui::InputComponent.new(
      form: form,
      field: field,
      type: type,
      **options
    )
  end

  # Renders a modern select component
  # @param form [ActionView::Helpers::FormBuilder] The form builder
  # @param field [Symbol] The field to build the select for
  # @param options [Array] The options for the select
  # @param select_options [Hash] Additional options for the select
  # @param html_options [Hash] Additional HTML options for the select
  # @return [String] The rendered select
  def modern_select(form:, field:, options:, **html_options)
    render Ui::SelectComponent.new(
      form: form,
      field: field,
      options: options,
      **html_options
    )
  end

  # Renders a modern collection select component
  # @param form [ActionView::Helpers::FormBuilder] The form builder
  # @param field [Symbol] The field to build the select for
  # @param collection [Array] The collection to build the select from
  # @param value_method [Symbol] The method to use for option values
  # @param text_method [Symbol] The method to use for option text
  # @param options [Hash] Additional options for the select
  # @param html_options [Hash] Additional HTML options for the select
  # @return [String] The rendered select
  def modern_collection_select(form:, field:, collection:, value_method:, text_method:, **options)
    render Ui::SelectComponent.new(
      form: form,
      field: field,
      collection: collection,
      value_method: value_method,
      text_method: text_method,
      **options
    )
  end

  # Renders a modern toggle switch component
  # @param form [ActionView::Helpers::FormBuilder] The form builder
  # @param field [Symbol] The field to build the toggle for
  # @param options [Hash] Additional options for the toggle
  # @return [String] The rendered toggle
  def modern_toggle_switch(form:, field:, **options)
    render Ui::ToggleSwitchComponent.new(
      form: form,
      field: field,
      **options
    )
  end

  # Renders a modern checkbox component
  # @param form [ActionView::Helpers::FormBuilder] The form builder
  # @param field [Symbol] The field to build the checkbox for
  # @param label_text [String] The label for the checkbox
  # @param options [Hash] Additional options for the checkbox
  # @return [String] The rendered checkbox
  def modern_checkbox(form:, field:, label_text: nil, **options)
    render Ui::CheckboxComponent.new(
      form: form,
      field: field,
      label_text: label_text,
      **options
    )
  end

  # Renders a modern radio button component
  # @param form [ActionView::Helpers::FormBuilder] The form builder
  # @param field [Symbol] The field to build the radio button for
  # @param value [String] The value for the radio button
  # @param label_text [String] The label for the radio button
  # @param options [Hash] Additional options for the radio button
  # @return [String] The rendered radio button
  def modern_radio_button(form:, field:, value:, label_text: nil, **options)
    render Ui::RadioButtonComponent.new(
      form: form,
      field: field,
      value: value,
      label_text: label_text,
      **options
    )
  end

  # Renders a modern radio group component
  # @param form [ActionView::Helpers::FormBuilder] The form builder
  # @param field [Symbol] The field to build the radio group for
  # @param legend [String] The legend for the radio group
  # @param options [Hash] Additional options for the radio group
  # @param block [Block] The block to render inside the radio group
  # @return [String] The rendered radio group
  def modern_radio_group(form:, field:, legend: nil, **options, &block)
    render Ui::RadioGroupComponent.new(
      form: form,
      field: field,
      legend: legend,
      **options
    ), &block
  end

  # Renders a modern textarea component
  # @param form [ActionView::Helpers::FormBuilder] The form builder
  # @param field [Symbol] The field to build the textarea for
  # @param options [Hash] Additional options for the textarea
  # @return [String] The rendered textarea
  def modern_textarea(form:, field:, **options)
    render Ui::TextareaComponent.new(
      form: form,
      field: field,
      **options
    )
  end

  # Renders a modern form feedback component
  # @param message [String] The message to display
  # @param variant [Symbol] The variant of the feedback
  # @param options [Hash] Additional options for the feedback
  # @return [String] The rendered feedback
  def modern_form_feedback(message:, variant: :info, **options)
    render Ui::FormFeedbackComponent.new(
      message: message,
      variant: variant,
      **options
    )
  end
end