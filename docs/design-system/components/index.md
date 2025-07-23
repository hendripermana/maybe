# Component Library

The Maybe Finance component library is a collection of reusable UI components built with ViewComponent and styled with Tailwind CSS. These components follow the Shadcn design principles and ensure consistency across the application.

## Component Categories

The component library is organized into the following categories:

1. **[Core Components](#core-components)**: Fundamental building blocks
2. **[Form Components](#form-components)**: Input and form-related components
3. **[Navigation Components](#navigation-components)**: Components for navigation and wayfinding
4. **[Feedback Components](#feedback-components)**: Components for user feedback and notifications
5. **[Data Display Components](#data-display-components)**: Components for displaying data
6. **[Financial Components](#financial-components)**: Domain-specific components for financial data

## Core Components

### Button Component

The Button component is a versatile interactive element used for actions.

```ruby
# app/components/button_component.rb
class ButtonComponent < ViewComponent::Base
  VARIANTS = {
    primary: "bg-primary text-primary-foreground hover:bg-primary/90",
    secondary: "bg-secondary text-secondary-foreground hover:bg-secondary/80",
    outline: "border border-input bg-background hover:bg-accent hover:text-accent-foreground",
    ghost: "hover:bg-accent hover:text-accent-foreground",
    link: "text-primary underline-offset-4 hover:underline",
    destructive: "bg-destructive text-destructive-foreground hover:bg-destructive/90"
  }.freeze
  
  SIZES = {
    default: "h-10 px-4 py-2",
    sm: "h-9 rounded-md px-3",
    lg: "h-11 rounded-md px-8",
    icon: "h-10 w-10"
  }.freeze
  
  def initialize(variant: :primary, size: :default, **options)
    @variant = variant
    @size = size
    @options = options
  end
  
  private
  
  def css_classes
    [
      "inline-flex items-center justify-center rounded-md text-sm font-medium ring-offset-background transition-colors focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50",
      VARIANTS[@variant.to_sym],
      SIZES[@size.to_sym],
      @options[:class]
    ].compact.join(" ")
  end
end
```

```erb
<%# app/components/button_component.html.erb %>
<%= tag.button(class: css_classes, **@options.except(:class)) do %>
  <%= content %>
<% end %>
```

**Usage:**

```erb
<%= render ButtonComponent.new(variant: :primary) do %>
  Click Me
<% end %>

<%= render ButtonComponent.new(variant: :secondary, size: :sm) do %>
  Small Button
<% end %>

<%= render ButtonComponent.new(variant: :destructive, disabled: true) do %>
  Disabled Button
<% end %>
```

### Card Component

The Card component is a container for related content.

```ruby
# app/components/card_component.rb
class CardComponent < ViewComponent::Base
  renders_one :header
  renders_one :title
  renders_one :description
  renders_one :content
  renders_one :footer
  
  def initialize(**options)
    @options = options
  end
  
  private
  
  def css_classes
    [
      "rounded-lg border border-border bg-card text-card-foreground shadow-sm",
      @options[:class]
    ].compact.join(" ")
  end
end
```

```erb
<%# app/components/card_component.html.erb %>
<div class="<%= css_classes %>" <%= @options.except(:class) %>>
  <% if header %>
    <div class="flex flex-col space-y-1.5 p-6">
      <%= header %>
    </div>
  <% end %>
  
  <% if title || description %>
    <div class="p-6 pt-0">
      <% if title %>
        <h3 class="text-2xl font-semibold leading-none tracking-tight"><%= title %></h3>
      <% end %>
      
      <% if description %>
        <p class="text-sm text-muted-foreground"><%= description %></p>
      <% end %>
    </div>
  <% end %>
  
  <% if content %>
    <div class="p-6 pt-0">
      <%= content %>
    </div>
  <% end %>
  
  <% if footer %>
    <div class="flex items-center p-6 pt-0">
      <%= footer %>
    </div>
  <% end %>
</div>
```

**Usage:**

```erb
<%= render CardComponent.new do |c| %>
  <% c.with_header do %>
    <h3 class="text-lg font-semibold">Card Header</h3>
  <% end %>
  
  <% c.with_content do %>
    <p>This is the main content of the card.</p>
  <% end %>
  
  <% c.with_footer do %>
    <%= render ButtonComponent.new(variant: :primary) do %>
      Action
    <% end %>
  <% end %>
<% end %>
```

## Form Components

### Input Component

The Input component is used for text input fields.

```ruby
# app/components/input_component.rb
class InputComponent < ViewComponent::Base
  def initialize(type: :text, **options)
    @type = type
    @options = options
  end
  
  private
  
  def css_classes
    [
      "flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50",
      @options[:class]
    ].compact.join(" ")
  end
end
```

```erb
<%# app/components/input_component.html.erb %>
<input 
  type="<%= @type %>" 
  class="<%= css_classes %>" 
  <%= @options.except(:class) %>
/>
```

**Usage:**

```erb
<%= render InputComponent.new(
  type: :text,
  placeholder: "Enter your name",
  name: "user[name]",
  id: "user_name"
) %>

<%= render InputComponent.new(
  type: :email,
  placeholder: "Email address",
  required: true
) %>
```

### Toggle Component

The Toggle component is used for boolean inputs.

```ruby
# app/components/toggle_component.rb
class ToggleComponent < ViewComponent::Base
  def initialize(pressed: false, **options)
    @pressed = pressed
    @options = options
  end
  
  private
  
  def css_classes
    [
      "inline-flex items-center justify-center rounded-md text-sm font-medium ring-offset-background transition-colors hover:bg-muted hover:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 data-[state=on]:bg-accent data-[state=on]:text-accent-foreground",
      @options[:class]
    ].compact.join(" ")
  end
  
  def data_attributes
    {
      controller: "toggle",
      toggle_pressed_value: @pressed,
      state: @pressed ? "on" : "off"
    }
  end
end
```

```erb
<%# app/components/toggle_component.html.erb %>
<button 
  type="button" 
  class="<%= css_classes %>" 
  data-controller="toggle"
  data-toggle-pressed-value="<%= @pressed %>"
  data-state="<%= @pressed ? 'on' : 'off' %>"
  data-action="toggle#toggle"
  <%= @options.except(:class) %>
>
  <%= content %>
</button>
```

**Usage:**

```erb
<%= render ToggleComponent.new(pressed: true) do %>
  Airplane Mode
<% end %>

<%= render ToggleComponent.new(pressed: false, class: "px-3") do %>
  Dark Mode
<% end %>
```

## Navigation Components

### Tabs Component

The Tabs component is used for switching between different views.

```ruby
# app/components/tabs_component.rb
class TabsComponent < ViewComponent::Base
  renders_many :tabs, "TabItem"
  
  def initialize(id: SecureRandom.hex(6), **options)
    @id = id
    @options = options
  end
  
  class TabItem < ViewComponent::Base
    attr_reader :value, :title
    
    def initialize(value:, title:, default: false, **options)
      @value = value
      @title = title
      @default = default
      @options = options
    end
    
    def default?
      @default
    end
    
    def css_classes
      [
        "inline-flex items-center justify-center whitespace-nowrap rounded-sm px-3 py-1.5 text-sm font-medium ring-offset-background transition-all focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:pointer-events-none disabled:opacity-50 data-[state=active]:bg-background data-[state=active]:text-foreground data-[state=active]:shadow-sm",
        @options[:class]
      ].compact.join(" ")
    end
  end
  
  private
  
  def default_tab
    tabs.find(&:default?) || tabs.first
  end
end
```

```erb
<%# app/components/tabs_component.html.erb %>
<div data-controller="tabs" data-tabs-active-value="<%= default_tab&.value %>" id="tabs-<%= @id %>">
  <div class="border-b">
    <div class="flex h-10 items-center gap-4">
      <% tabs.each do |tab| %>
        <button 
          type="button" 
          class="<%= tab.css_classes %>" 
          data-tabs-target="tab" 
          data-value="<%= tab.value %>" 
          data-state="<%= tab.value == default_tab&.value ? 'active' : 'inactive' %>"
          data-action="tabs#activate"
        >
          <%= tab.title %>
        </button>
      <% end %>
    </div>
  </div>
  
  <div class="mt-2">
    <% tabs.each do |tab| %>
      <div 
        data-tabs-target="panel" 
        data-value="<%= tab.value %>" 
        class="<%= tab.value == default_tab&.value ? '' : 'hidden' %>"
      >
        <%= tab.content %>
      </div>
    <% end %>
  </div>
</div>
```

**Usage:**

```erb
<%= render TabsComponent.new do |c| %>
  <% c.with_tab(value: "overview", title: "Overview", default: true) do %>
    <p>Overview content here</p>
  <% end %>
  
  <% c.with_tab(value: "analytics", title: "Analytics") do %>
    <p>Analytics content here</p>
  <% end %>
  
  <% c.with_tab(value: "reports", title: "Reports") do %>
    <p>Reports content here</p>
  <% end %>
<% end %>
```

## Feedback Components

### Alert Component

The Alert component is used for displaying important messages.

```ruby
# app/components/alert_component.rb
class AlertComponent < ViewComponent::Base
  VARIANTS = {
    default: "bg-background text-foreground",
    destructive: "bg-destructive text-destructive-foreground",
    success: "bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-100",
    warning: "bg-yellow-100 text-yellow-800 dark:bg-yellow-900 dark:text-yellow-100",
    info: "bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-100"
  }.freeze
  
  def initialize(variant: :default, dismissible: false, **options)
    @variant = variant
    @dismissible = dismissible
    @options = options
  end
  
  private
  
  def css_classes
    [
      "relative w-full rounded-lg border p-4",
      VARIANTS[@variant.to_sym],
      @options[:class]
    ].compact.join(" ")
  end
end
```

```erb
<%# app/components/alert_component.html.erb %>
<div 
  class="<%= css_classes %>" 
  role="alert"
  <%= "data-controller='alert'" if @dismissible %>
  <%= @options.except(:class) %>
>
  <div class="flex items-start gap-4">
    <div class="flex-1">
      <%= content %>
    </div>
    
    <% if @dismissible %>
      <button 
        type="button" 
        class="inline-flex h-6 w-6 items-center justify-center rounded-md text-foreground/50 hover:text-foreground"
        data-action="alert#dismiss"
      >
        <span class="sr-only">Dismiss</span>
        <svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="h-4 w-4">
          <line x1="18" y1="6" x2="6" y2="18"></line>
          <line x1="6" y1="6" x2="18" y2="18"></line>
        </svg>
      </button>
    <% end %>
  </div>
</div>
```

**Usage:**

```erb
<%= render AlertComponent.new(variant: :info) do %>
  <p>This is an informational message.</p>
<% end %>

<%= render AlertComponent.new(variant: :warning, dismissible: true) do %>
  <h4 class="font-medium">Warning</h4>
  <p>This is a warning message that can be dismissed.</p>
<% end %>
```

## Data Display Components

### Table Component

The Table component is used for displaying tabular data.

```ruby
# app/components/table_component.rb
class TableComponent < ViewComponent::Base
  renders_one :header
  renders_one :body
  renders_one :footer
  
  def initialize(**options)
    @options = options
  end
  
  private
  
  def css_classes
    [
      "w-full caption-bottom text-sm",
      @options[:class]
    ].compact.join(" ")
  end
end
```

```erb
<%# app/components/table_component.html.erb %>
<div class="relative w-full overflow-auto">
  <table class="<%= css_classes %>" <%= @options.except(:class) %>>
    <% if header %>
      <thead class="[&_tr]:border-b">
        <%= header %>
      </thead>
    <% end %>
    
    <% if body %>
      <tbody class="[&_tr:last-child]:border-0">
        <%= body %>
      </tbody>
    <% end %>
    
    <% if footer %>
      <tfoot class="border-t bg-muted/50">
        <%= footer %>
      </tfoot>
    <% end %>
  </table>
</div>
```

**Usage:**

```erb
<%= render TableComponent.new do |c| %>
  <% c.with_header do %>
    <tr class="border-b transition-colors hover:bg-muted/50 data-[state=selected]:bg-muted">
      <th class="h-12 px-4 text-left align-middle font-medium">Name</th>
      <th class="h-12 px-4 text-left align-middle font-medium">Email</th>
      <th class="h-12 px-4 text-left align-middle font-medium">Role</th>
      <th class="h-12 px-4 text-right align-middle font-medium">Actions</th>
    </tr>
  <% end %>
  
  <% c.with_body do %>
    <tr class="border-b transition-colors hover:bg-muted/50 data-[state=selected]:bg-muted">
      <td class="p-4 align-middle">John Doe</td>
      <td class="p-4 align-middle">john@example.com</td>
      <td class="p-4 align-middle">Admin</td>
      <td class="p-4 align-middle text-right">
        <%= render ButtonComponent.new(variant: :ghost, size: :sm) do %>
          Edit
        <% end %>
      </td>
    </tr>
    <tr class="border-b transition-colors hover:bg-muted/50 data-[state=selected]:bg-muted">
      <td class="p-4 align-middle">Jane Smith</td>
      <td class="p-4 align-middle">jane@example.com</td>
      <td class="p-4 align-middle">User</td>
      <td class="p-4 align-middle text-right">
        <%= render ButtonComponent.new(variant: :ghost, size: :sm) do %>
          Edit
        <% end %>
      </td>
    </tr>
  <% end %>
<% end %>
```

## Financial Components

### AccountCard Component

The AccountCard component is used for displaying account information.

```ruby
# app/components/account_card_component.rb
class AccountCardComponent < ViewComponent::Base
  def initialize(account:, **options)
    @account = account
    @options = options
  end
  
  private
  
  def css_classes
    [
      "rounded-lg border border-border bg-card text-card-foreground shadow-sm",
      @options[:class]
    ].compact.join(" ")
  end
  
  def account_type_icon
    case @account.accountable_type
    when "Depository"
      "bank"
    when "CreditCard"
      "credit-card"
    when "Investment"
      "trending-up"
    when "Loan"
      "landmark"
    when "Property"
      "home"
    when "Vehicle"
      "car"
    when "Crypto"
      "bitcoin"
    else
      "circle"
    end
  end
  
  def account_balance_class
    if @account.balance.to_f.negative?
      "text-destructive"
    else
      "text-foreground"
    end
  end
end
```

```erb
<%# app/components/account_card_component.html.erb %>
<div class="<%= css_classes %>" <%= @options.except(:class) %>>
  <div class="p-6">
    <div class="flex items-center justify-between">
      <div class="flex items-center gap-3">
        <div class="flex h-10 w-10 items-center justify-center rounded-full bg-primary/10 text-primary">
          <%= render FilledIconComponent.new(name: account_type_icon) %>
        </div>
        <div>
          <h3 class="font-medium"><%= @account.name %></h3>
          <p class="text-sm text-muted-foreground"><%= @account.accountable_type %></p>
        </div>
      </div>
      
      <div class="text-right">
        <p class="text-2xl font-semibold <%= account_balance_class %>">
          <%= format_currency(@account.balance, @account.currency) %>
        </p>
        <% if @account.available_balance.present? && @account.available_balance != @account.balance %>
          <p class="text-sm text-muted-foreground">
            <%= format_currency(@account.available_balance, @account.currency) %> available
          </p>
        <% end %>
      </div>
    </div>
  </div>
  
  <div class="border-t p-4">
    <div class="flex justify-between">
      <div class="text-sm text-muted-foreground">
        Last updated: <%= time_ago_in_words(@account.updated_at) %> ago
      </div>
      
      <div>
        <%= link_to account_path(@account), class: "text-sm text-primary hover:underline" do %>
          View details
        <% end %>
      </div>
    </div>
  </div>
</div>
```

**Usage:**

```erb
<%= render AccountCardComponent.new(account: @checking_account) %>

<div class="grid gap-4 md:grid-cols-2 lg:grid-cols-3">
  <% @accounts.each do |account| %>
    <%= render AccountCardComponent.new(account: account) %>
  <% end %>
</div>
```

## Component Documentation

All components are documented in Lookbook, which provides:

1. Interactive examples
2. Code snippets
3. Props documentation
4. Theme switching preview

To view the component documentation, visit `/lookbook` in development mode.

## Component Best Practices

1. **Theme Awareness**: All components should support both light and dark themes
2. **Accessibility**: Follow WCAG 2.1 AA standards for all components
3. **Responsive Design**: Components should adapt to different screen sizes
4. **Consistent API**: Follow consistent patterns for component props and options
5. **Composition**: Use composition over inheritance for component flexibility
6. **Testing**: Include unit and visual regression tests for all components

## Component Testing

```ruby
# test/components/button_component_test.rb
require "test_helper"

class ButtonComponentTest < ViewComponent::TestCase
  test "renders button with default variant" do
    render_inline(ButtonComponent.new) { "Click me" }
    
    assert_selector "button.bg-primary", text: "Click me"
  end
  
  test "renders button with custom variant" do
    render_inline(ButtonComponent.new(variant: :secondary)) { "Secondary" }
    
    assert_selector "button.bg-secondary", text: "Secondary"
  end
  
  test "renders button with custom size" do
    render_inline(ButtonComponent.new(size: :sm)) { "Small" }
    
    assert_selector "button.h-9", text: "Small"
  end
  
  test "passes through HTML attributes" do
    render_inline(ButtonComponent.new(disabled: true)) { "Disabled" }
    
    assert_selector "button[disabled]", text: "Disabled"
  end
end
```