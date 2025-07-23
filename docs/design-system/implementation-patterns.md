# Implementation Patterns

This document outlines common implementation patterns and best practices for working with the Maybe Finance design system. These patterns ensure consistency, maintainability, and performance across the application.

## ViewComponent Patterns

### Basic Component Structure

```ruby
# app/components/ui/button_component.rb
module Ui
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
end
```

```erb
<%# app/components/ui/button_component.html.erb %>
<%= tag.button(class: css_classes, **@options.except(:class)) do %>
  <%= content %>
<% end %>
```

### Component with Slots

```ruby
# app/components/ui/card_component.rb
module Ui
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
end
```

```erb
<%# app/components/ui/card_component.html.erb %>
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

### Component with Collections

```ruby
# app/components/ui/select_component.rb
module Ui
  class SelectComponent < ViewComponent::Base
    renders_many :options, "OptionComponent"
    
    def initialize(name:, id: nil, **options)
      @name = name
      @id = id || name.to_s.parameterize
      @options = options
    end
    
    class OptionComponent < ViewComponent::Base
      def initialize(value:, selected: false, **options)
        @value = value
        @selected = selected
        @options = options
      end
      
      def call
        tag.option(
          content,
          value: @value,
          selected: @selected,
          **@options
        )
      end
    end
    
    private
    
    def css_classes
      [
        "flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2",
        @options[:class]
      ].compact.join(" ")
    end
  end
end
```

```erb
<%# app/components/ui/select_component.html.erb %>
<select 
  name="<%= @name %>" 
  id="<%= @id %>" 
  class="<%= css_classes %>" 
  <%= @options.except(:class) %>
>
  <%= options %>
</select>
```

## Stimulus Controller Patterns

### Basic Controller

```javascript
// app/javascript/controllers/ui/toggle_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    pressed: { type: Boolean, default: false }
  }
  
  static targets = ["indicator"]
  
  connect() {
    this.updateState()
  }
  
  toggle() {
    this.pressedValue = !this.pressedValue
  }
  
  pressedValueChanged() {
    this.updateState()
    this.dispatch("toggle", { detail: { pressed: this.pressedValue } })
  }
  
  updateState() {
    this.element.setAttribute("aria-pressed", this.pressedValue)
    this.element.dataset.state = this.pressedValue ? "on" : "off"
    
    if (this.hasIndicatorTarget) {
      this.indicatorTarget.classList.toggle("translate-x-5", this.pressedValue)
      this.indicatorTarget.classList.toggle("translate-x-0", !this.pressedValue)
    }
  }
}
```

### Controller with External Actions

```javascript
// app/javascript/controllers/ui/dialog_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog", "overlay", "content"]
  
  connect() {
    this.keydownHandler = this.handleKeydown.bind(this)
    document.addEventListener("keydown", this.keydownHandler)
  }
  
  disconnect() {
    document.removeEventListener("keydown", this.keydownHandler)
  }
  
  open() {
    this.dialogTarget.showModal()
    document.body.classList.add("overflow-hidden")
    this.dispatch("open")
    
    // Focus first focusable element
    setTimeout(() => {
      const focusable = this.contentTarget.querySelectorAll(
        'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
      )
      if (focusable.length) focusable[0].focus()
    }, 50)
  }
  
  close() {
    this.dialogTarget.close()
    document.body.classList.remove("overflow-hidden")
    this.dispatch("close")
  }
  
  handleKeydown(event) {
    if (event.key === "Escape" && this.dialogTarget.open) {
      this.close()
    }
  }
  
  handleOverlayClick(event) {
    if (event.target === this.overlayTarget) {
      this.close()
    }
  }
}
```

### Controller with State Management

```javascript
// app/javascript/controllers/ui/tabs_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["tab", "panel"]
  static values = {
    active: String
  }
  
  connect() {
    if (!this.activeValue && this.tabTargets.length) {
      this.activeValue = this.tabTargets[0].dataset.value
    }
  }
  
  activate(event) {
    const clickedTab = event.currentTarget
    this.activeValue = clickedTab.dataset.value
  }
  
  activeValueChanged() {
    this.tabTargets.forEach(tab => {
      const isActive = tab.dataset.value === this.activeValue
      tab.setAttribute("aria-selected", isActive)
      tab.setAttribute("data-state", isActive ? "active" : "inactive")
      tab.setAttribute("tabindex", isActive ? 0 : -1)
    })
    
    this.panelTargets.forEach(panel => {
      const isActive = panel.dataset.value === this.activeValue
      panel.hidden = !isActive
    })
    
    this.dispatch("change", { detail: { value: this.activeValue } })
  }
}
```

## Theme Integration Patterns

### Theme-Aware Component

```ruby
# app/components/ui/alert_component.rb
module Ui
  class AlertComponent < ViewComponent::Base
    VARIANTS = {
      default: "bg-background text-foreground",
      destructive: "bg-destructive/15 text-destructive border-destructive/20",
      success: "bg-success/15 text-success border-success/20",
      warning: "bg-warning/15 text-warning border-warning/20",
      info: "bg-info/15 text-info border-info/20"
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
end
```

### Theme Switching in JavaScript

```javascript
// app/javascript/controllers/theme_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    userPreference: { type: String, default: "system" }
  }
  
  connect() {
    this.initializeTheme()
    
    // Listen for system preference changes
    this.mediaQuery = window.matchMedia("(prefers-color-scheme: dark)")
    this.mediaQueryHandler = this.handleMediaQueryChange.bind(this)
    this.mediaQuery.addEventListener("change", this.mediaQueryHandler)
  }
  
  disconnect() {
    this.mediaQuery.removeEventListener("change", this.mediaQueryHandler)
  }
  
  toggle() {
    const currentTheme = document.documentElement.getAttribute("data-theme")
    const newTheme = currentTheme === "dark" ? "light" : "dark"
    this.setTheme(newTheme)
    this.userPreferenceValue = newTheme
  }
  
  setLight() {
    this.setTheme("light")
    this.userPreferenceValue = "light"
  }
  
  setDark() {
    this.setTheme("dark")
    this.userPreferenceValue = "dark"
  }
  
  setSystem() {
    this.userPreferenceValue = "system"
    this.initializeTheme()
  }
  
  initializeTheme() {
    if (this.userPreferenceValue === "system") {
      const systemPreference = this.mediaQuery.matches ? "dark" : "light"
      this.setTheme(systemPreference)
    } else {
      this.setTheme(this.userPreferenceValue)
    }
  }
  
  handleMediaQueryChange(event) {
    if (this.userPreferenceValue === "system") {
      this.setTheme(event.matches ? "dark" : "light")
    }
  }
  
  setTheme(theme) {
    document.documentElement.setAttribute("data-theme", theme)
    localStorage.setItem("theme", theme)
    
    // Dispatch event for other components to react
    document.dispatchEvent(new CustomEvent("theme:changed", {
      detail: { theme }
    }))
  }
  
  userPreferenceValueChanged(value) {
    localStorage.setItem("theme-preference", value)
    
    // Save to server if user is logged in
    if (this.hasServerEndpointValue) {
      this.savePreferenceToServer(value)
    }
  }
  
  savePreferenceToServer(preference) {
    fetch(this.serverEndpointValue, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content
      },
      body: JSON.stringify({ theme_preference: preference })
    })
  }
}
```

## Form Integration Patterns

### Form with Validation

```ruby
# app/components/ui/form_component.rb
module Ui
  class FormComponent < ViewComponent::Base
    renders_many :fields, "FieldComponent"
    renders_one :actions
    
    def initialize(model: nil, **options)
      @model = model
      @options = options
    end
    
    class FieldComponent < ViewComponent::Base
      def call
        content_tag(:div, content, class: "form-group space-y-2 mb-4")
      end
    end
    
    private
    
    def form_errors
      return unless @model && @model.errors.any?
      
      content_tag(:div, class: "bg-destructive/10 text-destructive p-4 rounded-md mb-6") do
        concat content_tag(:h2, "#{pluralize(@model.errors.count, 'error')} prohibited this #{@model.class.name.downcase} from being saved:", class: "font-medium")
        concat content_tag(:ul, class: "list-disc list-inside mt-2") do
          @model.errors.full_messages.each do |message|
            concat content_tag(:li, message)
          end
        end
      end
    end
  end
end
```

```erb
<%# app/components/ui/form_component.html.erb %>
<%= form_with model: @model, **@options do |form| %>
  <%= form_errors %>
  
  <div class="space-y-6">
    <%= fields %>
    
    <% if actions %>
      <div class="form-actions">
        <%= actions %>
      </div>
    <% end %>
  </div>
<% end %>
```

### Input with Error Handling

```ruby
# app/components/ui/input_component.rb
module Ui
  class InputComponent < ViewComponent::Base
    def initialize(type: :text, label: nil, error: nil, hint: nil, **options)
      @type = type
      @label = label
      @error = error
      @hint = hint
      @options = options
    end
    
    private
    
    def input_id
      @options[:id] || @options[:name]&.parameterize || SecureRandom.hex(6)
    end
    
    def css_classes
      [
        "flex h-10 w-full rounded-md border px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50",
        @error.present? ? "border-destructive" : "border-input",
        @options[:class]
      ].compact.join(" ")
    end
    
    def aria_attributes
      attrs = {}
      
      if @error.present?
        attrs["aria-invalid"] = true
        attrs["aria-describedby"] = "#{input_id}-error"
      elsif @hint.present?
        attrs["aria-describedby"] = "#{input_id}-hint"
      end
      
      attrs.merge(@options[:aria] || {})
    end
  end
end
```

```erb
<%# app/components/ui/input_component.html.erb %>
<div class="space-y-2">
  <% if @label.present? %>
    <label for="<%= input_id %>" class="block text-sm font-medium">
      <%= @label %>
      <% if @options[:required] %>
        <span class="text-destructive">*</span>
      <% end %>
    </label>
  <% end %>
  
  <input 
    type="<%= @type %>" 
    id="<%= input_id %>" 
    class="<%= css_classes %>" 
    <%= aria_attributes.map { |k, v| "#{k}=\"#{v}\"" }.join(" ").html_safe %>
    <%= @options.except(:class, :aria) %>
  />
  
  <% if @error.present? %>
    <p id="<%= input_id %>-error" class="text-sm text-destructive"><%= @error %></p>
  <% elsif @hint.present? %>
    <p id="<%= input_id %>-hint" class="text-sm text-muted-foreground"><%= @hint %></p>
  <% end %>
</div>
```

## Layout Integration Patterns

### Page Layout Component

```ruby
# app/components/ui/page_layout_component.rb
module Ui
  class PageLayoutComponent < ViewComponent::Base
    renders_one :header
    renders_one :sidebar
    renders_one :content
    renders_one :footer
    
    def initialize(container: true, **options)
      @container = container
      @options = options
    end
    
    private
    
    def container_classes
      @container ? "container mx-auto px-4" : ""
    end
  end
end
```

```erb
<%# app/components/ui/page_layout_component.html.erb %>
<div class="<%= @options[:class] %>">
  <% if header %>
    <header class="<%= container_classes %> py-6">
      <%= header %>
    </header>
  <% end %>
  
  <div class="<%= container_classes %> py-6">
    <div class="flex flex-col lg:flex-row gap-6">
      <% if sidebar %>
        <aside class="w-full lg:w-64 shrink-0">
          <%= sidebar %>
        </aside>
      <% end %>
      
      <main class="flex-1">
        <%= content %>
      </main>
    </div>
  </div>
  
  <% if footer %>
    <footer class="<%= container_classes %> py-6 border-t">
      <%= footer %>
    </footer>
  <% end %>
</div>
```

### Grid Layout Component

```ruby
# app/components/ui/grid_component.rb
module Ui
  class GridComponent < ViewComponent::Base
    def initialize(cols: 1, sm: nil, md: nil, lg: nil, xl: nil, gap: 6, **options)
      @cols = cols
      @sm = sm
      @md = md
      @lg = lg
      @xl = xl
      @gap = gap
      @options = options
    end
    
    private
    
    def css_classes
      [
        "grid",
        "grid-cols-#{@cols}",
        @sm ? "sm:grid-cols-#{@sm}" : nil,
        @md ? "md:grid-cols-#{@md}" : nil,
        @lg ? "lg:grid-cols-#{@lg}" : nil,
        @xl ? "xl:grid-cols-#{@xl}" : nil,
        "gap-#{@gap}",
        @options[:class]
      ].compact.join(" ")
    end
  end
end
```

```erb
<%# app/components/ui/grid_component.html.erb %>
<div class="<%= css_classes %>" <%= @options.except(:class) %>>
  <%= content %>
</div>
```

## Testing Patterns

### Component Unit Testing

```ruby
# test/components/ui/button_component_test.rb
require "test_helper"

class Ui::ButtonComponentTest < ViewComponent::TestCase
  test "renders button with default variant" do
    render_inline(Ui::ButtonComponent.new) { "Click me" }
    
    assert_selector "button.bg-primary", text: "Click me"
  end
  
  test "renders button with custom variant" do
    render_inline(Ui::ButtonComponent.new(variant: :secondary)) { "Secondary" }
    
    assert_selector "button.bg-secondary", text: "Secondary"
  end
  
  test "renders button with custom size" do
    render_inline(Ui::ButtonComponent.new(size: :sm)) { "Small" }
    
    assert_selector "button.h-9", text: "Small"
  end
  
  test "passes through HTML attributes" do
    render_inline(Ui::ButtonComponent.new(disabled: true)) { "Disabled" }
    
    assert_selector "button[disabled]", text: "Disabled"
  end
  
  test "renders as link when href is provided" do
    render_inline(Ui::ButtonComponent.new(href: "/path")) { "Link Button" }
    
    assert_selector "a[href='/path']", text: "Link Button"
  end
end
```

### Theme Testing

```ruby
# test/components/ui/theme_test.rb
require "test_helper"

class ThemeTest < ViewComponent::TestCase
  include ThemeTestHelper
  
  test "component renders correctly in light theme" do
    with_theme(:light) do
      render_inline(Ui::CardComponent.new) { "Content" }
      
      assert_selector ".bg-card", text: "Content"
      # Additional light theme assertions
    end
  end
  
  test "component renders correctly in dark theme" do
    with_theme(:dark) do
      render_inline(Ui::CardComponent.new) { "Content" }
      
      assert_selector ".bg-card", text: "Content"
      # Additional dark theme assertions
    end
  end
end
```

```ruby
# test/support/theme_test_helper.rb
module ThemeTestHelper
  def with_theme(theme)
    original_theme = page.evaluate_script("document.documentElement.getAttribute('data-theme')")
    page.execute_script("document.documentElement.setAttribute('data-theme', '#{theme}')")
    yield
    page.execute_script("document.documentElement.setAttribute('data-theme', '#{original_theme || 'light'}')")
  end
end
```

### Accessibility Testing

```ruby
# test/components/ui/accessibility_test.rb
require "test_helper"

class AccessibilityTest < ViewComponent::TestCase
  include AccessibilityTestHelper
  
  test "button has accessible name" do
    render_inline(Ui::ButtonComponent.new(aria: { label: "Close" }))
    
    assert_selector "button[aria-label='Close']"
  end
  
  test "dialog has proper ARIA attributes" do
    render_inline(Ui::DialogComponent.new(id: "test-dialog", title: "Dialog Title"))
    
    assert_selector "dialog[aria-labelledby]"
    assert_selector "h2#test-dialog-title", text: "Dialog Title"
  end
end
```

```ruby
# test/support/accessibility_test_helper.rb
module AccessibilityTestHelper
  def assert_sufficient_contrast(selector)
    element = find(selector)
    bg_color = element.native.style("background-color")
    text_color = element.native.style("color")
    
    # Calculate contrast ratio
    contrast_ratio = calculate_contrast_ratio(bg_color, text_color)
    
    assert contrast_ratio >= 4.5, "Contrast ratio of #{contrast_ratio} is below WCAG AA standard of 4.5:1"
  end
  
  def assert_keyboard_navigable(selector)
    elements = all(selector)
    
    # Tab through elements
    elements.each do |element|
      element.send_keys(:tab)
      assert_equal element, page.evaluate_script("document.activeElement")
    end
  end
  
  private
  
  def calculate_contrast_ratio(bg_color, text_color)
    # Implementation of contrast ratio calculation
    # This is a simplified example
    4.5 # Placeholder return value
  end
end
```

## Performance Optimization Patterns

### Lazy Loading Components

```ruby
# app/components/ui/lazy_component.rb
module Ui
  class LazyComponent < ViewComponent::Base
    def initialize(component:, **options)
      @component = component
      @options = options
    end
    
    def call
      content_tag(:div, "", 
        data: {
          controller: "lazy-load",
          lazy_load_component_value: @component,
          lazy_load_options_value: @options.to_json
        },
        class: "min-h-[100px]"
      )
    end
  end
end
```

```javascript
// app/javascript/controllers/lazy_load_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    component: String,
    options: Object
  }
  
  connect() {
    this.observer = new IntersectionObserver(this.handleIntersection.bind(this), {
      rootMargin: "100px"
    })
    
    this.observer.observe(this.element)
  }
  
  disconnect() {
    this.observer.disconnect()
  }
  
  handleIntersection(entries) {
    entries.forEach(entry => {
      if (entry.isIntersecting) {
        this.loadComponent()
        this.observer.disconnect()
      }
    })
  }
  
  loadComponent() {
    fetch(`/components/${this.componentValue}`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("meta[name='csrf-token']").content
      },
      body: JSON.stringify(this.optionsValue)
    })
    .then(response => response.text())
    .then(html => {
      this.element.innerHTML = html
    })
  }
}
```

### Optimized Rendering

```ruby
# app/components/ui/optimized_list_component.rb
module Ui
  class OptimizedListComponent < ViewComponent::Base
    def initialize(items:, per_page: 20, **options)
      @items = items
      @per_page = per_page
      @options = options
    end
    
    private
    
    def paginated_items
      @items.first(@per_page)
    end
    
    def has_more_items?
      @items.size > @per_page
    end
  end
end
```

```erb
<%# app/components/ui/optimized_list_component.html.erb %>
<div 
  data-controller="infinite-scroll"
  data-infinite-scroll-url-value="<%= @options[:url] %>"
  data-infinite-scroll-page-value="1"
>
  <div data-infinite-scroll-target="container">
    <% paginated_items.each do |item| %>
      <%= render ItemComponent.new(item: item) %>
    <% end %>
  </div>
  
  <% if has_more_items? %>
    <div data-infinite-scroll-target="loader" class="flex justify-center p-4">
      <div class="animate-spin h-8 w-8 border-4 border-primary border-t-transparent rounded-full"></div>
    </div>
  <% end %>
</div>
```

## Common Implementation Examples

### Dashboard Card Implementation

```ruby
# Example usage of components for a dashboard card
def dashboard_card
  render Ui::CardComponent.new do |c|
    c.with_header do
      content_tag(:div, class: "flex items-center justify-between") do
        concat content_tag(:h3, "Account Balance", class: "text-lg font-medium")
        concat render(Ui::ButtonComponent.new(variant: :ghost, size: :sm)) { "View All" }
      end
    end
    
    c.with_content do
      content_tag(:div, class: "space-y-4") do
        concat content_tag(:p, "$12,345.67", class: "text-3xl font-bold")
        concat content_tag(:div, class: "flex items-center text-sm") do
          concat render(Ui::FilledIconComponent.new(name: "trending-up", class: "text-success mr-1"))
          concat content_tag(:span, "Up 12% from last month", class: "text-success")
        end
      end
    end
    
    c.with_footer do
      content_tag(:div, class: "text-sm text-muted-foreground") do
        "Last updated: #{time_ago_in_words(Time.current)} ago"
      end
    end
  end
end
```

### Form Implementation

```ruby
# Example usage of components for a form
def user_form
  render Ui::FormComponent.new(model: @user) do |f|
    f.with_field do
      render Ui::InputComponent.new(
        type: :text,
        label: "Name",
        name: "user[name]",
        value: @user.name,
        error: @user.errors[:name].first,
        required: true
      )
    end
    
    f.with_field do
      render Ui::InputComponent.new(
        type: :email,
        label: "Email",
        name: "user[email]",
        value: @user.email,
        error: @user.errors[:email].first,
        required: true
      )
    end
    
    f.with_field do
      render Ui::SelectComponent.new(
        label: "Country",
        name: "user[country]",
        selected: @user.country,
        error: @user.errors[:country].first
      ) do |s|
        s.with_option(value: "") { "Select a country" }
        s.with_option(value: "US") { "United States" }
        s.with_option(value: "CA") { "Canada" }
        s.with_option(value: "UK") { "United Kingdom" }
      end
    end
    
    f.with_field do
      render Ui::CheckboxComponent.new(
        name: "user[terms]",
        checked: @user.terms_accepted,
        error: @user.errors[:terms_accepted].first
      ) do
        safe_join([
          "I agree to the ",
          link_to("terms and conditions", terms_path, class: "text-primary hover:underline")
        ])
      end
    end
    
    f.with_actions do
      content_tag(:div, class: "flex justify-end space-x-2") do
        concat render(Ui::ButtonComponent.new(variant: :outline, href: users_path)) { "Cancel" }
        concat render(Ui::ButtonComponent.new(variant: :primary, type: :submit)) { "Save" }
      end
    end
  end
end
```

### Data Table Implementation

```ruby
# Example usage of components for a data table
def transactions_table
  render Ui::TableComponent.new do |t|
    t.with_header do
      content_tag(:tr) do
        concat content_tag(:th, "Date", class: "text-left p-4")
        concat content_tag(:th, "Description", class: "text-left p-4")
        concat content_tag(:th, "Category", class: "text-left p-4")
        concat content_tag(:th, "Amount", class: "text-right p-4")
      end
    end
    
    t.with_body do
      @transactions.map do |transaction|
        content_tag(:tr, class: "border-t border-border hover:bg-muted/50") do
          concat content_tag(:td, transaction.date.strftime("%b %d, %Y"), class: "p-4")
          concat content_tag(:td, transaction.description, class: "p-4")
          concat content_tag(:td, class: "p-4") do
            render Ui::BadgeComponent.new(variant: :outline) { transaction.category.name }
          end
          concat content_tag(:td, number_to_currency(transaction.amount), class: "p-4 text-right")
        end
      end
    end
  end
end
```

## Best Practices

1. **Component Composition**: Prefer composition over inheritance for component flexibility
2. **Single Responsibility**: Each component should have a single responsibility
3. **Consistent API**: Follow consistent patterns for component props and options
4. **Theme Awareness**: All components should support both light and dark themes
5. **Accessibility First**: Design components with accessibility in mind from the start
6. **Performance Optimization**: Optimize components for performance and bundle size
7. **Comprehensive Testing**: Include unit, visual, and accessibility tests for all components
8. **Clear Documentation**: Document all components with examples and usage guidelines
9. **Progressive Enhancement**: Design components to work without JavaScript when possible
10. **Responsive Design**: Ensure all components adapt to different screen sizes