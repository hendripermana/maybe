import { Controller } from "@hotwired/stimulus";

// Handles touch interactions for budget forms
export default class extends Controller {
  static targets = ["input"];

  connect() {
    // Add touch-specific event listeners
    this.addTouchListeners();

    // Check if we're on a touch device
    this.isTouchDevice =
      "ontouchstart" in window || navigator.maxTouchPoints > 0;

    if (this.isTouchDevice) {
      this.element.classList.add("touch-device");
    }
  }

  disconnect() {
    // Clean up event listeners
    this.removeTouchListeners();
  }

  addTouchListeners() {
    if (this.hasInputTarget) {
      this.inputTargets.forEach((input) => {
        input.addEventListener("touchstart", this.handleTouchStart.bind(this));
        input.addEventListener("touchend", this.handleTouchEnd.bind(this));
      });
    }
  }

  removeTouchListeners() {
    if (this.hasInputTarget) {
      this.inputTargets.forEach((input) => {
        input.removeEventListener(
          "touchstart",
          this.handleTouchStart.bind(this),
        );
        input.removeEventListener("touchend", this.handleTouchEnd.bind(this));
      });
    }
  }

  handleTouchStart(event) {
    // Prevent the default behavior to avoid double tap zoom on iOS
    event.preventDefault();

    // Focus the input
    event.target.focus();

    // Add active state class
    event.target.classList.add("touch-active");
  }

  handleTouchEnd(event) {
    // Remove active state class
    event.target.classList.remove("touch-active");
  }

  // Helper method to preserve focus when auto-submitting forms
  preserveFocus(event) {
    // Store the current focused element
    this.lastFocusedElement = document.activeElement;
  }

  // Restore focus after form submission
  restoreFocus() {
    if (this.lastFocusedElement) {
      this.lastFocusedElement.focus();
    }
  }
}
