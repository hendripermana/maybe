import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "form", "type", "message", "page", "theme", "browser", "submitButton", "successMessage", "errorMessage"]
  
  connect() {
    // Set current page URL
    this.pageTarget.value = window.location.href
    
    // Set browser info
    if (this.hasBrowserTarget) {
      this.browserTarget.value = navigator.userAgent
    }
    
    // Close form when clicking outside
    document.addEventListener('click', this.handleOutsideClick)
  }
  
  disconnect() {
    document.removeEventListener('click', this.handleOutsideClick)
  }
  
  handleOutsideClick = (event) => {
    if (this.panelTarget.classList.contains("open") && 
        !this.element.contains(event.target)) {
      this.closeForm()
    }
  }
  
  toggleForm(event) {
    event.preventDefault()
    this.panelTarget.classList.toggle("open")
  }
  
  closeForm() {
    this.panelTarget.classList.remove("open")
    this.resetForm()
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
        // Close the form after a delay
        setTimeout(() => this.closeForm(), 3000)
      } else {
        const data = await response.json()
        this.showError(data.error || "There was a problem submitting your feedback")
      }
    } catch (error) {
      this.showError("An unexpected error occurred")
      console.error("Feedback submission error:", error)
    } finally {
      // Re-enable submit button
      this.submitButtonTarget.disabled = false
      this.submitButtonTarget.classList.remove("opacity-50")
    }
  }
  
  validateForm() {
    if (!this.typeTarget.value) {
      this.showError("Please select a feedback type")
      return false
    }
    
    if (!this.messageTarget.value.trim()) {
      this.showError("Please enter your feedback")
      return false
    }
    
    return true
  }
  
  showSuccess(message) {
    this.successMessageTarget.textContent = message
    this.successMessageTarget.classList.remove("hidden")
  }
  
  showError(message) {
    this.errorMessageTarget.textContent = message
    this.errorMessageTarget.classList.remove("hidden")
  }
}