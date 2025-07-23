import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="ui--navigation"
export default class extends Controller {
  static targets = ["item"];

  connect() {
    this.addKeyboardNavigation();
  }

  addKeyboardNavigation() {
    // Add keyboard navigation for desktop navigation
    if (this.element.classList.contains("sidebar-modern")) {
      this.itemTargets.forEach((item, index) => {
        item.setAttribute("tabindex", "0");
        
        item.addEventListener("keydown", (event) => {
          // Handle arrow key navigation
          if (event.key === "ArrowDown") {
            event.preventDefault();
            const nextItem = this.itemTargets[index + 1] || this.itemTargets[0];
            nextItem.focus();
          } else if (event.key === "ArrowUp") {
            event.preventDefault();
            const prevItem = this.itemTargets[index - 1] || this.itemTargets[this.itemTargets.length - 1];
            prevItem.focus();
          } else if (event.key === "Enter" || event.key === " ") {
            event.preventDefault();
            item.click();
          }
        });
      });
    }
  }
}