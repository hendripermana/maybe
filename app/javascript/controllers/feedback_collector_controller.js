import { Controller } from "@hotwired/stimulus";

// Collects user feedback about UI/UX
export default class extends Controller {
  static targets = [
    "form",
    "type",
    "message",
    "page",
    "theme",
    "submitButton",
    "successMessage",
    "errorMessage",
  ];

  connect() {
    // Set default values
    if (this.hasPageTarget) {
      this.pageTarget.value = window.location.pathname;
    }

    if (this.hasThemeTarget) {
      this.themeTarget.value =
        document.documentElement.dataset.theme || "light";
    }
  }

  async submitFeedback(event) {
    event.preventDefault();

    // Disable submit button to prevent double submission
    if (this.hasSubmitButtonTarget) {
      this.submitButtonTarget.disabled = true;
      this.submitButtonTarget.classList.add("opacity-50");
    }

    // Hide any previous messages
    if (this.hasSuccessMessageTarget) {
      this.successMessageTarget.classList.add("hidden");
    }

    if (this.hasErrorMessageTarget) {
      this.errorMessageTarget.classList.add("hidden");
    }

    try {
      // Get form data
      const formData = new FormData(this.formTarget);

      // Get CSRF token
      const token = document.querySelector('meta[name="csrf-token"]')?.content;

      // Submit feedback
      const response = await fetch("/monitoring/user_feedback", {
        method: "POST",
        headers: {
          "X-CSRF-Token": token,
          Accept: "application/json",
        },
        body: formData,
      });

      const result = await response.json();

      if (result.success) {
        // Show success message
        if (this.hasSuccessMessageTarget) {
          this.successMessageTarget.textContent = result.message;
          this.successMessageTarget.classList.remove("hidden");
        }

        // Reset form
        this.formTarget.reset();
      } else {
        // Show error message
        if (this.hasErrorMessageTarget) {
          this.errorMessageTarget.textContent =
            result.errors?.join(", ") || "Failed to submit feedback";
          this.errorMessageTarget.classList.remove("hidden");
        }
      }
    } catch (error) {
      console.error("Error submitting feedback:", error);

      // Show error message
      if (this.hasErrorMessageTarget) {
        this.errorMessageTarget.textContent =
          "An error occurred while submitting your feedback";
        this.errorMessageTarget.classList.remove("hidden");
      }
    } finally {
      // Re-enable submit button
      if (this.hasSubmitButtonTarget) {
        this.submitButtonTarget.disabled = false;
        this.submitButtonTarget.classList.remove("opacity-50");
      }
    }
  }
}
