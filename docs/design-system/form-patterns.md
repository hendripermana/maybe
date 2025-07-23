# Form Patterns

This document outlines the standard form patterns used throughout the Maybe Finance application. These patterns ensure consistency in form layout, validation, and user experience.

## Form Structure

### Basic Form Layout

```erb
<%= form_with model: @user, class: "space-y-6" do |form| %>
  <div class="form-group">
    <%= form.label :name, class: "block text-sm font-medium mb-1" %>
    <%= render InputComponent.new(
      type: :text,
      name: "user[name]",
      id: "user_name",
      value: @user.name,
      required: true
    ) %>
  </div>
  
  <div class="form-group">
    <%= form.label :email, class: "block text-sm font-medium mb-1" %>
    <%= render InputComponent.new(
      type: :email,
      name: "user[email]",
      id: "user_email",
      value: @user.email,
      required: true
    ) %>
  </div>
  
  <div class="form-actions">
    <%= render ButtonComponent.new(variant: :primary, type: :submit) do %>
      Save
    <% end %>
  </div>
<% end %>
```

### Form with Validation Errors

```erb
<%= form_with model: @user, class: "space-y-6" do |form| %>
  <div class="form-group">
    <%= form.label :name, class: "block text-sm font-medium mb-1" %>
    <%= render InputComponent.new(
      type: :text,
      name: "user[name]",
      id: "user_name",
      value: @user.name,
      required: true,
      aria: { invalid: @user.errors[:name].any? }
    ) %>
    <% if @user.errors[:name].any? %>
      <p class="text-sm text-destructive mt-1"><%= @user.errors[:name].first %></p>
    <% end %>
  </div>
  
  <!-- Additional fields -->
  
  <div class="form-actions">
    <%= render ButtonComponent.new(variant: :primary, type: :submit) do %>
      Save
    <% end %>
  </div>
<% end %>
```

### Form with Sections

```erb
<%= form_with model: @account, class: "space-y-8" do |form| %>
  <section class="space-y-6">
    <h2 class="text-lg font-medium">Account Information</h2>
    
    <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
      <div class="form-group">
        <%= form.label :name, class: "block text-sm font-medium mb-1" %>
        <%= render InputComponent.new(
          type: :text,
          name: "account[name]",
          id: "account_name",
          value: @account.name,
          required: true
        ) %>
      </div>
      
      <div class="form-group">
        <%= form.label :type, class: "block text-sm font-medium mb-1" %>
        <%= render SelectComponent.new(
          name: "account[type]",
          id: "account_type",
          options: account_type_options,
          selected: @account.type
        ) %>
      </div>
    </div>
  </section>
  
  <section class="space-y-6">
    <h2 class="text-lg font-medium">Additional Details</h2>
    
    <!-- Additional fields -->
  </section>
  
  <div class="form-actions">
    <%= render ButtonComponent.new(variant: :primary, type: :submit) do %>
      Save Account
    <% end %>
    
    <%= render ButtonComponent.new(variant: :outline, href: accounts_path) do %>
      Cancel
    <% end %>
  </div>
<% end %>
```

## Form Components

### Input Component

```erb
<%= render InputComponent.new(
  type: :text,
  name: "user[name]",
  id: "user_name",
  value: @user.name,
  placeholder: "Enter your name",
  required: true,
  disabled: false,
  readonly: false,
  class: "custom-class"
) %>
```

### Select Component

```erb
<%= render SelectComponent.new(
  name: "user[country]",
  id: "user_country",
  options: [
    ["United States", "US"],
    ["Canada", "CA"],
    ["United Kingdom", "UK"]
  ],
  selected: @user.country,
  placeholder: "Select a country",
  required: true
) %>
```

### Checkbox Component

```erb
<%= render CheckboxComponent.new(
  name: "user[terms]",
  id: "user_terms",
  checked: @user.terms_accepted,
  required: true
) do %>
  I agree to the <a href="/terms" class="text-primary hover:underline">terms and conditions</a>
<% end %>
```

### Radio Group Component

```erb
<fieldset class="space-y-2">
  <legend class="text-sm font-medium">Notification Preference</legend>
  
  <div class="space-y-1">
    <%= render RadioComponent.new(
      name: "user[notification_preference]",
      id: "user_notification_preference_email",
      value: "email",
      checked: @user.notification_preference == "email"
    ) do %>
      Email
    <% end %>
    
    <%= render RadioComponent.new(
      name: "user[notification_preference]",
      id: "user_notification_preference_sms",
      value: "sms",
      checked: @user.notification_preference == "sms"
    ) do %>
      SMS
    <% end %>
    
    <%= render RadioComponent.new(
      name: "user[notification_preference]",
      id: "user_notification_preference_none",
      value: "none",
      checked: @user.notification_preference == "none"
    ) do %>
      None
    <% end %>
  </div>
</fieldset>
```

### Toggle Component

```erb
<div class="flex items-center justify-between">
  <label for="user_dark_mode" class="text-sm font-medium">Dark Mode</label>
  
  <%= render ToggleComponent.new(
    id: "user_dark_mode",
    name: "user[dark_mode]",
    pressed: @user.dark_mode,
    "data-action": "toggle#toggle"
  ) %>
</div>
```

### Textarea Component

```erb
<%= render TextareaComponent.new(
  name: "user[bio]",
  id: "user_bio",
  value: @user.bio,
  placeholder: "Tell us about yourself",
  rows: 4
) %>
```

### File Input Component

```erb
<%= render FileInputComponent.new(
  name: "user[avatar]",
  id: "user_avatar",
  accept: "image/*"
) %>
```

## Form Layouts

### Stacked Form Layout

```erb
<div class="space-y-6">
  <div class="form-group">
    <label for="name" class="block text-sm font-medium mb-1">Name</label>
    <%= render InputComponent.new(type: :text, id: "name") %>
  </div>
  
  <div class="form-group">
    <label for="email" class="block text-sm font-medium mb-1">Email</label>
    <%= render InputComponent.new(type: :email, id: "email") %>
  </div>
  
  <div class="form-group">
    <label for="message" class="block text-sm font-medium mb-1">Message</label>
    <%= render TextareaComponent.new(id: "message", rows: 4) %>
  </div>
</div>
```

### Horizontal Form Layout

```erb
<div class="space-y-6">
  <div class="grid grid-cols-3 gap-4 items-center">
    <label for="name" class="text-sm font-medium">Name</label>
    <div class="col-span-2">
      <%= render InputComponent.new(type: :text, id: "name") %>
    </div>
  </div>
  
  <div class="grid grid-cols-3 gap-4 items-center">
    <label for="email" class="text-sm font-medium">Email</label>
    <div class="col-span-2">
      <%= render InputComponent.new(type: :email, id: "email") %>
    </div>
  </div>
  
  <div class="grid grid-cols-3 gap-4 items-start">
    <label for="message" class="text-sm font-medium pt-2">Message</label>
    <div class="col-span-2">
      <%= render TextareaComponent.new(id: "message", rows: 4) %>
    </div>
  </div>
</div>
```

### Grid Form Layout

```erb
<div class="grid grid-cols-1 md:grid-cols-2 gap-6">
  <div class="form-group">
    <label for="first_name" class="block text-sm font-medium mb-1">First Name</label>
    <%= render InputComponent.new(type: :text, id: "first_name") %>
  </div>
  
  <div class="form-group">
    <label for="last_name" class="block text-sm font-medium mb-1">Last Name</label>
    <%= render InputComponent.new(type: :text, id: "last_name") %>
  </div>
  
  <div class="form-group md:col-span-2">
    <label for="email" class="block text-sm font-medium mb-1">Email</label>
    <%= render InputComponent.new(type: :email, id: "email") %>
  </div>
  
  <div class="form-group">
    <label for="password" class="block text-sm font-medium mb-1">Password</label>
    <%= render InputComponent.new(type: :password, id: "password") %>
  </div>
  
  <div class="form-group">
    <label for="password_confirmation" class="block text-sm font-medium mb-1">Confirm Password</label>
    <%= render InputComponent.new(type: :password, id: "password_confirmation") %>
  </div>
</div>
```

## Form Validation

### Client-Side Validation

```erb
<%= form_with model: @user, class: "space-y-6", data: { controller: "validation" } do |form| %>
  <div class="form-group">
    <%= form.label :email, class: "block text-sm font-medium mb-1" %>
    <%= render InputComponent.new(
      type: :email,
      name: "user[email]",
      id: "user_email",
      value: @user.email,
      required: true,
      data: {
        validation_target: "input",
        action: "blur->validation#validate"
      }
    ) %>
    <p class="text-sm text-destructive mt-1 hidden" data-validation-target="error"></p>
  </div>
  
  <!-- Additional fields -->
  
  <div class="form-actions">
    <%= render ButtonComponent.new(variant: :primary, type: :submit) do %>
      Save
    <% end %>
  </div>
<% end %>
```

### Server-Side Validation

```erb
<%= form_with model: @user, class: "space-y-6" do |form| %>
  <% if @user.errors.any? %>
    <div class="bg-destructive/10 text-destructive p-4 rounded-md mb-6">
      <h2 class="font-medium">
        <%= pluralize(@user.errors.count, "error") %> prohibited this user from being saved:
      </h2>
      
      <ul class="list-disc list-inside mt-2">
        <% @user.errors.full_messages.each do |message| %>
          <li><%= message %></li>
        <% end %>
      </ul>
    </div>
  <% end %>
  
  <!-- Form fields -->
<% end %>
```

### Inline Validation

```erb
<div class="form-group">
  <%= form.label :password, class: "block text-sm font-medium mb-1" %>
  <%= render InputComponent.new(
    type: :password,
    name: "user[password]",
    id: "user_password",
    required: true,
    class: @user.errors[:password].any? ? "border-destructive" : "",
    aria: { invalid: @user.errors[:password].any? }
  ) %>
  <% if @user.errors[:password].any? %>
    <p class="text-sm text-destructive mt-1"><%= @user.errors[:password].first %></p>
  <% end %>
</div>
```

## Form States

### Loading State

```erb
<%= form_with model: @user, class: "space-y-6", data: { controller: "form" } do |form| %>
  <!-- Form fields -->
  
  <div class="form-actions">
    <%= render ButtonComponent.new(
      variant: :primary,
      type: :submit,
      data: {
        form_target: "submitButton",
        action: "click->form#submitWithLoading"
      }
    ) do %>
      <span data-form-target="buttonText">Save</span>
      <span class="hidden" data-form-target="loadingText">
        <svg class="animate-spin -ml-1 mr-2 h-4 w-4 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
          <circle class="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" stroke-width="4"></circle>
          <path class="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
        </svg>
        Saving...
      </span>
    <% end %>
  </div>
<% end %>
```

### Disabled State

```erb
<%= render InputComponent.new(
  type: :text,
  value: "Read-only value",
  disabled: true
) %>

<%= render ButtonComponent.new(
  variant: :primary,
  disabled: true
) do %>
  Disabled Button
<% end %>
```

### Focus State

All form components have consistent focus states using the ring utility:

```css
.form-input:focus-visible {
  outline: none;
  ring: 2px;
  ring-offset: 2px;
  ring-color: hsl(var(--ring));
}
```

## Form Patterns

### Search Form

```erb
<%= form_with url: search_path, method: :get, class: "relative" do |form| %>
  <%= render InputComponent.new(
    type: :search,
    name: "q",
    placeholder: "Search...",
    value: params[:q],
    class: "pr-10"
  ) %>
  
  <button type="submit" class="absolute inset-y-0 right-0 flex items-center pr-3">
    <%= render FilledIconComponent.new(name: "search", class: "h-4 w-4 text-muted-foreground") %>
  </button>
<% end %>
```

### Filter Form

```erb
<%= form_with url: transactions_path, method: :get, class: "bg-card rounded-lg border border-border p-4" do |form| %>
  <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
    <div class="form-group">
      <label for="category" class="block text-sm font-medium mb-1">Category</label>
      <%= render SelectComponent.new(
        name: "category",
        id: "category",
        options: category_options,
        selected: params[:category],
        include_blank: "All Categories"
      ) %>
    </div>
    
    <div class="form-group">
      <label for="date_from" class="block text-sm font-medium mb-1">From</label>
      <%= render InputComponent.new(
        type: :date,
        name: "date_from",
        id: "date_from",
        value: params[:date_from]
      ) %>
    </div>
    
    <div class="form-group">
      <label for="date_to" class="block text-sm font-medium mb-1">To</label>
      <%= render InputComponent.new(
        type: :date,
        name: "date_to",
        id: "date_to",
        value: params[:date_to]
      ) %>
    </div>
  </div>
  
  <div class="mt-4 flex justify-end space-x-2">
    <%= render ButtonComponent.new(
      variant: :outline,
      type: :button,
      href: transactions_path
    ) do %>
      Reset
    <% end %>
    
    <%= render ButtonComponent.new(
      variant: :primary,
      type: :submit
    ) do %>
      Apply Filters
    <% end %>
  </div>
<% end %>
```

### Multi-Step Form

```erb
<div data-controller="multi-step-form">
  <!-- Step indicators -->
  <div class="mb-8">
    <div class="flex items-center">
      <div class="flex items-center text-primary relative">
        <div class="rounded-full transition duration-500 ease-in-out h-12 w-12 py-3 border-2 border-primary flex items-center justify-center">
          <span class="text-center font-medium">1</span>
        </div>
        <div class="absolute top-0 -ml-10 text-center mt-16 w-32 text-xs font-medium">
          Account Details
        </div>
      </div>
      
      <div class="flex-auto border-t-2 transition duration-500 ease-in-out border-muted"></div>
      
      <div class="flex items-center text-muted relative">
        <div class="rounded-full transition duration-500 ease-in-out h-12 w-12 py-3 border-2 border-muted flex items-center justify-center">
          <span class="text-center font-medium">2</span>
        </div>
        <div class="absolute top-0 -ml-10 text-center mt-16 w-32 text-xs font-medium">
          Preferences
        </div>
      </div>
      
      <div class="flex-auto border-t-2 transition duration-500 ease-in-out border-muted"></div>
      
      <div class="flex items-center text-muted relative">
        <div class="rounded-full transition duration-500 ease-in-out h-12 w-12 py-3 border-2 border-muted flex items-center justify-center">
          <span class="text-center font-medium">3</span>
        </div>
        <div class="absolute top-0 -ml-10 text-center mt-16 w-32 text-xs font-medium">
          Confirmation
        </div>
      </div>
    </div>
  </div>
  
  <!-- Step content -->
  <div class="bg-card rounded-lg border border-border p-6">
    <!-- Step 1 -->
    <div data-multi-step-form-target="step" class="block">
      <h2 class="text-lg font-medium mb-6">Account Details</h2>
      
      <div class="space-y-6">
        <!-- Step 1 fields -->
        
        <div class="flex justify-end">
          <%= render ButtonComponent.new(
            variant: :primary,
            data: { action: "click->multi-step-form#next" }
          ) do %>
            Next
          <% end %>
        </div>
      </div>
    </div>
    
    <!-- Step 2 -->
    <div data-multi-step-form-target="step" class="hidden">
      <!-- Step 2 content -->
    </div>
    
    <!-- Step 3 -->
    <div data-multi-step-form-target="step" class="hidden">
      <!-- Step 3 content -->
    </div>
  </div>
</div>
```

## Accessibility Considerations

1. **Labels**: Always use proper labels for form controls
2. **Error Messages**: Associate error messages with form controls using `aria-describedby`
3. **Required Fields**: Use the `required` attribute and indicate required fields visually
4. **Focus Management**: Ensure proper focus order and visible focus states
5. **Keyboard Navigation**: Make sure all form controls are keyboard accessible
6. **Form Validation**: Provide clear error messages and focus the first invalid field
7. **ARIA Attributes**: Use appropriate ARIA attributes for complex form controls

## Best Practices

1. **Consistent Layout**: Use consistent spacing and alignment for form elements
2. **Clear Labels**: Use clear and concise labels for form fields
3. **Helpful Placeholders**: Use placeholders to provide examples, not as replacements for labels
4. **Logical Grouping**: Group related form fields together
5. **Progressive Disclosure**: Use progressive disclosure for complex forms
6. **Inline Validation**: Provide immediate feedback for validation errors
7. **Responsive Design**: Ensure forms work well on all device sizes
8. **Theme Support**: Test forms in both light and dark themes