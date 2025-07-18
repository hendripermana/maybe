import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="transaction-form"
export default class extends Controller {
  static targets = ["categorySelect", "advancedFields", "chevron"]

  connect() {
    // Initialize any form state if needed
  }

  changeType(event) {
    const type = event.currentTarget.dataset.type
    
    // Update the hidden field
    const natureField = this.element.querySelector('input[name="entry[nature]"]')
    if (natureField) {
      natureField.value = type
    }
    
    // Update the active tab styling
    const tabs = this.element.querySelectorAll('button[data-type]')
    tabs.forEach(tab => {
      if (tab.dataset.type === type) {
        tab.classList.add('border-primary', 'text-primary')
        tab.classList.remove('border-transparent', 'text-muted-foreground', 'hover:text-foreground')
      } else {
        tab.classList.remove('border-primary', 'text-primary')
        tab.classList.add('border-transparent', 'text-muted-foreground', 'hover:text-foreground')
      }
    })
    
    // Fetch the appropriate categories based on the type
    this.fetchCategories(type)
  }
  
  fetchCategories(type) {
    // In a real implementation, this would fetch categories via AJAX
    // For now, we'll just simulate the behavior
    
    const isIncome = type === 'inflow'
    const url = `/categories?type=${isIncome ? 'income' : 'expense'}`
    
    fetch(url)
      .then(response => response.json())
      .then(categories => {
        if (this.hasCategorySelectTarget) {
          // Clear existing options except the first one
          while (this.categorySelectTarget.options.length > 1) {
            this.categorySelectTarget.remove(1)
          }
          
          // Add new options
          categories.forEach(category => {
            const option = document.createElement('option')
            option.value = category.id
            option.textContent = category.name
            this.categorySelectTarget.appendChild(option)
          })
        }
      })
      .catch(error => {
        console.error('Error fetching categories:', error)
      })
  }
  
  toggleAdvanced() {
    if (this.hasAdvancedFieldsTarget) {
      this.advancedFieldsTarget.classList.toggle('hidden')
      
      if (this.hasChevronTarget) {
        // Rotate the chevron icon
        this.chevronTarget.classList.toggle('rotate-180')
      }
    }
  }
}