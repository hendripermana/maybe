import { Controller } from "@hotwired/stimulus"

// Alert controller for handling dismissible alerts
export default class extends Controller {
  dismiss() {
    // Add a fade-out animation
    this.element.classList.add("opacity-0", "transition-opacity", "duration-300")
    
    // Remove the element after animation completes
    setTimeout(() => {
      this.element.remove()
    }, 300)
  }
}