import { Controller } from "@hotwired/stimulus";

// Responsive transaction controller for handling touch interactions and responsive behavior
export default class extends Controller {
  static targets = ["container", "checkbox", "details", "categorySelect"];

  connect() {
    // Add touch event listeners for mobile devices
    if ("ontouchstart" in window) {
      this.addTouchInteractions();
    }

    // Check for viewport size changes
    this.checkViewportSize();
    window.addEventListener("resize", this.checkViewportSize.bind(this));
  }

  disconnect() {
    // Clean up event listeners
    window.removeEventListener("resize", this.checkViewportSize.bind(this));
  }

  // Add touch-specific interactions for mobile devices
  addTouchInteractions() {
    if (this.hasContainerTarget) {
      // Track touch start position for swipe detection
      this.containerTarget.addEventListener(
        "touchstart",
        (event) => {
          this.touchStartX = event.touches[0].clientX;
          this.touchStartY = event.touches[0].clientY;
        },
        { passive: true },
      );

      // Handle touch move for swipe gestures
      this.containerTarget.addEventListener("touchmove", (event) => {
        if (!this.touchStartX || !this.touchStartY) return;

        const touchEndX = event.touches[0].clientX;
        const touchEndY = event.touches[0].clientY;

        const xDiff = this.touchStartX - touchEndX;
        const yDiff = this.touchStartY - touchEndY;

        // Horizontal swipe detection (for potential swipe actions)
        if (Math.abs(xDiff) > Math.abs(yDiff) && Math.abs(xDiff) > 50) {
          // Prevent default only if we're handling the swipe
          event.preventDefault();

          if (xDiff > 0) {
            // Swipe left - could show action buttons
            this.handleSwipeLeft();
          } else {
            // Swipe right - could show different action
            this.handleSwipeRight();
          }

          // Reset touch start position
          this.touchStartX = null;
          this.touchStartY = null;
        }
      });

      // Handle touch end to reset tracking
      this.containerTarget.addEventListener(
        "touchend",
        () => {
          this.touchStartX = null;
          this.touchStartY = null;
        },
        { passive: true },
      );
    }
  }

  // Handle swipe left gesture (e.g., reveal delete/edit actions)
  handleSwipeLeft() {
    // Implementation for swipe left action
    // Could reveal action buttons on mobile
    console.log("Swipe left detected");
  }

  // Handle swipe right gesture (e.g., mark as read/done)
  handleSwipeRight() {
    // Implementation for swipe right action
    console.log("Swipe right detected");
  }

  // Check viewport size and adjust UI accordingly
  checkViewportSize() {
    const isMobile = window.innerWidth < 640;
    const isTablet = window.innerWidth >= 640 && window.innerWidth < 1024;

    // Add appropriate classes based on viewport
    if (this.hasContainerTarget) {
      this.containerTarget.classList.toggle("is-mobile", isMobile);
      this.containerTarget.classList.toggle("is-tablet", isTablet);
    }

    // Adjust touch target sizes for mobile
    if (this.hasCheckboxTarget) {
      if (isMobile) {
        this.checkboxTarget.classList.add("w-6", "h-6");
        this.checkboxTarget.classList.remove("w-4", "h-4");
      } else {
        this.checkboxTarget.classList.remove("w-6", "h-6");
        this.checkboxTarget.classList.add("w-4", "h-4");
      }
    }
  }

  // Toggle transaction details on mobile (tap to expand)
  toggleDetails(event) {
    // Only handle on mobile
    if (window.innerWidth >= 640) return;

    // Don't toggle if clicking on interactive elements
    if (event.target.closest("a, button, input, select")) return;

    if (this.hasDetailsTarget) {
      this.detailsTarget.classList.toggle("hidden");
    }
  }

  // Handle long press for selection on mobile
  handleLongPress(event) {
    // Only handle on mobile
    if (window.innerWidth >= 640) return;

    // Toggle checkbox on long press
    if (this.hasCheckboxTarget) {
      this.checkboxTarget.checked = !this.checkboxTarget.checked;

      // Dispatch change event to trigger any listeners
      this.checkboxTarget.dispatchEvent(new Event("change", { bubbles: true }));
    }
  }
}
