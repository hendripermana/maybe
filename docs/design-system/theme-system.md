# Theme System

The Maybe Finance application uses a robust theme system that supports both light and dark modes, ensuring a consistent user experience across all components and pages.

## Theme Architecture

The theme system is built on CSS custom properties (variables) and data attributes, allowing for runtime theme switching without page reloads.

### Core Concepts

1. **Base Theme Definition**: Default light theme values defined in `:root`
2. **Theme Overrides**: Dark theme values defined in `[data-theme="dark"]`
3. **Theme Switching**: Controlled via `data-theme` attribute on the `<html>` element
4. **User Preferences**: Respects user's system preference with option to override

## Implementation

### HTML Structure

```html
<!DOCTYPE html>
<html data-theme="light">
  <head>
    <!-- ... -->
  </head>
  <body>
    <!-- Content adapts to the current theme -->
  </body>
</html>
```

### CSS Implementation

```css
/* Base theme (light) */
:root {
  --background: 210 40% 98%;
  --foreground: 224 71% 4%;
  /* Other theme variables */
}

/* Dark theme overrides */
[data-theme="dark"] {
  --background: 224 71% 4%;
  --foreground: 210 40% 98%;
  /* Other dark theme overrides */
}

/* Using theme variables */
body {
  background-color: hsl(var(--background));
  color: hsl(var(--foreground));
}
```

### JavaScript Theme Switching

```javascript
// Theme switching function
function setTheme(theme) {
  document.documentElement.setAttribute('data-theme', theme);
  localStorage.setItem('theme', theme);
  
  // Dispatch event for other components to react
  document.dispatchEvent(new CustomEvent('theme:changed', {
    detail: { theme }
  }));
}

// Get user preference
function getPreferredTheme() {
  const savedTheme = localStorage.getItem('theme');
  
  if (savedTheme) {
    return savedTheme;
  }
  
  // Check system preference
  return window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
}

// Initialize theme
document.addEventListener('DOMContentLoaded', () => {
  setTheme(getPreferredTheme());
  
  // Listen for system preference changes
  window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (e) => {
    if (localStorage.getItem('theme') === 'system') {
      setTheme(e.matches ? 'dark' : 'light');
    }
  });
});
```

### Stimulus Controller

```javascript
// app/javascript/controllers/theme_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    userPreference: { type: String, default: "system" }
  }
  
  connect() {
    this.initializeTheme();
  }
  
  toggle() {
    const currentTheme = document.documentElement.getAttribute('data-theme');
    const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
    this.setTheme(newTheme);
    this.userPreferenceValue = newTheme;
  }
  
  setLight() {
    this.setTheme('light');
    this.userPreferenceValue = 'light';
  }
  
  setDark() {
    this.setTheme('dark');
    this.userPreferenceValue = 'dark';
  }
  
  setSystem() {
    this.userPreferenceValue = 'system';
    this.initializeTheme();
  }
  
  initializeTheme() {
    if (this.userPreferenceValue === 'system') {
      const systemPreference = window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
      this.setTheme(systemPreference);
    } else {
      this.setTheme(this.userPreferenceValue);
    }
  }
  
  setTheme(theme) {
    document.documentElement.setAttribute('data-theme', theme);
    localStorage.setItem('theme', theme);
    
    // Dispatch event for other components to react
    document.dispatchEvent(new CustomEvent('theme:changed', {
      detail: { theme }
    }));
  }
  
  userPreferenceValueChanged(value) {
    localStorage.setItem('theme-preference', value);
  }
}
```

## Theme Customization

### User Preference Settings

The application allows users to customize their theme preference:

```ruby
# app/controllers/settings/preferences_controller.rb
def update
  current_user.update(theme_preference: params[:theme_preference])
  # ...
end
```

```erb
<%# app/views/settings/preferences/edit.html.erb %>
<div data-controller="theme">
  <h2>Theme Preferences</h2>
  
  <div class="theme-options">
    <button data-action="click->theme#setLight" class="theme-option <%= 'active' if current_user.theme_preference == 'light' %>">
      Light
    </button>
    
    <button data-action="click->theme#setDark" class="theme-option <%= 'active' if current_user.theme_preference == 'dark' %>">
      Dark
    </button>
    
    <button data-action="click->theme#setSystem" class="theme-option <%= 'active' if current_user.theme_preference == 'system' %>">
      System
    </button>
  </div>
</div>
```

### Theme Extension

For custom themes or brand-specific overrides, create additional theme data attributes:

```css
/* Custom branded theme */
[data-theme="branded"] {
  --primary: 220 90% 50%;
  --secondary: 280 80% 60%;
  /* Other overrides */
}
```

## Theme Transitions

To create smooth transitions between themes:

```css
/* Add transitions to elements that change with theme */
body {
  transition: background-color 0.3s ease, color 0.3s ease;
}

/* For all themed elements */
*,
*::before,
*::after {
  transition: background-color 0.3s ease, border-color 0.3s ease, color 0.3s ease, fill 0.3s ease;
}

/* Disable transitions for users who prefer reduced motion */
@media (prefers-reduced-motion: reduce) {
  *,
  *::before,
  *::after {
    transition-duration: 0.01ms !important;
  }
}
```

## Theme Testing

### Manual Testing

1. Visit `/theme-test.html` to test all components in both themes
2. Toggle between light and dark modes
3. Verify all components adapt correctly
4. Check for any hardcoded colors or inconsistencies

### Automated Testing

```ruby
# test/system/theme_test.rb
require "application_system_test_case"

class ThemeTest < ApplicationSystemTestCase
  test "theme switching works correctly" do
    visit root_path
    
    # Test light theme
    assert_selector "html[data-theme='light']"
    
    # Toggle to dark theme
    find("[data-action*='theme#toggle']").click
    assert_selector "html[data-theme='dark']"
    
    # Verify components adapt
    assert_no_selector ".bg-white", visible: true
    
    # Test system preference
    find("[data-action*='theme#setSystem']").click
    if system_prefers_dark_mode?
      assert_selector "html[data-theme='dark']"
    else
      assert_selector "html[data-theme='light']"
    end
  end
  
  private
  
  def system_prefers_dark_mode?
    page.evaluate_script("window.matchMedia('(prefers-color-scheme: dark)').matches")
  end
end
```

## Common Theme Issues and Solutions

### Issue: Hardcoded Colors

**Problem**: Components using hardcoded colors don't adapt to theme changes.

**Solution**: Replace hardcoded colors with theme variables:

```css
/* Before */
.element {
  background-color: white;
  color: black;
}

/* After */
.element {
  background-color: hsl(var(--background));
  color: hsl(var(--foreground));
}
```

### Issue: Theme Flashing

**Problem**: Page briefly shows wrong theme before JavaScript loads.

**Solution**: Add server-side theme initialization:

```erb
<%# In application layout %>
<html data-theme="<%= current_user&.theme_preference || 'system' %>">
  <head>
    <script>
      // Immediate theme initialization
      (function() {
        const savedTheme = localStorage.getItem('theme');
        const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
        
        let theme = '<%= current_user&.theme_preference || "system" %>';
        if (theme === 'system') {
          theme = prefersDark ? 'dark' : 'light';
        }
        
        document.documentElement.setAttribute('data-theme', theme);
      })();
    </script>
  </head>
  <!-- ... -->
</html>
```

### Issue: Third-Party Components

**Problem**: Third-party components don't respect the theme system.

**Solution**: Create theme-aware wrappers:

```css
/* Theme wrapper for third-party components */
.third-party-wrapper {
  --third-party-bg: hsl(var(--background));
  --third-party-text: hsl(var(--foreground));
  --third-party-border: hsl(var(--border));
  
  /* Override third-party variables */
  --vendor-background-color: var(--third-party-bg) !important;
  --vendor-text-color: var(--third-party-text) !important;
  --vendor-border-color: var(--third-party-border) !important;
}
```

## Performance Considerations

1. **Minimize DOM updates**: When switching themes, only update the `data-theme` attribute on the root element
2. **Use CSS variables efficiently**: Group related properties to reduce redundancy
3. **Preload theme**: Initialize theme before rendering to prevent flashing
4. **Optimize transitions**: Only add transitions to properties that change with theme
5. **Respect user preferences**: Honor reduced motion preferences

## Browser Support

CSS variables and data attributes are supported in all modern browsers:
- Chrome 49+
- Firefox 31+
- Safari 9.1+
- Edge 16+

For older browsers, consider providing a fixed theme or using a polyfill.