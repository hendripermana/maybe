# Layout Patterns

This document outlines the standard layout patterns used throughout the Maybe Finance application. These patterns ensure consistency in spacing, alignment, and responsiveness across all pages.

## Grid System

The Maybe Finance application uses a responsive grid system based on Tailwind CSS's grid utilities. This system provides consistent spacing and alignment across different screen sizes.

### Basic Grid

```erb
<div class="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
  <div>Item 1</div>
  <div>Item 2</div>
  <div>Item 3</div>
</div>
```

### Responsive Grid with Different Column Spans

```erb
<div class="grid grid-cols-1 md:grid-cols-3 gap-6">
  <div class="md:col-span-2">Main Content</div>
  <div>Sidebar</div>
</div>
```

### Auto-fit Grid for Card Layouts

```erb
<div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-6">
  <% @items.each do |item| %>
    <%= render CardComponent.new(item: item) %>
  <% end %>
</div>
```

## Page Layouts

### Standard Page Layout

```erb
<div class="container mx-auto px-4 py-6">
  <header class="mb-6">
    <h1 class="text-2xl font-bold">Page Title</h1>
    <p class="text-muted-foreground">Page description or subtitle</p>
  </header>
  
  <main>
    <!-- Page content -->
  </main>
</div>
```

### Dashboard Layout

```erb
<div class="container mx-auto px-4 py-6">
  <header class="mb-6">
    <div class="flex flex-col sm:flex-row sm:items-center sm:justify-between gap-4">
      <h1 class="text-2xl font-bold">Dashboard</h1>
      
      <div class="flex items-center gap-2">
        <!-- Action buttons -->
        <%= render ButtonComponent.new(variant: :primary) do %>
          New Item
        <% end %>
      </div>
    </div>
  </header>
  
  <div class="grid gap-6 md:grid-cols-2 lg:grid-cols-3">
    <!-- Dashboard cards -->
  </div>
</div>
```

### Two-Column Layout with Sidebar

```erb
<div class="container mx-auto px-4 py-6">
  <div class="flex flex-col lg:flex-row gap-6">
    <aside class="w-full lg:w-64 shrink-0">
      <!-- Sidebar content -->
    </aside>
    
    <main class="flex-1">
      <!-- Main content -->
    </main>
  </div>
</div>
```

### Three-Column Layout

```erb
<div class="container mx-auto px-4 py-6">
  <div class="grid grid-cols-1 lg:grid-cols-3 gap-6">
    <div>
      <!-- Left column -->
    </div>
    
    <div>
      <!-- Middle column -->
    </div>
    
    <div>
      <!-- Right column -->
    </div>
  </div>
</div>
```

## Section Layouts

### Card Section

```erb
<section class="bg-card rounded-lg border border-border p-6 shadow-sm">
  <h2 class="text-xl font-semibold mb-4">Section Title</h2>
  
  <div class="space-y-4">
    <!-- Section content -->
  </div>
</section>
```

### Split Section

```erb
<section class="bg-card rounded-lg border border-border overflow-hidden">
  <div class="grid grid-cols-1 md:grid-cols-2">
    <div class="p-6">
      <!-- Left content -->
    </div>
    
    <div class="bg-muted p-6">
      <!-- Right content -->
    </div>
  </div>
</section>
```

### Tabbed Section

```erb
<section class="bg-card rounded-lg border border-border p-6 shadow-sm">
  <%= render TabsComponent.new do |c| %>
    <% c.with_tab(value: "tab1", title: "First Tab", default: true) do %>
      <!-- Tab 1 content -->
    <% end %>
    
    <% c.with_tab(value: "tab2", title: "Second Tab") do %>
      <!-- Tab 2 content -->
    <% end %>
  <% end %>
</section>
```

## Spacing System

The Maybe Finance application uses a consistent spacing system based on the design tokens. The following spacing classes are commonly used:

- `gap-{size}`: For grid and flex gaps
- `p-{size}`, `px-{size}`, `py-{size}`: For padding
- `m-{size}`, `mx-{size}`, `my-{size}`: For margin
- `space-y-{size}`, `space-x-{size}`: For consistent spacing between children

### Standard Spacing Example

```erb
<div class="space-y-6">
  <section class="p-6 bg-card rounded-lg border border-border">
    <!-- Section content -->
  </section>
  
  <section class="p-6 bg-card rounded-lg border border-border">
    <!-- Section content -->
  </section>
</div>
```

## Responsive Patterns

### Mobile-First Approach

All layouts in Maybe Finance follow a mobile-first approach, where the base styles are for mobile devices and media queries are used to enhance the layout for larger screens.

```erb
<div class="flex flex-col md:flex-row gap-4">
  <div class="w-full md:w-1/3">
    <!-- Sidebar -->
  </div>
  
  <div class="w-full md:w-2/3">
    <!-- Main content -->
  </div>
</div>
```

### Responsive Typography

```erb
<h1 class="text-xl sm:text-2xl md:text-3xl font-bold">
  Responsive Heading
</h1>

<p class="text-sm md:text-base">
  Responsive paragraph text
</p>
```

### Responsive Navigation

```erb
<nav class="hidden md:flex space-x-4">
  <!-- Desktop navigation -->
</nav>

<button class="md:hidden" data-controller="mobile-menu">
  <!-- Mobile menu toggle -->
</button>
```

## Layout Best Practices

1. **Use Container**: Wrap page content in a `.container` class for consistent max-width
2. **Consistent Spacing**: Use the spacing system for consistent gaps between elements
3. **Mobile-First**: Start with mobile layouts and enhance for larger screens
4. **Semantic HTML**: Use appropriate HTML elements for their intended purpose
5. **Avoid Fixed Heights**: Use min-height instead of fixed heights when possible
6. **Prevent Layout Shifts**: Set explicit width/height for images and dynamic content
7. **Theme Awareness**: Ensure layouts work in both light and dark themes

## Common Layout Components

### Page Header

```erb
<header class="border-b border-border py-4">
  <div class="container mx-auto px-4 flex items-center justify-between">
    <h1 class="text-xl font-semibold"><%= page_title %></h1>
    
    <div class="flex items-center gap-2">
      <!-- Action buttons -->
    </div>
  </div>
</header>
```

### Content Card

```erb
<div class="bg-card rounded-lg border border-border p-6 shadow-sm">
  <h2 class="text-lg font-medium mb-4"><%= card_title %></h2>
  
  <div>
    <%= card_content %>
  </div>
</div>
```

### List Container

```erb
<div class="bg-card rounded-lg border border-border overflow-hidden">
  <div class="p-4 border-b border-border">
    <h3 class="font-medium"><%= list_title %></h3>
  </div>
  
  <ul class="divide-y divide-border">
    <% items.each do |item| %>
      <li class="p-4">
        <%= item.name %>
      </li>
    <% end %>
  </ul>
</div>
```

## Page-Specific Layout Patterns

### Dashboard Layout

The dashboard uses a grid of cards with different sizes:

```erb
<div class="grid gap-6">
  <!-- Full-width card -->
  <div class="col-span-full">
    <%= render CardComponent.new do |c| %>
      <% c.with_content do %>
        <!-- Chart or summary data -->
      <% end %>
    <% end %>
  </div>
  
  <!-- Half-width cards -->
  <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
    <div>
      <%= render CardComponent.new do |c| %>
        <!-- Card content -->
      <% end %>
    </div>
    
    <div>
      <%= render CardComponent.new do |c| %>
        <!-- Card content -->
      <% end %>
    </div>
  </div>
  
  <!-- Third-width cards -->
  <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
    <div>
      <%= render CardComponent.new do |c| %>
        <!-- Card content -->
      <% end %>
    </div>
    
    <div>
      <%= render CardComponent.new do |c| %>
        <!-- Card content -->
      <% end %>
    </div>
    
    <div>
      <%= render CardComponent.new do |c| %>
        <!-- Card content -->
      <% end %>
    </div>
  </div>
</div>
```

### Transactions Page Layout

```erb
<div class="space-y-6">
  <!-- Filters and search -->
  <div class="bg-card rounded-lg border border-border p-4">
    <!-- Filter controls -->
  </div>
  
  <!-- Transactions list -->
  <div class="bg-card rounded-lg border border-border overflow-hidden">
    <div class="p-4 border-b border-border">
      <h2 class="font-medium">Transactions</h2>
    </div>
    
    <div class="divide-y divide-border">
      <% @transactions.each do |transaction| %>
        <%= render TransactionItemComponent.new(transaction: transaction) %>
      <% end %>
    </div>
    
    <!-- Pagination -->
    <div class="p-4 border-t border-border">
      <!-- Pagination controls -->
    </div>
  </div>
</div>
```

### Settings Page Layout

```erb
<div class="grid grid-cols-1 lg:grid-cols-4 gap-6">
  <!-- Sidebar navigation -->
  <div class="lg:col-span-1">
    <nav class="bg-card rounded-lg border border-border overflow-hidden">
      <ul class="divide-y divide-border">
        <li>
          <a href="#profile" class="block p-4 hover:bg-accent hover:text-accent-foreground">
            Profile
          </a>
        </li>
        <li>
          <a href="#preferences" class="block p-4 hover:bg-accent hover:text-accent-foreground">
            Preferences
          </a>
        </li>
        <!-- More navigation items -->
      </ul>
    </nav>
  </div>
  
  <!-- Settings content -->
  <div class="lg:col-span-3">
    <div class="bg-card rounded-lg border border-border p-6">
      <!-- Settings form -->
    </div>
  </div>
</div>
```

## Accessibility Considerations

1. **Landmark Regions**: Use semantic landmark elements (`<header>`, `<main>`, `<nav>`, `<footer>`)
2. **Skip Links**: Include skip links for keyboard navigation
3. **Focus Order**: Ensure logical tab order for keyboard navigation
4. **Responsive Design**: Test layouts at different zoom levels and screen sizes
5. **Content Reflow**: Ensure content reflows properly at 400% zoom
6. **Sufficient Spacing**: Provide adequate spacing for touch targets (minimum 44x44px)