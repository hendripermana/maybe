# Settings Page Modernization Guide

This guide provides instructions for modernizing settings pages using the enhanced form components.

## Form Component Usage

Replace legacy forms with modern components:

```erb
<!-- Legacy form -->
<%= styled_form_with model: @user, class: "space-y-4" do |form| %>
  <!-- Form fields -->
<% end %>

<!-- Modern form -->
<%= render Ui::FormComponent.new(model: @user) do |form| %>
  <!-- Form fields -->
<% end %>
```

## Input Component Usage

Replace legacy inputs with modern components:

```erb
<!-- Legacy input -->
<%= form.text_field :email, placeholder: "Email", label: "Email" %>

<!-- Modern input -->
<%= render Ui::FormFieldComponent.new(form: form, field: :email, label: "Email", required: true) do %>
  <%= render Ui::InputComponent.new(
    form: form,
    field: :email,
    type: :email,
    placeholder: "Email",
    required: true
  ) %>
<% end %>
```

## Select Component Usage

Replace legacy selects with modern components:

```erb
<!-- Legacy select -->
<%= form.select :locale, language_options, { label: "Language" } %>

<!-- Modern select -->
<%= render Ui::FormFieldComponent.new(form: form, field: :locale, label: "Language") do %>
  <%= render Ui::SelectComponent.new(
    form: form,
    field: :locale,
    options: language_options
  ) %>
<% end %>
```

## Checkbox Component Usage

Replace legacy checkboxes with modern components:

```erb
<!-- Legacy checkbox -->
<%= form.check_box :remember_me, label: "Remember me" %>

<!-- Modern checkbox -->
<%= render Ui::FormFieldComponent.new(form: form, field: :remember_me, label: "Remember me") do %>
  <%= render Ui::CheckboxComponent.new(
    form: form,
    field: :remember_me,
    label_text: "Remember me"
  ) %>
<% end %>
```

## Toggle Switch Component Usage

Replace legacy toggles with modern components:

```erb
<!-- Legacy toggle -->
<%= form.check_box :active, label: "Active" %>

<!-- Modern toggle -->
<%= render Ui::FormFieldComponent.new(form: form, field: :active, label: "Active") do %>
  <%= render Ui::ToggleSwitchComponent.new(
    form: form,
    field: :active,
    label_text: "Active"
  ) %>
<% end %>
```

## Radio Button Component Usage

Replace legacy radio buttons with modern components:

```erb
<!-- Legacy radio buttons -->
<%= form.radio_button :theme, "light", label: "Light" %>
<%= form.radio_button :theme, "dark", label: "Dark" %>

<!-- Modern radio buttons -->
<%= render Ui::FormFieldComponent.new(form: form, field: :theme, label: "Theme") do %>
  <%= render Ui::RadioGroupComponent.new(form: form, field: :theme, legend: "Theme") do |radio_group| %>
    <% radio_group.radio_button(value: "light", label: "Light") %>
    <% radio_group.radio_button(value: "dark", label: "Dark") %>
  <% end %>
<% end %>
```

## Textarea Component Usage

Replace legacy textareas with modern components:

```erb
<!-- Legacy textarea -->
<%= form.text_area :description, placeholder: "Description", label: "Description" %>

<!-- Modern textarea -->
<%= render Ui::FormFieldComponent.new(form: form, field: :description, label: "Description") do %>
  <%= render Ui::TextareaComponent.new(
    form: form,
    field: :description,
    placeholder: "Description",
    rows: 4
  ) %>
<% end %>
```

## Form Feedback Component Usage

Add feedback messages to forms:

```erb
<!-- Success message -->
<%= render Ui::FormFeedbackComponent.new(
  message: "Settings saved successfully!",
  variant: :success
) %>

<!-- Error message -->
<%= render Ui::FormFeedbackComponent.new(
  message: "There was an error saving your settings.",
  variant: :error
) %>

<!-- Info message -->
<%= render Ui::FormFeedbackComponent.new(
  message: "Your changes will take effect after you log out and back in.",
  variant: :info
) %>
```

## Accessibility Considerations

1. Always include proper labels for form controls
2. Use `required` attribute for required fields
3. Add descriptive help text for complex fields
4. Ensure proper color contrast for all form elements
5. Test keyboard navigation through forms
6. Add appropriate ARIA attributes for screen readers