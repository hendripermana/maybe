import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="ui--modal"
export default class extends Controller {
  static targets = ["overlay", "dialog"]
  static values = { 
    open: Boolean,
    backdropClosable: { type: Boolean, default: true }
  }

  connect() {
    this.boundKeyHandler = this.handleKeydown.bind(this)
    
    if (this.openValue) {
      this.show()
    }
  }

  disconnect() {
    this.hide()
  }

  show() {
    this.openValue = true
    this.overlayTarget.style.display = "flex"
    this.overlayTarget.setAttribute("data-state", "open")
    this.dialogTarget.setAttribute("data-state", "open")
    
    // Prevent body scroll
    document.body.style.overflow = "hidden"
    
    // Add keyboard event listener
    document.addEventListener("keydown", this.boundKeyHandler)
    
    // Focus the dialog
    this.dialogTarget.focus()
    
    // Dispatch custom event
    this.dispatch("opened")
  }

  hide() {
    this.openValue = false
    this.overlayTarget.setAttribute("data-state", "closed")
    this.dialogTarget.setAttribute("data-state", "closed")
    
    // Restore body scroll
    document.body.style.overflow = ""
    
    // Remove keyboard event listener
    document.removeEventListener("keydown", this.boundKeyHandler)
    
    // Hide after animation
    setTimeout(() => {
      if (!this.openValue) {
        this.overlayTarget.style.display = "none"
      }
    }, 200)
    
    // Dispatch custom event
    this.dispatch("closed")
  }

  close() {
    this.hide()
  }

  closeOnBackdrop(event) {
    if (this.backdropClosableValue && event.target === this.overlayTarget) {
      this.close()
    }
  }

  handleKeydown(event) {
    if (event.key === "Escape") {
      event.preventDefault()
      this.close()
    }
  }

  openValueChanged() {
    if (this.openValue) {
      this.show()
    } else {
      this.hide()
    }
  }
}