# frozen_string_literal: true

module Ui
  class ModalComponentPreview < ViewComponent::Preview
    # @param variant select {{ Ui::ModalComponent::VARIANTS.keys }}
    # @param size select {{ Ui::ModalComponent::SIZES.keys }}
    # @param open toggle
    # @param closable toggle
    # @param backdrop_closable toggle
    def default(variant: "default", size: "md", open: true, closable: true, backdrop_closable: true)
      render Ui::ModalComponent.new(
        variant: variant.to_sym,
        size: size.to_sym,
        title: "Sample Modal",
        description: "This is a sample modal dialog.",
        open: open,
        closable: closable,
        backdrop_closable: backdrop_closable,
        data: { controller: "ui--modal" }
      ) do
        content_tag(:p, "This is the modal content. You can put any content here.")
      end
    end

    # @!group Basic Examples
    def simple_modal
      render Ui::ModalComponent.new(
        title: "Simple Modal",
        description: "A basic modal with title and description.",
        open: true,
        data: { controller: "ui--modal" }
      ) do
        content_tag(:p, "This is a simple modal with minimal content.")
      end
    end

    def modal_with_footer
      render Ui::ModalComponent.new(
        title: "Confirm Action",
        description: "Are you sure you want to proceed with this action?",
        open: true,
        data: { controller: "ui--modal" }
      ) do |modal|
        modal.with_footer do
          content_tag(:div, class: "flex justify-end space-x-2") do
            concat(render(Ui::ButtonComponent.new(variant: :ghost) { "Cancel" }))
            concat(render(Ui::ButtonComponent.new(variant: :destructive) { "Delete" }))
          end
        end
        content_tag(:p, "This action cannot be undone. Please confirm that you want to proceed.")
      end
    end

    def modal_without_close
      render Ui::ModalComponent.new(
        title: "Important Notice",
        description: "This modal cannot be closed by clicking outside.",
        open: true,
        closable: false,
        backdrop_closable: false,
        data: { controller: "ui--modal" }
      ) do |modal|
        modal.with_footer do
          render(Ui::ButtonComponent.new(variant: :primary) { "I Understand" })
        end
        content_tag(:p, "Please read this important information carefully before proceeding.")
      end
    end
    # @!endgroup

    # @!group Sizes
    def small_modal
      render Ui::ModalComponent.new(
        size: :sm,
        title: "Small Modal",
        description: "A compact modal for simple interactions.",
        open: true,
        data: { controller: "ui--modal" }
      ) do
        content_tag(:p, "This is a small modal with limited width.")
      end
    end

    def medium_modal
      render Ui::ModalComponent.new(
        size: :md,
        title: "Medium Modal",
        description: "The standard modal size for most use cases.",
        open: true,
        data: { controller: "ui--modal" }
      ) do
        content_tag(:p, "This is a medium-sized modal with standard width.")
      end
    end

    def large_modal
      render Ui::ModalComponent.new(
        size: :lg,
        title: "Large Modal",
        description: "A wider modal for more complex content.",
        open: true,
        data: { controller: "ui--modal" }
      ) do
        content_tag(:div, class: "space-y-4") do
          concat(content_tag(:p, "This is a large modal with more space for content."))
          concat(content_tag(:p, "You can include forms, tables, or other complex layouts here."))
        end
      end
    end

    def extra_large_modal
      render Ui::ModalComponent.new(
        size: :xl,
        title: "Extra Large Modal",
        description: "Maximum width modal for complex interfaces.",
        open: true,
        data: { controller: "ui--modal" }
      ) do
        content_tag(:div, class: "grid grid-cols-2 gap-6") do
          concat(content_tag(:div) do
            concat(content_tag(:h4, "Left Column", class: "font-semibold mb-2"))
            concat(content_tag(:p, "Content for the left side of the modal."))
          end)
          concat(content_tag(:div) do
            concat(content_tag(:h4, "Right Column", class: "font-semibold mb-2"))
            concat(content_tag(:p, "Content for the right side of the modal."))
          end)
        end
      end
    end

    def fullscreen_modal
      render Ui::ModalComponent.new(
        variant: :fullscreen,
        title: "Fullscreen Modal",
        description: "A modal that takes up the entire screen.",
        open: true,
        data: { controller: "ui--modal" }
      ) do
        content_tag(:div, class: "h-96 flex items-center justify-center") do
          content_tag(:p, "This modal fills the entire screen.", class: "text-xl")
        end
      end
    end
    # @!endgroup

    # @!group Form Examples
    def form_modal
      render Ui::ModalComponent.new(
        title: "Create New Account",
        description: "Fill out the form below to create a new account.",
        open: true,
        size: :lg,
        data: { controller: "ui--modal" }
      ) do |modal|
        modal.with_footer do
          content_tag(:div, class: "flex justify-end space-x-2") do
            concat(render(Ui::ButtonComponent.new(variant: :ghost) { "Cancel" }))
            concat(render(Ui::ButtonComponent.new(variant: :primary) { "Create Account" }))
          end
        end
        
        content_tag(:form, class: "space-y-4") do
          concat(render(Ui::InputComponent.new(
            label: "Account Name",
            placeholder: "Enter account name",
            required: true
          )))
          concat(render(Ui::InputComponent.new(
            type: "select",
            label: "Account Type",
            required: true
          ) do
            concat(content_tag(:option, "Select account type", value: ""))
            concat(content_tag(:option, "Checking", value: "checking"))
            concat(content_tag(:option, "Savings", value: "savings"))
            concat(content_tag(:option, "Investment", value: "investment"))
          end))
          concat(render(Ui::InputComponent.new(
            type: "number",
            label: "Initial Balance",
            placeholder: "0.00",
            help_text: "Optional starting balance"
          )))
        end
      end
    end

    def confirmation_modal
      render Ui::ModalComponent.new(
        title: "Delete Account",
        description: "This action cannot be undone.",
        open: true,
        data: { controller: "ui--modal" }
      ) do |modal|
        modal.with_footer do
          content_tag(:div, class: "flex justify-end space-x-2") do
            concat(render(Ui::ButtonComponent.new(variant: :ghost) { "Cancel" }))
            concat(render(Ui::ButtonComponent.new(variant: :destructive) { "Delete Account" }))
          end
        end
        
        content_tag(:div, class: "space-y-4") do
          concat(content_tag(:p, "Are you sure you want to delete this account? This will permanently remove:"))
          concat(content_tag(:ul, class: "list-disc list-inside space-y-1 text-sm text-muted-foreground") do
            concat(content_tag(:li, "All transaction history"))
            concat(content_tag(:li, "Account balance information"))
            concat(content_tag(:li, "Associated categories and tags"))
          end)
          concat(render(Ui::InputComponent.new(
            label: "Type 'DELETE' to confirm",
            placeholder: "DELETE",
            help_text: "This confirmation is required to proceed."
          )))
        end
      end
    end
    # @!endgroup

    # @!group Interactive Examples
    def trigger_button_example
      content_tag(:div, class: "space-y-4") do
        concat(content_tag(:p, "Click the button below to open a modal:"))
        concat(render(Ui::ButtonComponent.new(
          variant: :primary,
          data: { action: "click->ui--modal#show" }
        ) { "Open Modal" }))
        
        concat(render(Ui::ModalComponent.new(
          title: "Triggered Modal",
          description: "This modal was opened by clicking a button.",
          open: false,
          data: { controller: "ui--modal" }
        ) do |modal|
          modal.with_footer do
            render(Ui::ButtonComponent.new(
              variant: :primary,
              data: { action: "click->ui--modal#close" }
            ) { "Close Modal" })
          end
          content_tag(:p, "This demonstrates how to trigger modals with buttons.")
        end))
      end
    end
    # @!endgroup

    # @!group Theme Examples
    def theme_showcase
      content_tag(:div, class: "space-y-4") do
        concat(content_tag(:h3, "Modal Theme Examples", class: "text-lg font-semibold"))
        concat(content_tag(:p, "Switch between light and dark themes to see consistent modal styling.", class: "text-sm text-muted-foreground"))
        
        concat(render(Ui::ModalComponent.new(
          title: "Theme-Aware Modal",
          description: "This modal adapts to your current theme setting.",
          open: true,
          data: { controller: "ui--modal" }
        ) do |modal|
          modal.with_footer do
            content_tag(:div, class: "flex justify-end space-x-2") do
              concat(render(Ui::ButtonComponent.new(variant: :ghost) { "Cancel" }))
              concat(render(Ui::ButtonComponent.new(variant: :primary) { "Confirm" }))
            end
          end
          
          content_tag(:div, class: "space-y-4") do
            concat(content_tag(:p, "Notice how the modal background, borders, and text colors all adapt to the current theme."))
            concat(content_tag(:div, class: "p-4 bg-muted rounded-lg") do
              content_tag(:p, "Even nested elements like this highlighted section maintain theme consistency.", class: "text-sm")
            end)
          end
        end))
      end
    end
    # @!endgroup
  end
end