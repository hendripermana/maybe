import { Controller } from "@hotwired/stimulus"

// Toggle switch controller for handling toggle switch interactions
export default class extends Controller {
  static values = {
    field: String,
    checked: String,
    unchecked: String
  }
  
  connect() {
    // Initialize hidden field if needed
    this.hiddenField = document.querySelector(`input[name="${this.fieldValue}"]`)
    
    if (!this.hiddenField) {
      console.error(`Could not find hidden field for ${this.fieldValue}`)
    }
  }
  
  toggle() {
    if (this.element.disabled) return
    
    const isChecked = this.element.getAttribute('aria-checked') === 'true'
    const newValue = isChecked ? this.uncheckedValue : this.checkedValue
    
    // Update aria-checked attribute
    this.element.setAttribute('aria-checked', !isChecked)
    
    // Update hidden field value
    if (this.hiddenField) {
      this.hiddenField.value = newValue
    }
    
    // Toggle classes
    if (isChecked) {
      this.element.classList.remove('bg-primary')
      this.element.classList.add('bg-input')
      this.element.querySelector('span:not(.sr-only)').classList.remove('translate-x-5')
      this.element.querySelector('span:not(.sr-only)').classList.add('translate-x-0')
    } else {
      this.element.classList.add('bg-primary')
      this.element.classList.remove('bg-input')
      this.element.querySelector('span:not(.sr-only)').classList.add('translate-x-5')
      this.element.querySelector('span:not(.sr-only)').classList.remove('translate-x-0')
    }
    
    // Trigger change event for auto-submit forms
    if (this.hiddenField) {
      this.hiddenField.dispatchEvent(new Event('change', { bubbles: true }))
    }
  }
}