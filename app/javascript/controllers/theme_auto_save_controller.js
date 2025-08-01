import { Controller } from "@hotwired/stimulus";

/**
 * Theme Auto Save Controller
 * Automatically saves theme preferences when changed via toggle or other controls
 */
export default class extends Controller {
  static targets = ["themeInput", "form"];
  static values = {
    url: String,
    csrfToken: String,
  };

  connect() {
    // Listen for theme preference changes
    document.addEventListener(
      "theme:preferenceChanged",
      this.handlePreferenceChange.bind(this),
    );
  }

  disconnect() {
    document.removeEventListener(
      "theme:preferenceChanged",
      this.handlePreferenceChange.bind(this),
    );
  }

  // Handle theme preference change event
  handlePreferenceChange(event) {
    const { preference } = event.detail;

    if (this.hasThemeInputTarget) {
      // Update the input value
      this.themeInputTarget.value = preference;

      // Submit the form if it exists
      if (this.hasFormTarget) {
        this.formTarget.requestSubmit();
      } else {
        // Otherwise, make an AJAX request
        this.savePreference(preference);
      }
    } else {
      // If no input target, just make an AJAX request
      this.savePreference(preference);
    }
  }

  // Save preference via AJAX
  savePreference(preference) {
    if (!this.hasUrlValue) return;

    fetch(this.urlValue, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token":
          this.csrfTokenValue ||
          document.querySelector("meta[name='csrf-token']")?.content,
      },
      body: JSON.stringify({ theme: preference }),
    })
      .then((response) => {
        if (!response.ok) {
          throw new Error("Failed to save theme preference");
        }
        return response.json();
      })
      .catch((error) => {
        console.error("Error saving theme preference:", error);
      });
  }
}
