import { Controller } from "@hotwired/stimulus";

/**
 * Theme Controller
 * Handles theme switching and system preference detection
 */
export default class extends Controller {
  static values = { userPreference: String };
  static targets = ["toggle", "lightLabel", "darkLabel"];

  connect() {
    this.startSystemThemeListener();
    this.applyTheme();
    this.addTransitionClass();
  }

  disconnect() {
    this.stopSystemThemeListener();
  }

  // Called automatically by Stimulus when the userPreferenceValue changes (e.g., after form submit/page reload)
  userPreferenceValueChanged() {
    this.applyTheme();
  }

  // Called when a theme radio button is clicked
  updateTheme(event) {
    const selectedTheme = event.currentTarget.value;
    this.applyThemePreference(selectedTheme);
  }

  // Applies theme based on the userPreferenceValue (from server)
  applyTheme() {
    this.applyThemePreference(this.userPreferenceValue || "system");
  }

  // Apply theme preference with smooth transition
  applyThemePreference(preference) {
    let isDark;
    
    switch (preference) {
      case "dark":
        isDark = true;
        break;
      case "light":
        isDark = false;
        break;
      case "system":
      default:
        isDark = this.systemPrefersDark();
        break;
    }
    
    this.setTheme(isDark);
    this.updateToggleState(isDark);
    this.dispatchThemeChangeEvent(isDark, preference);
  }

  // Sets the data-theme attribute with smooth transition
  setTheme(isDark) {
    const root = document.documentElement;
    const newTheme = isDark ? "dark" : "light";
    const currentTheme = root.getAttribute("data-theme");
    
    // Only update if theme actually changed
    if (currentTheme !== newTheme) {
      // Add transition class for smooth theme switching
      root.classList.add("theme-transitioning");
      
      // Set the new theme
      root.setAttribute("data-theme", newTheme);
      
      // Remove transition class after animation completes
      setTimeout(() => {
        root.classList.remove("theme-transitioning");
      }, 300);
    }
  }

  // Update toggle button state if present
  updateToggleState(isDark) {
    if (this.hasToggleTarget) {
      this.toggleTarget.setAttribute("aria-pressed", isDark.toString());
      this.toggleTarget.setAttribute("data-theme-state", isDark ? "dark" : "light");
    }
  }

  // Dispatch custom event for other components to listen to
  dispatchThemeChangeEvent(isDark, preference) {
    const event = new CustomEvent("theme:changed", {
      detail: {
        theme: isDark ? "dark" : "light",
        preference: preference,
        isDark: isDark
      },
      bubbles: true
    });
    document.dispatchEvent(event);
  }

  systemPrefersDark() {
    return window.matchMedia("(prefers-color-scheme: dark)").matches;
  }

  handleSystemThemeChange = (event) => {
    // Only apply system theme changes if the user preference is currently 'system'
    if (this.userPreferenceValue === "system") {
      this.setTheme(event.matches);
      this.updateToggleState(event.matches);
      this.dispatchThemeChangeEvent(event.matches, "system");
    }
  };

  // Toggle between light and dark themes
  toggle() {
    const currentTheme = document.documentElement.getAttribute("data-theme");
    const newIsDark = currentTheme !== "dark";
    const newPreference = newIsDark ? "dark" : "light";
    
    this.applyThemePreference(newPreference);
    
    // If this is a manual toggle, we should update the user preference
    // This would typically trigger a form submission or AJAX request
    this.updateUserPreference(newPreference);
  }

  // Add CSS transition class for smooth theme switching
  addTransitionClass() {
    const style = document.createElement("style");
    style.textContent = `
      .theme-transitioning,
      .theme-transitioning * {
        transition: background-color 0.3s ease, 
                   color 0.3s ease, 
                   border-color 0.3s ease, 
                   box-shadow 0.3s ease !important;
      }
    `;
    document.head.appendChild(style);
  }

  // Update user preference (would typically make an API call)
  updateUserPreference(preference) {
    // Dispatch event that other controllers can listen to for saving preference
    const event = new CustomEvent("theme:preferenceChanged", {
      detail: { preference },
      bubbles: true
    });
    document.dispatchEvent(event);
  }

  startSystemThemeListener() {
    this.darkMediaQuery = window.matchMedia("(prefers-color-scheme: dark)");
    this.darkMediaQuery.addEventListener(
      "change",
      this.handleSystemThemeChange,
    );
  }

  stopSystemThemeListener() {
    if (this.darkMediaQuery) {
      this.darkMediaQuery.removeEventListener(
        "change",
        this.handleSystemThemeChange,
      );
    }
  }
}