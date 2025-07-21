import { Controller } from "@hotwired/stimulus";

/**
 * Theme Preferences Controller
 * Handles theme preference selection and preview functionality
 */
export default class extends Controller {
  static targets = ["option", "preview", "form"];
  static values = { 
    currentTheme: String,
    previewDelay: { type: Number, default: 500 }
  };

  connect() {
    this.setupEventListeners();
    this.highlightSelectedOption();
  }

  setupEventListeners() {
    // Listen for theme changes from the main theme controller
    document.addEventListener("theme:changed", this.handleThemeChange.bind(this));
    
    // Setup preview hover behavior if preview targets exist
    if (this.hasPreviewTarget) {
      this.optionTargets.forEach(option => {
        option.addEventListener("mouseenter", this.handleOptionHover.bind(this));
        option.addEventListener("mouseleave", this.handleOptionLeave.bind(this));
      });
    }
  }

  // When a theme option is selected
  selectOption(event) {
    const selectedValue = event.currentTarget.querySelector("input").value;
    this.currentThemeValue = selectedValue;
    this.highlightSelectedOption();
    
    // If form auto-submit is not enabled, we need to dispatch an event
    if (!this.hasFormTarget || !this.formTarget.hasAttribute("data-controller")) {
      this.dispatchThemeChangeEvent(selectedValue);
    }
  }

  // When hovering over a theme option, show a preview
  handleOptionHover(event) {
    if (this.previewTimeout) {
      clearTimeout(this.previewTimeout);
    }
    
    const hoverValue = event.currentTarget.querySelector("input").value;
    
    // Add a small delay before showing preview to prevent flickering
    this.previewTimeout = setTimeout(() => {
      this.showThemePreview(hoverValue);
    }, this.previewDelayValue);
  }

  // When leaving a theme option, restore the selected theme
  handleOptionLeave() {
    if (this.previewTimeout) {
      clearTimeout(this.previewTimeout);
    }
    
    // Add a small delay before restoring to prevent flickering
    this.previewTimeout = setTimeout(() => {
      this.showThemePreview(this.currentThemeValue);
    }, this.previewDelayValue / 2);
  }

  // Show theme preview for a specific theme
  showThemePreview(theme) {
    if (!this.hasPreviewTarget) return;
    
    this.previewTarget.setAttribute("data-theme", theme);
    
    // If theme is "system", use the system preference
    if (theme === "system") {
      const systemTheme = window.matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light";
      this.previewTarget.setAttribute("data-system-theme", systemTheme);
    } else {
      this.previewTarget.removeAttribute("data-system-theme");
    }
  }

  // Handle theme change event from the main theme controller
  handleThemeChange(event) {
    const { theme, preference } = event.detail;
    
    if (preference && preference !== this.currentThemeValue) {
      this.currentThemeValue = preference;
      this.highlightSelectedOption();
    }
    
    // Update preview if it exists
    if (this.hasPreviewTarget) {
      this.showThemePreview(preference || "system");
    }
  }

  // Highlight the currently selected option
  highlightSelectedOption() {
    if (!this.hasOptionTarget) return;
    
    this.optionTargets.forEach(option => {
      const input = option.querySelector("input");
      const isSelected = input && input.value === this.currentThemeValue;
      
      option.classList.toggle("selected", isSelected);
      if (input) {
        input.checked = isSelected;
      }
    });
  }

  // Dispatch theme change event
  dispatchThemeChangeEvent(preference) {
    const event = new CustomEvent("theme:preferenceChanged", {
      detail: { preference },
      bubbles: true
    });
    this.element.dispatchEvent(event);
  }
}