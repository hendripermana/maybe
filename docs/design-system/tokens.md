# Design Tokens

Design tokens are the foundational elements of the Maybe Finance design system. They represent the smallest visual attributes that construct the UI and ensure consistency across the application.

## Color Tokens

### Base Color Palette

These are the raw color values that form the foundation of our theme system:

```css
:root {
  /* Base colors */
  --gray-50: 210 40% 98%;
  --gray-100: 220 14% 96%;
  --gray-200: 220 13% 91%;
  --gray-300: 216 12% 84%;
  --gray-400: 218 11% 65%;
  --gray-500: 220 9% 46%;
  --gray-600: 215 14% 34%;
  --gray-700: 217 19% 27%;
  --gray-800: 215 28% 17%;
  --gray-900: 221 39% 11%;
  --gray-950: 224 71% 4%;
  
  --blue-50: 213 100% 98%;
  --blue-100: 214 95% 93%;
  --blue-200: 213 97% 87%;
  --blue-300: 212 96% 78%;
  --blue-400: 213 94% 68%;
  --blue-500: 217 91% 60%;
  --blue-600: 221 83% 53%;
  --blue-700: 224 76% 48%;
  --blue-800: 226 71% 40%;
  --blue-900: 224 64% 33%;
  --blue-950: 226 57% 21%;
  
  /* Additional base colors for green, red, yellow, etc. */
}
```

### Semantic Color Tokens

These tokens map to specific UI purposes and automatically adapt between themes:

```css
:root {
  /* Semantic tokens - Light theme defaults */
  --background: var(--gray-50);
  --foreground: var(--gray-950);
  
  --card: var(--gray-100);
  --card-foreground: var(--gray-950);
  
  --popover: var(--gray-100);
  --popover-foreground: var(--gray-950);
  
  --primary: var(--blue-600);
  --primary-foreground: var(--gray-50);
  
  --secondary: var(--gray-200);
  --secondary-foreground: var(--gray-900);
  
  --muted: var(--gray-200);
  --muted-foreground: var(--gray-600);
  
  --accent: var(--gray-200);
  --accent-foreground: var(--gray-900);
  
  --destructive: 0 84% 60%;
  --destructive-foreground: var(--gray-50);
  
  --border: var(--gray-300);
  --input: var(--gray-300);
  --ring: var(--blue-600);
}

[data-theme="dark"] {
  /* Dark theme overrides */
  --background: var(--gray-950);
  --foreground: var(--gray-50);
  
  --card: var(--gray-900);
  --card-foreground: var(--gray-50);
  
  --popover: var(--gray-900);
  --popover-foreground: var(--gray-50);
  
  --primary: var(--blue-500);
  --primary-foreground: var(--gray-950);
  
  --secondary: var(--gray-800);
  --secondary-foreground: var(--gray-50);
  
  --muted: var(--gray-800);
  --muted-foreground: var(--gray-400);
  
  --accent: var(--gray-800);
  --accent-foreground: var(--gray-50);
  
  --destructive: 0 62% 50%;
  --destructive-foreground: var(--gray-50);
  
  --border: var(--gray-700);
  --input: var(--gray-700);
  --ring: var(--blue-500);
}
```

## Typography Tokens

### Font Families

```css
:root {
  --font-sans: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', sans-serif;
  --font-mono: 'JetBrains Mono', Menlo, Monaco, Consolas, 'Liberation Mono', 'Courier New', monospace;
}
```

### Font Sizes

```css
:root {
  --font-size-xs: 0.75rem;    /* 12px */
  --font-size-sm: 0.875rem;   /* 14px */
  --font-size-base: 1rem;     /* 16px */
  --font-size-lg: 1.125rem;   /* 18px */
  --font-size-xl: 1.25rem;    /* 20px */
  --font-size-2xl: 1.5rem;    /* 24px */
  --font-size-3xl: 1.875rem;  /* 30px */
  --font-size-4xl: 2.25rem;   /* 36px */
  --font-size-5xl: 3rem;      /* 48px */
}
```

### Font Weights

```css
:root {
  --font-weight-thin: 100;
  --font-weight-extralight: 200;
  --font-weight-light: 300;
  --font-weight-normal: 400;
  --font-weight-medium: 500;
  --font-weight-semibold: 600;
  --font-weight-bold: 700;
  --font-weight-extrabold: 800;
  --font-weight-black: 900;
}
```

### Line Heights

```css
:root {
  --line-height-none: 1;
  --line-height-tight: 1.25;
  --line-height-snug: 1.375;
  --line-height-normal: 1.5;
  --line-height-relaxed: 1.625;
  --line-height-loose: 2;
}
```

## Spacing Tokens

```css
:root {
  --spacing-0: 0;
  --spacing-px: 1px;
  --spacing-0-5: 0.125rem;  /* 2px */
  --spacing-1: 0.25rem;     /* 4px */
  --spacing-1-5: 0.375rem;  /* 6px */
  --spacing-2: 0.5rem;      /* 8px */
  --spacing-2-5: 0.625rem;  /* 10px */
  --spacing-3: 0.75rem;     /* 12px */
  --spacing-3-5: 0.875rem;  /* 14px */
  --spacing-4: 1rem;        /* 16px */
  --spacing-5: 1.25rem;     /* 20px */
  --spacing-6: 1.5rem;      /* 24px */
  --spacing-7: 1.75rem;     /* 28px */
  --spacing-8: 2rem;        /* 32px */
  --spacing-9: 2.25rem;     /* 36px */
  --spacing-10: 2.5rem;     /* 40px */
  --spacing-11: 2.75rem;    /* 44px */
  --spacing-12: 3rem;       /* 48px */
  --spacing-14: 3.5rem;     /* 56px */
  --spacing-16: 4rem;       /* 64px */
  --spacing-20: 5rem;       /* 80px */
  --spacing-24: 6rem;       /* 96px */
  --spacing-28: 7rem;       /* 112px */
  --spacing-32: 8rem;       /* 128px */
  --spacing-36: 9rem;       /* 144px */
  --spacing-40: 10rem;      /* 160px */
  --spacing-44: 11rem;      /* 176px */
  --spacing-48: 12rem;      /* 192px */
  --spacing-52: 13rem;      /* 208px */
  --spacing-56: 14rem;      /* 224px */
  --spacing-60: 15rem;      /* 240px */
  --spacing-64: 16rem;      /* 256px */
  --spacing-72: 18rem;      /* 288px */
  --spacing-80: 20rem;      /* 320px */
  --spacing-96: 24rem;      /* 384px */
}
```

## Border Radius Tokens

```css
:root {
  --radius-none: 0;
  --radius-sm: 0.125rem;    /* 2px */
  --radius-md: 0.25rem;     /* 4px */
  --radius-lg: 0.5rem;      /* 8px */
  --radius-xl: 0.75rem;     /* 12px */
  --radius-2xl: 1rem;       /* 16px */
  --radius-3xl: 1.5rem;     /* 24px */
  --radius-full: 9999px;
}
```

## Shadow Tokens

```css
:root {
  /* Light theme shadows */
  --shadow-sm: 0 1px 2px 0 rgb(0 0 0 / 0.05);
  --shadow-md: 0 4px 6px -1px rgb(0 0 0 / 0.1), 0 2px 4px -2px rgb(0 0 0 / 0.1);
  --shadow-lg: 0 10px 15px -3px rgb(0 0 0 / 0.1), 0 4px 6px -4px rgb(0 0 0 / 0.1);
  --shadow-xl: 0 20px 25px -5px rgb(0 0 0 / 0.1), 0 8px 10px -6px rgb(0 0 0 / 0.1);
  --shadow-2xl: 0 25px 50px -12px rgb(0 0 0 / 0.25);
  --shadow-inner: inset 0 2px 4px 0 rgb(0 0 0 / 0.05);
  
  /* Focus ring shadow */
  --shadow-ring: 0 0 0 2px var(--ring);
}

[data-theme="dark"] {
  /* Dark theme shadows - more subtle */
  --shadow-sm: 0 1px 2px 0 rgb(0 0 0 / 0.1);
  --shadow-md: 0 4px 6px -1px rgb(0 0 0 / 0.2), 0 2px 4px -2px rgb(0 0 0 / 0.2);
  --shadow-lg: 0 10px 15px -3px rgb(0 0 0 / 0.2), 0 4px 6px -4px rgb(0 0 0 / 0.2);
  --shadow-xl: 0 20px 25px -5px rgb(0 0 0 / 0.2), 0 8px 10px -6px rgb(0 0 0 / 0.2);
  --shadow-2xl: 0 25px 50px -12px rgb(0 0 0 / 0.4);
  --shadow-inner: inset 0 2px 4px 0 rgb(0 0 0 / 0.1);
}
```

## Animation Tokens

```css
:root {
  /* Duration */
  --duration-75: 75ms;
  --duration-100: 100ms;
  --duration-150: 150ms;
  --duration-200: 200ms;
  --duration-300: 300ms;
  --duration-500: 500ms;
  --duration-700: 700ms;
  --duration-1000: 1000ms;
  
  /* Easing */
  --ease-linear: linear;
  --ease-in: cubic-bezier(0.4, 0, 1, 1);
  --ease-out: cubic-bezier(0, 0, 0.2, 1);
  --ease-in-out: cubic-bezier(0.4, 0, 0.2, 1);
  
  /* Common transitions */
  --transition-all: all var(--duration-200) var(--ease-in-out);
  --transition-colors: background-color var(--duration-200) var(--ease-in-out), 
                      border-color var(--duration-200) var(--ease-in-out), 
                      color var(--duration-200) var(--ease-in-out), 
                      fill var(--duration-200) var(--ease-in-out), 
                      stroke var(--duration-200) var(--ease-in-out);
  --transition-opacity: opacity var(--duration-200) var(--ease-in-out);
  --transition-shadow: box-shadow var(--duration-200) var(--ease-in-out);
  --transition-transform: transform var(--duration-200) var(--ease-in-out);
}
```

## Z-Index Tokens

```css
:root {
  --z-0: 0;
  --z-10: 10;
  --z-20: 20;
  --z-30: 30;
  --z-40: 40;
  --z-50: 50;
  --z-auto: auto;
  
  /* Semantic z-index values */
  --z-dropdown: 1000;
  --z-sticky: 1020;
  --z-fixed: 1030;
  --z-modal-backdrop: 1040;
  --z-modal: 1050;
  --z-popover: 1060;
  --z-tooltip: 1070;
}
```

## Using Design Tokens

### In CSS

```css
.my-component {
  background-color: hsl(var(--background));
  color: hsl(var(--foreground));
  padding: var(--spacing-4);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-md);
  font-family: var(--font-sans);
  font-size: var(--font-size-base);
  transition: var(--transition-all);
}

.my-component:hover {
  box-shadow: var(--shadow-lg);
}
```

### In ViewComponents

```ruby
def css_classes
  [
    "bg-card",
    "text-card-foreground",
    "p-4",
    "rounded-lg",
    "shadow-md",
    "transition-all",
    @options[:class]
  ].compact.join(" ")
end
```

### In Tailwind Classes

```html
<div class="bg-card text-card-foreground p-4 rounded-lg shadow-md transition-all">
  Content
</div>
```

## Best Practices

1. **Always use tokens instead of hardcoded values**
   ```css
   /* Good */
   margin: var(--spacing-4);
   
   /* Avoid */
   margin: 16px;
   ```

2. **Use semantic tokens over base tokens when possible**
   ```css
   /* Good */
   color: hsl(var(--primary));
   
   /* Avoid */
   color: hsl(var(--blue-600));
   ```

3. **Maintain consistent spacing with spacing tokens**
   ```css
   /* Good */
   padding: var(--spacing-4) var(--spacing-6);
   
   /* Avoid */
   padding: 16px 24px;
   ```

4. **Use the shadow system for consistent elevation**
   ```css
   /* Good */
   box-shadow: var(--shadow-md);
   
   /* Avoid */
   box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
   ```

5. **Apply transitions consistently**
   ```css
   /* Good */
   transition: var(--transition-colors);
   
   /* Avoid */
   transition: background-color 0.2s ease;
   ```