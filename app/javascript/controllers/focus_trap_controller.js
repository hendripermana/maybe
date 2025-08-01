import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="focus-trap"
export default class extends Controller {
  static values = {
    autoFocus: { type: Boolean, default: true },
  };

  connect() {
    this.focusableElements = this.getFocusableElements();
    this.firstFocusableElement = this.focusableElements[0];
    this.lastFocusableElement =
      this.focusableElements[this.focusableElements.length - 1];

    // Store the element that had focus before opening the modal
    this.previouslyFocusedElement = document.activeElement;

    // Set up event listeners
    document.addEventListener("keydown", this.handleKeyDown);

    // Auto-focus the first element if enabled
    if (this.autoFocusValue && this.firstFocusableElement) {
      setTimeout(() => {
        this.firstFocusableElement.focus();
      }, 100);
    }
  }

  disconnect() {
    // Remove event listeners
    document.removeEventListener("keydown", this.handleKeyDown);

    // Return focus to the element that had focus before the modal was opened
    if (this.previouslyFocusedElement) {
      this.previouslyFocusedElement.focus();
    }
  }

  handleKeyDown = (event) => {
    // Only handle tab key
    if (event.key !== "Tab") return;

    // If there are no focusable elements, do nothing
    if (this.focusableElements.length === 0) return;

    // Handle shift+tab to move focus backwards
    if (event.shiftKey) {
      if (document.activeElement === this.firstFocusableElement) {
        event.preventDefault();
        this.lastFocusableElement.focus();
      }
    }
    // Handle tab to move focus forwards
    else {
      if (document.activeElement === this.lastFocusableElement) {
        event.preventDefault();
        this.firstFocusableElement.focus();
      }
    }
  };

  getFocusableElements() {
    // Get all focusable elements within the modal
    return Array.from(
      this.element.querySelectorAll(
        'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])',
      ),
    ).filter((el) => !el.disabled && el.offsetParent !== null);
  }
}
