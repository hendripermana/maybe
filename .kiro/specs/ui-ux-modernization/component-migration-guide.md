# Component Migration Guide

This guide provides comprehensive instructions for migrating from legacy components to the modern Shadcn-inspired UI component library. It includes migration paths, examples, and best practices to ensure a smooth transition.

## Table of Contents

1. [Migration Overview](#migration-overview)
2. [General Migration Principles](#general-migration-principles)
3. [Component-Specific Migration Paths](#component-specific-migration-paths)
4. [Theme System Integration](#theme-system-integration)
5. [Automated Migration Tools](#automated-migration-tools)
6. [Testing Your Migration](#testing-your-migration)
7. [Common Patterns and Examples](#common-patterns-and-examples)
8. [Troubleshooting](#troubleshooting)

## Migration Overview

The UI modernization project introduces a new component library under the `Ui` namespace that follows Shadcn design principles and provides consistent theming across light and dark modes. This guide will help you migrate from legacy components to their modern equivalents.

### Key Differences Between Legacy and Modern Components

| Feature | Legacy Components | Modern UI Components |
|---------|------------------|---------------------|
| Namespace | Root namespace | `Ui` namespace |
| Theme Support | Limited, often hardcoded | Comprehensive CSS variables |
| Variants | Limited options | Multiple well-defined variants |
| Sizes | Inconsistent | Standardized size system |
| Accessibility | Basic | WCAG 2.1 AA compliant |
| Documentation | Minimal | Comprehensive Lookbook examples |
| Base Class | Various | `Ui::BaseComponent` |

## General Migration Principles

Follow these principles when migrating components:

1. **Namespace Change**: Move from root namespace to `Ui` namespace
2. **Parameter Standardization**: Adapt to standardized parameter naming
3. **CSS Variable Usage**: Replace hardcoded colors with CSS variables
4. **Variant Mapping**: Map legacy variants to appropriate modern variants
5. **Size Standardization**: Use the standardized size system (sm, md, lg, xl)
6. **Accessibility Enhancement**: Add proper ARIA attributes and keyboard support
7. **Theme Testing**: Test components in both light and dark themes

## Component-Specific Migration Paths

### Button Component

**Legacy:** `ButtonComponent`  
**Modern:** `Ui::ButtonComponent`

**Key Changes:**
- Added standardized variants (primary, secondary, destructive, outline, ghost, link)
- Added standardized sizes (sm, md, lg, xl)
- Added loading state with spinner
- Added icon support with positioning
- Improved accessibility with focus states

**Migration Example:**

```ruby
# Legacy
render ButtonComponent.new(class: "btn-primary") { "Submit" }

# Modern
render Ui::ButtonComponent.new(variant: :primary) { "Submit" }

# Legacy with icon
render ButtonComponent.new(class: "btn-primary") do
  concat icon("save")
  concat "Save Changes"
end

# Modern with icon
render Ui::ButtonComponent.new(variant: :primary, icon: "save") { "Save Changes" }

# Legacy disabled
render ButtonComponent.new(class: "btn-primary", disabled: true) { "Processing..." }

# Modern loading state
render Ui::ButtonComponent.new(variant: :primary, loading: true) { "Processing..." }
```

### Alert Component

**Legacy:** `AlertComponent`  
**Modern:** `Ui::AlertComponent`

**Key Changes:**
- Added title support
- Added dismissible functionality
- Standardized variants (default, info, success, warning, destructive)
- Added standardized sizes (sm, md, lg)
- Improved theme support

**Migration Example:**

```ruby
# Legacy
render AlertComponent.new(message: "Your changes have been saved", variant: :success)

# Modern
render Ui::AlertComponent.new(variant: :success) { "Your changes have been saved" }

# Legacy with custom class
render AlertComponent.new(message: "Please check your input", variant: :error, class: "mb-4")

# Modern with title and custom class
render Ui::AlertComponent.new(
  title: "Error",
  variant: :destructive,
  class: "mb-4"
) { "Please check your input" }

# Modern dismissible
render Ui::AlertComponent.new(
  variant: :warning,
  dismissible: true
) { "This message can be dismissed" }
```

### Card Component

**Legacy:** Various custom card implementations  
**Modern:** `Ui::CardComponent`

**Key Changes:**
- Standardized card structure with header, content, and footer
- Added variants (default, elevated, outlined, ghost, interactive)
- Added sizes (sm, md, lg, xl)
- Added interactive card support
- Improved theme consistency

**Migration Example:**

```ruby
# Legacy custom card
content_tag(:div, class: "bg-white border rounded-lg p-4 shadow-sm") do
  concat content_tag(:h3, "Card Title", class: "text-lg font-medium")
  concat content_tag(:p, "Card content goes here", class: "mt-2")
end

# Modern card
render Ui::CardComponent.new(title: "Card Title") { "Card content goes here" }

# Legacy interactive card
link_to(item_path, class: "block bg-white border rounded-lg p-4 shadow-sm hover:shadow-md") do
  concat content_tag(:h3, item.title, class: "text-lg font-medium")
  concat content_tag(:p, item.description, class: "mt-2")
end

# Modern interactive card
render Ui::CardComponent.new(
  title: item.title,
  variant: :interactive,
  href: item_path
) { item.description }

# Legacy card with footer
content_tag(:div, class: "bg-white border rounded-lg p-4 shadow-sm") do
  concat content_tag(:h3, "Card Title", class: "text-lg font-medium")
  concat content_tag(:p, "Card content goes here", class: "mt-2")
  concat content_tag(:div, class: "mt-4 pt-4 border-t") do
    concat render(ButtonComponent.new(class: "btn-primary")) { "Action" }
  end
end

# Modern card with footer
render Ui::CardComponent.new(title: "Card Title") do |card|
  card.with_content { "Card content goes here" }
  card.with_footer do
    render Ui::ButtonComponent.new(variant: :primary) { "Action" }
  end
end
```

### Input Component

**Legacy:** Various form helpers and custom inputs  
**Modern:** `Ui::InputComponent`, `Ui::SelectComponent`, `Ui::CheckboxComponent`

**Key Changes:**
- Unified interface for different input types
- Added standardized variants (default, outline, ghost, filled)
- Added standardized sizes (sm, md, lg, xl)
- Added proper error state handling
- Added help text support
- Improved accessibility with labels and ARIA attributes

**Migration Example:**

```ruby
# Legacy text input
form.text_field :name, class: "form-input", placeholder: "Enter your name"

# Modern text input
render Ui::InputComponent.new(
  label: "Name",
  name: "user[name]",
  placeholder: "Enter your name"
)

# Legacy select input
form.select :category_id, Category.all.map { |c| [c.name, c.id] }, { include_blank: "Select..." }, class: "form-select"

# Modern select input
render Ui::SelectComponent.new(
  label: "Category",
  name: "transaction[category_id]",
  include_blank: "Select..."
) do
  Category.all.each do |category|
    concat content_tag(:option, category.name, value: category.id)
  end
end

# Legacy input with error
form.text_field :email, class: "form-input #{'is-invalid' if form.object.errors[:email].present?}"
form.error_message :email, class: "text-red-500 text-sm mt-1" if form.object.errors[:email].present?

# Modern input with error
render Ui::InputComponent.new(
  label: "Email",
  name: "user[email]",
  value: form.object.email,
  error: form.object.errors[:email].first
)
```

### Dialog/Modal Component

**Legacy:** `DialogComponent`  
**Modern:** `Ui::ModalComponent`

**Key Changes:**
- Added standardized variants (default, centered, fullscreen)
- Added standardized sizes (sm, md, lg, xl, full)
- Improved keyboard navigation and focus management
- Added header, content, and footer sections
- Added backdrop click configuration

**Migration Example:**

```ruby
# Legacy dialog
render DialogComponent.new(id: "confirm-dialog", title: "Confirm Action") do
  concat content_tag(:p, "Are you sure you want to continue?")
  concat content_tag(:div, class: "mt-4 flex justify-end space-x-2") do
    concat button_tag("Cancel", type: "button", class: "btn-secondary", data: { action: "dialog#close" })
    concat button_tag("Confirm", type: "button", class: "btn-primary")
  end
end

# Modern modal
render Ui::ModalComponent.new(
  id: "confirm-modal",
  title: "Confirm Action",
  data: { controller: "ui--modal" }
) do |modal|
  modal.with_content { "Are you sure you want to continue?" }
  modal.with_footer do
    content_tag(:div, class: "flex justify-end space-x-2") do
      concat render(Ui::ButtonComponent.new(variant: :secondary, data: { action: "ui--modal#close" })) { "Cancel" }
      concat render(Ui::ButtonComponent.new(variant: :primary)) { "Confirm" }
    end
  end
end
```

### Tabs Component

**Legacy:** `TabsComponent` and `TabComponent`  
**Modern:** `Ui::TabsComponent`

**Key Changes:**
- Improved accessibility with proper ARIA roles
- Added keyboard navigation support
- Added standardized variants
- Improved theme consistency

**Migration Example:**

```ruby
# Legacy tabs
render TabsComponent.new do |tabs|
  tabs.with_tab(title: "Overview", active: true) { "Overview content" }
  tabs.with_tab(title: "Details") { "Details content" }
  tabs.with_tab(title: "History") { "History content" }
end

# Modern tabs
render Ui::TabsComponent.new do |tabs|
  tabs.with_tab(id: "overview", title: "Overview", active: true) { "Overview content" }
  tabs.with_tab(id: "details", title: "Details") { "Details content" }
  tabs.with_tab(id: "history", title: "History") { "History content" }
end
```

## Theme System Integration

The modern component library uses CSS variables for theming. When migrating components, replace hardcoded colors with theme variables:

### Color Token Mapping

| Legacy Hardcoded Color | Modern CSS Variable |
|------------------------|---------------------|
| `bg-white` | `bg-background` |
| `text-black` | `text-foreground` |
| `bg-gray-100` | `bg-muted` |
| `text-gray-500` | `text-muted-foreground` |
| `bg-blue-600` | `bg-primary` |
| `text-blue-600` | `text-primary` |
| `bg-red-600` | `bg-destructive` |
| `text-red-600` | `text-destructive` |

### Example of Theme Migration

```ruby
# Legacy with hardcoded colors
content_tag(:div, class: "bg-white text-black border border-gray-200 p-4")

# Modern with theme variables
content_tag(:div, class: "bg-background text-foreground border border-border p-4")
```

## Automated Migration Tools

To assist with component migration, we've created several tools:

### Component Finder Script

This script helps identify legacy components in your codebase:

```ruby
# Save as script/find_legacy_components.rb
#!/usr/bin/env ruby

require_relative "../config/environment"

LEGACY_COMPONENTS = [
  "ButtonComponent",
  "AlertComponent",
  "DialogComponent",
  "TabsComponent",
  "TabComponent",
  # Add other legacy components here
]

def find_in_views(pattern)
  results = {}
  Dir.glob("app/views/**/*.erb").each do |file|
    content = File.read(file)
    matches = content.scan(pattern)
    results[file] = matches if matches.any?
  end
  results
end

LEGACY_COMPONENTS.each do |component|
  puts "=== Finding usages of #{component} ==="
  pattern = /render\s+#{component}|<%= render\s+#{component}|<%=\s+render\(#{component}/
  results = find_in_views(pattern)
  
  if results.any?
    results.each do |file, matches|
      puts "#{file}: #{matches.count} occurrences"
    end
  else
    puts "No usages found"
  end
  puts "\n"
end
```

### Component Replacement Script

This script helps with automated replacement of simple component usages:

```ruby
# Save as script/replace_legacy_components.rb
#!/usr/bin/env ruby

require_relative "../config/environment"

REPLACEMENTS = {
  /render\s+ButtonComponent\.new\(class:\s*["']btn-primary["'](.*?)\)/ => 'render Ui::ButtonComponent.new(variant: :primary\1)',
  /render\s+ButtonComponent\.new\(class:\s*["']btn-secondary["'](.*?)\)/ => 'render Ui::ButtonComponent.new(variant: :secondary\1)',
  /render\s+AlertComponent\.new\(message:\s*(.*?),\s*variant:\s*:success(.*?)\)/ => 'render Ui::AlertComponent.new(variant: :success\2) { \1 }',
  /render\s+AlertComponent\.new\(message:\s*(.*?),\s*variant:\s*:error(.*?)\)/ => 'render Ui::AlertComponent.new(variant: :destructive\2) { \1 }',
  /render\s+AlertComponent\.new\(message:\s*(.*?),\s*variant:\s*:info(.*?)\)/ => 'render Ui::AlertComponent.new(variant: :info\2) { \1 }',
  /render\s+AlertComponent\.new\(message:\s*(.*?),\s*variant:\s*:warning(.*?)\)/ => 'render Ui::AlertComponent.new(variant: :warning\2) { \1 }',
  # Add more replacement patterns here
}

def replace_in_file(file, replacements)
  content = File.read(file)
  original_content = content.dup
  
  replacements.each do |pattern, replacement|
    content.gsub!(pattern, replacement)
  end
  
  if content != original_content
    File.write(file, content)
    puts "Updated #{file}"
  end
end

Dir.glob("app/views/**/*.erb").each do |file|
  replace_in_file(file, REPLACEMENTS)
end
```

## Testing Your Migration

After migrating components, follow these testing steps:

1. **Visual Testing**: Compare the appearance of the page before and after migration
2. **Theme Testing**: Test the component in both light and dark themes
3. **Responsive Testing**: Test the component at different screen sizes
4. **Accessibility Testing**: Verify keyboard navigation and screen reader compatibility
5. **Functional Testing**: Ensure all interactive behaviors work as expected

## Common Patterns and Examples

### Form Migration Example

**Legacy Form:**

```erb
<%= form_with(model: user, class: "space-y-4") do |form| %>
  <div class="form-group">
    <%= form.label :name, class: "form-label" %>
    <%= form.text_field :name, class: "form-input" %>
    <% if form.object.errors[:name].present? %>
      <p class="text-red-500 text-sm mt-1"><%= form.object.errors[:name].first %></p>
    <% end %>
  </div>
  
  <div class="form-group">
    <%= form.label :email, class: "form-label" %>
    <%= form.email_field :email, class: "form-input" %>
    <% if form.object.errors[:email].present? %>
      <p class="text-red-500 text-sm mt-1"><%= form.object.errors[:email].first %></p>
    <% end %>
  </div>
  
  <div class="form-actions">
    <%= form.submit "Save", class: "btn-primary" %>
    <%= link_to "Cancel", users_path, class: "btn-secondary" %>
  </div>
<% end %>
```

**Modern Form:**

```erb
<%= form_with(model: user, class: "space-y-6") do |form| %>
  <%= render Ui::FormComponent.new do |f| %>
    <%= f.with_field do %>
      <%= render Ui::InputComponent.new(
        label: "Name",
        name: "user[name]",
        value: form.object.name,
        error: form.object.errors[:name].first
      ) %>
    <% end %>
    
    <%= f.with_field do %>
      <%= render Ui::InputComponent.new(
        label: "Email",
        type: "email",
        name: "user[email]",
        value: form.object.email,
        error: form.object.errors[:email].first
      ) %>
    <% end %>
    
    <%= f.with_actions do %>
      <%= render Ui::ButtonComponent.new(variant: :primary, type: "submit") { "Save" } %>
      <%= render Ui::ButtonComponent.new(variant: :secondary, href: users_path) { "Cancel" } %>
    <% end %>
  <% end %>
<% end %>
```

### Card List Migration Example

**Legacy Card List:**

```erb
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
  <% items.each do |item| %>
    <div class="bg-white border rounded-lg p-4 shadow-sm">
      <h3 class="text-lg font-medium"><%= item.title %></h3>
      <p class="mt-2 text-gray-600"><%= item.description %></p>
      <div class="mt-4 pt-4 border-t flex justify-between">
        <span class="text-gray-500"><%= item.date %></span>
        <%= link_to "View", item_path(item), class: "text-blue-600 hover:underline" %>
      </div>
    </div>
  <% end %>
</div>
```

**Modern Card List:**

```erb
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
  <% items.each do |item| %>
    <%= render Ui::CardComponent.new(title: item.title) do |card| %>
      <%= card.with_content do %>
        <p class="text-muted-foreground"><%= item.description %></p>
      <% end %>
      
      <%= card.with_footer do %>
        <div class="flex justify-between">
          <span class="text-muted-foreground"><%= item.date %></span>
          <%= render Ui::LinkComponent.new(href: item_path(item)) { "View" } %>
        </div>
      <% end %>
    <% end %>
  <% end %>
</div>
```

### Dialog Migration Example

**Legacy Dialog:**

```erb
<%= render DialogComponent.new(id: "delete-dialog", title: "Confirm Deletion") do %>
  <p>Are you sure you want to delete this item? This action cannot be undone.</p>
  
  <div class="mt-4 flex justify-end space-x-2">
    <button type="button" class="btn-secondary" data-action="dialog#close">Cancel</button>
    <%= button_to "Delete", item_path(@item), method: :delete, class: "btn-destructive" %>
  </div>
<% end %>

<button type="button" class="btn-destructive" data-action="dialog#open" data-dialog-target="delete-dialog">
  Delete Item
</button>
```

**Modern Dialog:**

```erb
<%= render Ui::ModalComponent.new(
  id: "delete-modal",
  title: "Confirm Deletion",
  description: "This action cannot be undone.",
  data: { controller: "ui--modal" }
) do |modal| %>
  <%= modal.with_content do %>
    <p>Are you sure you want to delete this item?</p>
  <% end %>
  
  <%= modal.with_footer do %>
    <div class="flex justify-end space-x-2">
      <%= render Ui::ButtonComponent.new(
        variant: :secondary,
        data: { action: "ui--modal#close" }
      ) { "Cancel" } %>
      
      <%= render Ui::ButtonComponent.new(
        variant: :destructive,
        href: item_path(@item),
        data: { turbo_method: :delete }
      ) { "Delete" } %>
    </div>
  <% end %>
<% end %>

<%= render Ui::ButtonComponent.new(
  variant: :destructive,
  data: { action: "ui--modal#open", "ui--modal-target": "delete-modal" }
) { "Delete Item" } %>
```

## Troubleshooting

### Common Migration Issues

1. **Missing Parameters**: Modern components may require parameters that weren't needed in legacy components
   - Solution: Check the component documentation for required parameters

2. **Theme Inconsistencies**: Components look different in light and dark themes
   - Solution: Ensure all hardcoded colors are replaced with theme variables

3. **Layout Shifts**: Modern components may have different default spacing
   - Solution: Adjust container spacing or use size variants

4. **JavaScript Controller Issues**: Modern components may use different Stimulus controllers
   - Solution: Update data-controller and data-action attributes

5. **Nested Content Blocks**: Modern components often use named content blocks
   - Solution: Use the block syntax with named content sections

### Getting Help

If you encounter issues during migration:

1. Check the component documentation in Lookbook (`/lookbook` in development)
2. Review the component source code in `app/components/ui/`
3. Look at existing usage examples in the codebase
4. Consult the UI/UX modernization design document

## Conclusion

Migrating to the modern UI component library will improve theme consistency, accessibility, and maintainability of the application. Follow this guide to ensure a smooth transition from legacy components to their modern equivalents.

Remember that migration can be done incrementally, focusing on one page or section at a time. Prioritize high-visibility pages and components for the best user impact.