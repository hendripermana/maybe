import { Controller } from "@hotwired/stimulus"

/**
 * Character Counter Controller
 * 
 * Counts characters in a text input or textarea and updates a counter display
 */
export default class extends Controller {
  static targets = ["input", "counter", "current"]

  connect() {
    this.updateCounter()
    this.inputTarget.addEventListener("input", this.updateCounter.bind(this))
  }
  
  disconnect() {
    this.inputTarget.removeEventListener("input", this.updateCounter.bind(this))
  }

  updateCounter() {
    const currentLength = this.inputTarget.value.length
    const maxLength = this.inputTarget.getAttribute("maxlength")
    
    if (this.hasCurrentTarget) {
      this.currentTarget.textContent = currentLength
      
      // Add visual feedback when approaching the limit
      if (maxLength) {
        const remaining = parseInt(maxLength) - currentLength
        
        if (remaining <= 10) {
          this.counterTarget.classList.add("text-warning")
        } else {
          this.counterTarget.classList.remove("text-warning")
        }
        
        if (remaining <= 0) {
          this.counterTarget.classList.add("text-destructive")
          this.counterTarget.classList.remove("text-warning")
        } else {
          this.counterTarget.classList.remove("text-destructive")
        }
      }
    } else if (this.hasCounterTarget) {
      this.counterTarget.textContent = `${currentLength}${maxLength ? '/' + maxLength : ''}`
    }
  }
}