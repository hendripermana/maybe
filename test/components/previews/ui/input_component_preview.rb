# frozen_string_literal: true

module Ui
  class InputComponentPreview < ViewComponent::Preview
    # @param variant select {{ Ui::InputComponent::VARIANTS.keys }}
    # @param size select {{ Ui::InputComponent::SIZES.keys }}
    # @param disabled toggle
    # @param required toggle
    def default(variant: "default", size: "md", disabled: false, required: false)
      render Ui::InputComponent.new(
        variant: variant.to_sym,
        size: size.to_sym,
        placeholder: "Enter text here...",
        disabled: disabled,
        required: required,
        label: "Sample Input"
      )
    end

    # @!group Input Types
    def text_input
      render Ui::InputComponent.new(
        type: "text",
        label: "Text Input",
        placeholder: "Enter your name",
        help_text: "This is a standard text input field."
      )
    end

    def email_input
      render Ui::InputComponent.new(
        type: "email",
        label: "Email Address",
        placeholder: "user@example.com",
        required: true
      )
    end

    def password_input
      render Ui::InputComponent.new(
        type: "password",
        label: "Password",
        placeholder: "Enter your password",
        required: true
      )
    end

    def number_input
      render Ui::InputComponent.new(
        type: "number",
        label: "Amount",
        placeholder: "0.00",
        help_text: "Enter a numeric value"
      )
    end

    def date_input
      render Ui::InputComponent.new(
        type: "date",
        label: "Date",
        value: Date.current.to_s
      )
    end

    def textarea_input
      render Ui::InputComponent.new(
        type: "textarea",
        label: "Description",
        placeholder: "Enter a detailed description...",
        help_text: "Maximum 500 characters",
        rows: 4
      )
    end

    def select_input
      render Ui::InputComponent.new(
        type: "select",
        label: "Category",
        required: true
      ) do
        concat(content_tag(:option, "Select a category", value: ""))
        concat(content_tag(:option, "Food & Dining", value: "food"))
        concat(content_tag(:option, "Transportation", value: "transport"))
        concat(content_tag(:option, "Entertainment", value: "entertainment"))
        concat(content_tag(:option, "Shopping", value: "shopping"))
      end
    end
    # @!endgroup

    # @!group Variants
    def default_variant
      render Ui::InputComponent.new(
        label: "Default Input",
        placeholder: "Default styling"
      )
    end

    def outline_variant
      render Ui::InputComponent.new(
        variant: :outline,
        label: "Outline Input",
        placeholder: "With visible border"
      )
    end

    def ghost_variant
      render Ui::InputComponent.new(
        variant: :ghost,
        label: "Ghost Input",
        placeholder: "Minimal styling"
      )
    end

    def filled_variant
      render Ui::InputComponent.new(
        variant: :filled,
        label: "Filled Input",
        placeholder: "With background fill"
      )
    end
    # @!endgroup

    # @!group Sizes
    def small_input
      render Ui::InputComponent.new(
        size: :sm,
        label: "Small Input",
        placeholder: "Compact size"
      )
    end

    def medium_input
      render Ui::InputComponent.new(
        size: :md,
        label: "Medium Input",
        placeholder: "Standard size"
      )
    end

    def large_input
      render Ui::InputComponent.new(
        size: :lg,
        label: "Large Input",
        placeholder: "Larger size"
      )
    end

    def extra_large_input
      render Ui::InputComponent.new(
        size: :xl,
        label: "Extra Large Input",
        placeholder: "Maximum size"
      )
    end
    # @!endgroup

    # @!group States
    def required_input
      render Ui::InputComponent.new(
        label: "Required Field",
        placeholder: "This field is required",
        required: true,
        help_text: "Please fill out this field."
      )
    end

    def disabled_input
      render Ui::InputComponent.new(
        label: "Disabled Input",
        placeholder: "Cannot be edited",
        disabled: true,
        value: "Read-only value"
      )
    end

    def readonly_input
      render Ui::InputComponent.new(
        label: "Read-only Input",
        value: "This value cannot be changed",
        readonly: true
      )
    end

    def error_input
      render Ui::InputComponent.new(
        label: "Input with Error",
        placeholder: "Enter valid email",
        value: "invalid-email",
        error: "Please enter a valid email address"
      )
    end
    # @!endgroup

    # @!group Form Examples
    def login_form
      content_tag(:div, class: "space-y-4 max-w-sm") do
        concat(content_tag(:h3, "Login Form", class: "text-lg font-semibold mb-4"))
        concat(render(Ui::InputComponent.new(
          type: "email",
          label: "Email",
          placeholder: "Enter your email",
          required: true
        )))
        concat(render(Ui::InputComponent.new(
          type: "password",
          label: "Password",
          placeholder: "Enter your password",
          required: true
        )))
        concat(render(Ui::ButtonComponent.new(
          variant: :primary,
          full_width: true,
          class: "mt-4"
        ) { "Sign In" }))
      end
    end

    def contact_form
      content_tag(:div, class: "space-y-4 max-w-md") do
        concat(content_tag(:h3, "Contact Form", class: "text-lg font-semibold mb-4"))
        concat(render(Ui::InputComponent.new(
          label: "Full Name",
          placeholder: "John Doe",
          required: true
        )))
        concat(render(Ui::InputComponent.new(
          type: "email",
          label: "Email Address",
          placeholder: "john@example.com",
          required: true
        )))
        concat(render(Ui::InputComponent.new(
          type: "select",
          label: "Subject",
          required: true
        ) do
          concat(content_tag(:option, "Select a subject", value: ""))
          concat(content_tag(:option, "General Inquiry", value: "general"))
          concat(content_tag(:option, "Support Request", value: "support"))
          concat(content_tag(:option, "Bug Report", value: "bug"))
        end))
        concat(render(Ui::InputComponent.new(
          type: "textarea",
          label: "Message",
          placeholder: "Your message here...",
          required: true,
          rows: 4
        )))
        concat(render(Ui::ButtonComponent.new(
          variant: :primary,
          full_width: true,
          class: "mt-4"
        ) { "Send Message" }))
      end
    end
    # @!endgroup

    # @!group Theme Examples
    def theme_showcase
      content_tag(:div, class: "space-y-6") do
        concat(content_tag(:h3, "Input Theme Examples", class: "text-lg font-semibold"))
        concat(content_tag(:p, "Switch between light and dark themes to see consistent styling.", class: "text-sm text-muted-foreground mb-4"))
        
        concat(content_tag(:div, class: "grid grid-cols-1 md:grid-cols-2 gap-4") do
          Ui::InputComponent::VARIANTS.keys.each do |variant|
            concat(render(Ui::InputComponent.new(
              variant: variant,
              label: "#{variant.to_s.humanize} Input",
              placeholder: "#{variant} variant example"
            )))
          end
        end)
      end
    end
    # @!endgroup
  end
end