# frozen_string_literal: true

module Ui
  # Preview for the Input component
  #
  # ## Usage Guidelines
  #
  # - Always include labels for form inputs
  # - Use the appropriate input type for the data being collected
  # - Provide clear error messages for validation failures
  # - Include help text for complex inputs
  # - Group related inputs logically
  # - Use consistent sizing within the same form
  #
  # ## Accessibility Considerations
  #
  # - Labels: All inputs have properly associated labels
  # - Error states: Clear error messages with proper ARIA attributes
  # - Required fields: Clearly indicated with both visual and programmatic markers
  # - Focus management: Visible focus states for keyboard navigation
  # - Color contrast: All text meets WCAG AA contrast requirements
  #
  # ## Theme Support
  #
  # This component uses CSS variables for theming and works in both light and dark modes.
  # All colors are derived from the theme tokens to ensure consistency.
  class InputComponentPreview < ViewComponent::Preview
    # @!group Types

    # @label Text Input
    def text_input
      render(Ui::InputComponent.new(
        label: "Username",
        type: "text",
        placeholder: "Enter your username"
      ))
    end

    # @label Email Input
    def email_input
      render(Ui::InputComponent.new(
        label: "Email Address",
        type: "email",
        placeholder: "user@example.com"
      ))
    end

    # @label Password Input
    def password_input
      render(Ui::InputComponent.new(
        label: "Password",
        type: "password",
        placeholder: "Enter your password"
      ))
    end

    # @label Number Input
    def number_input
      render(Ui::InputComponent.new(
        label: "Amount",
        type: "number",
        placeholder: "0.00",
        min: 0,
        step: 0.01
      ))
    end

    # @label Date Input
    def date_input
      render(Ui::InputComponent.new(
        label: "Date",
        type: "date"
      ))
    end

    # @label Textarea Input
    def textarea_input
      render(Ui::InputComponent.new(
        label: "Description",
        type: "textarea",
        placeholder: "Enter a description",
        rows: 4
      ))
    end

    # @label Select Input
    def select_input
      render_with_template(locals: {
        component: Ui::InputComponent.new(
          label: "Category",
          type: "select"
        )
      })
    end
    # @!endgroup

    # @!group Variants

    # @label Default
    def default_variant
      render(Ui::InputComponent.new(
        label: "Default Input",
        variant: :default,
        placeholder: "Default variant"
      ))
    end

    # @label Outline
    def outline_variant
      render(Ui::InputComponent.new(
        label: "Outline Input",
        variant: :outline,
        placeholder: "Outline variant"
      ))
    end

    # @label Ghost
    def ghost_variant
      render(Ui::InputComponent.new(
        label: "Ghost Input",
        variant: :ghost,
        placeholder: "Ghost variant"
      ))
    end

    # @label Filled
    def filled_variant
      render(Ui::InputComponent.new(
        label: "Filled Input",
        variant: :filled,
        placeholder: "Filled variant"
      ))
    end
    # @!endgroup

    # @!group Sizes

    # @label Small
    def small_size
      render(Ui::InputComponent.new(
        label: "Small Input",
        size: :sm,
        placeholder: "Small input"
      ))
    end

    # @label Medium (Default)
    def medium_size
      render(Ui::InputComponent.new(
        label: "Medium Input",
        size: :md,
        placeholder: "Medium input"
      ))
    end

    # @label Large
    def large_size
      render(Ui::InputComponent.new(
        label: "Large Input",
        size: :lg,
        placeholder: "Large input"
      ))
    end

    # @label Extra Large
    def extra_large_size
      render(Ui::InputComponent.new(
        label: "Extra Large Input",
        size: :xl,
        placeholder: "Extra large input"
      ))
    end
    # @!endgroup

    # @!group Features

    # @label With Help Text
    def with_help_text
      render(Ui::InputComponent.new(
        label: "Username",
        placeholder: "Enter your username",
        help_text: "Username must be between 3-20 characters"
      ))
    end

    # @label With Error
    def with_error
      render(Ui::InputComponent.new(
        label: "Email",
        type: "email",
        value: "invalid-email",
        error: "Please enter a valid email address"
      ))
    end

    # @label Required Field
    def required_field
      render(Ui::InputComponent.new(
        label: "Full Name",
        placeholder: "Enter your full name",
        required: true
      ))
    end

    # @label Disabled
    def disabled
      render(Ui::InputComponent.new(
        label: "Username",
        placeholder: "Enter your username",
        disabled: true
      ))
    end

    # @label Readonly
    def readonly
      render(Ui::InputComponent.new(
        label: "Username",
        value: "johndoe",
        readonly: true
      ))
    end

    # @label With Leading Icon
    def with_leading_icon
      render(Ui::InputComponent.new(
        label: "Search",
        placeholder: "Search...",
        leading_icon: "search"
      ))
    end

    # @label With Trailing Icon
    def with_trailing_icon
      render(Ui::InputComponent.new(
        label: "Password",
        type: "password",
        placeholder: "Enter your password",
        trailing_icon: "eye"
      ))
    end

    # @label With Leading and Trailing Content
    def with_leading_and_trailing_content
      render_with_template(locals: {
        component: Ui::InputComponent.new(
          label: "Amount",
          type: "number",
          placeholder: "0.00",
          min: 0,
          step: 0.01
        )
      })
    end
    # @!endgroup

    # @!group Theme Examples

    # @label Light and Dark Theme
    def theme_examples
      render_with_template(locals: {
        component: Ui::InputComponent.new(
          label: "Username",
          placeholder: "Enter your username"
        )
      })
    end
    # @!endgroup

    # @!group Accessibility Examples

    # @label Keyboard Navigation
    def keyboard_navigation
      render_with_template(locals: {
        component: Ui::InputComponent.new(
          label: "Username",
          placeholder: "Enter your username"
        )
      })
    end

    # @label Screen Reader Support
    def screen_reader_support
      render_with_template(locals: {
        component: Ui::InputComponent.new(
          label: "Email",
          type: "email",
          placeholder: "user@example.com",
          required: true,
          aria: { describedby: "email-help" }
        )
      })
    end
    # @!endgroup
  end
end
