import { Controller } from "@hotwired/stimulus";

/**
 * Toggle Switch Controller
 *
 * Controls the behavior of toggle switches in forms
 */
export default class extends Controller {
  static values = {
    field: String,
    checked: String,
    unchecked: String,
  };

  connect() {
    // Initialize the toggle state based on the hidden input value
    this.updateAriaChecked();
  }

  toggle() {
    if (this.element.disabled) return;

    // Find the hidden input field
    const inputName = this.fieldValue;
    const input = document.querySelector(`input[name="${inputName}"]`);

    if (!input) return;

    // Toggle the value
    const isChecked = input.value === this.checkedValue;
    input.value = isChecked ? this.uncheckedValue : this.checkedValue;

    // Update the visual state
    this.element.setAttribute("aria-checked", !isChecked);

    // Dispatch change event for auto-submit forms
    input.dispatchEvent(new Event("change", { bubbles: true }));

    // Add visual feedback animation
    this.addFeedbackAnimation();
  }

  updateAriaChecked() {
    const inputName = this.fieldValue;
    const input = document.querySelector(`input[name="${inputName}"]`);

    if (input) {
      const isChecked = input.value === this.checkedValue;
      this.element.setAttribute("aria-checked", isChecked);
    }
  }

  addFeedbackAnimation() {
    // Add a subtle pulse animation for visual feedback
    this.element.classList.add("toggle-animation");

    // Remove the animation class after animation completes
    setTimeout(() => {
      this.element.classList.remove("toggle-animation");
    }, 300);
  }
}
