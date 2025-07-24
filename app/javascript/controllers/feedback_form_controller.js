import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "form", "type", "message", "page", "theme", "browser", "submitButton", "successMessage", "errorMessage", "toggleButton"]
  
  connect() {
    // Set current page URL
    this.pageTarget.value = window.location.href
    
    // Set browser info
    if (this.hasBrowserTarget) {
      this.browserTarget.value = navigator.userAgent
    }
    
    // Close form when clicking outside
    document.addEventListener('click', this.handleOutsideClick)
    
    // Handle keyboard events
    document.addEventListener('keydown', this.handleKeyDown)
  }
  
  disconnect() {
    document.removeEventListener('click', this.handleOutsideClick)
    document.removeEventListener('keydown', this.handleKeyDown)
  }
  
  handleOutsideClick = (event) => {
    if (!this.panelTarget.classList.contains("hidden") && 
        !this.element.contains(event.target)) {
      this.closeForm()
    }
  }
  
  handleKeyDown = (event) => {
    // Close on escape key
    if (event.key === 'Escape' && !this.panelTarget.classList.contains("hidden")) {
      this.closeForm()
      event.preventDefault()
    }
    
    // Trap focus within the form when it's open
    if (event.key === 'Tab' && !this.panelTarget.classList.contains("hidden")) {
      this.trapFocus(event)
    }
  }
  
  trapFocus(event) {
    // Get all focusable elements in the form
    const focusableElements = this.panelTarget.querySelectorAll(
      'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
    )
    
    const firstElement = focusableElements[0]
    const lastElement = focusableElements[focusableElements.length - 1]
    
    // If shift+tab on first element, move to last element
    if (event.shiftKey && document.activeElement === firstElement) {
      lastElement.focus()
      event.preventDefault()
    }
    // If tab on last element, move to first element
    else if (!event.shiftKey && document.activeElement === lastElement) {
      firstElement.focus()
      event.preventDefault()
    }
  }
  
  toggleForm(event) {
    event.preventDefault()
    const isHidden = this.panelTarget.classList.contains("hidden")
    
    if (isHidden) {
      this.openForm()
    } else {
      this.closeForm()
    }
  }
  
  openForm() {
    this.panelTarget.classList.remove("hidden")
    this.toggleButtonTarget.setAttribute("aria-expanded", "true")
    
    // Focus the first form element after opening
    setTimeout(() => {
      this.typeTarget.focus()
    }, 100)
  }
  
  closeForm() {
    this.panelTarget.classList.add("hidden")
    this.toggleButtonTarget.setAttribute("aria-expanded", "false")
    this.resetForm()
    
    // Return focus to the toggle button
    this.toggleButtonTarget.focus()
  }
  
  resetForm() {
    this.formTarget.reset()
    this.hideMessages()
  }
  
  hideMessages() {
    this.successMessageTarget.classList.add("hidden")
    this.errorMessageTarget.classList.add("hidden")
  }
  
  async submitFeedback(event) {
    event.preventDefault()
    this.hideMessages()
    
    // Disable submit button to prevent multiple submissions
    this.submitButtonTarget.disabled = true
    this.submitButtonTarget.classList.add("opacity-50")
    
    try {
      // Validate form
      if (!this.validateForm()) {
        return
      }
      
      const formData = new FormData(this.formTarget)
      
      const response = await fetch('/user_feedbacks', {
        method: 'POST',
        headers: {
          'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content,
          'Accept': 'application/json'
        },
        body: formData
      })
      
      if (response.ok) {
        this.showSuccess("Thank you for your feedback!")
        this.resetForm()
        // Focus on success message for screen readers
        this.successMessageTarget.focus()
        // Close the form after a delay
        setTimeout(() => this.closeForm(), 3000)
      } else {
        const data = await response.json()
        this.showError(data.error || "There was a problem submitting your feedback")
        // Focus on error message for screen readers
        this.errorMessageTarget.focus()
      }
    } catch (error) {
      this.showError("An unexpected error occurred")
      console.error("Feedback submission error:", error)
      // Focus on error message for screen readers
      this.errorMessageTarget.focus()
    } finally {
      // Re-enable submit button
      this.submitButtonTarget.disabled = false
      this.submitButtonTarget.classList.remove("opacity-50")
    }
  }
  
  validateForm() {
    if (!this.typeTarget.value) {
      this.showError("Please select a feedback type")
      this.typeTarget.focus()
      return false
    }
    
    if (!this.messageTarget.value.trim()) {
      this.showError("Please enter your feedback")
      this.messageTarget.focus()
      return false
    }
    
    return true
  }
  
  showSuccess(message) {
    this.successMessageTarget.textContent = message
    this.successMessageTarget.classList.remove("hidden")
    // Make sure screen readers announce the message
    this.successMessageTarget.setAttribute("tabindex", "-1")
  }
  
  showError(message) {
    this.errorMessageTarget.textContent = message
    this.errorMessageTarget.classList.remove("hidden")
    // Make sure screen readers announce the message
    this.errorMessageTarget.setAttribute("tabindex", "-1")
  }
}