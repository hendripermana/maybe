// app/javascript/controllers/lazy_load_controller.js
import { Controller } from "@hotwired/stimulus"

/**
 * Lazy Load Controller
 * 
 * This controller implements lazy loading for heavy components.
 * It uses the Intersection Observer API to load components only when they are about to enter the viewport.
 * 
 * Usage:
 * <div data-controller="lazy-load" 
 *      data-lazy-load-threshold-value="0.1"
 *      data-lazy-load-url-value="/path/to/component">
 *   <div data-lazy-load-target="placeholder">Loading...</div>
 *   <div data-lazy-load-target="content" class="hidden"></div>
 * </div>
 */
export default class extends Controller {
  static targets = ["placeholder", "content"]
  static values = { 
    threshold: { type: Number, default: 0.1 },
    url: String,
    loaded: { type: Boolean, default: false }
  }

  connect() {
    // Skip if already loaded or no URL provided
    if (this.loadedValue || !this.hasUrlValue) return
    
    // Create and configure the Intersection Observer
    this.observer = new IntersectionObserver(this.handleIntersection.bind(this), {
      rootMargin: '100px', // Start loading 100px before the element enters viewport
      threshold: this.thresholdValue
    })
    
    // Start observing this element
    this.observer.observe(this.element)
  }

  disconnect() {
    // Clean up the observer when the controller is disconnected
    if (this.observer) {
      this.observer.disconnect()
    }
  }

  async handleIntersection(entries) {
    const entry = entries[0]
    
    // If the element is about to enter the viewport and not already loaded
    if (entry.isIntersecting && !this.loadedValue) {
      // Stop observing once we've triggered the load
      this.observer.disconnect()
      
      try {
        // Fetch the component content
        const response = await fetch(this.urlValue)
        
        if (!response.ok) {
          throw new Error(`Failed to load component: ${response.status}`)
        }
        
        // Get the HTML content
        const html = await response.text()
        
        // Update the content target with the loaded HTML
        this.contentTarget.innerHTML = html
        
        // Show the content and hide the placeholder
        this.contentTarget.classList.remove('hidden')
        
        if (this.hasPlaceholderTarget) {
          this.placeholderTarget.classList.add('hidden')
        }
        
        // Mark as loaded
        this.loadedValue = true
        
        // Dispatch a custom event that can be used by other controllers
        this.dispatch('loaded', { detail: { url: this.urlValue } })
        
        // Initialize any Stimulus controllers in the loaded content
        this.application.controllers.forEach(controller => {
          if (controller.context.scope.element.contains(this.contentTarget)) {
            controller.connect()
          }
        })
      } catch (error) {
        console.error('Error lazy loading component:', error)
        
        // Show error in the content area
        if (this.hasContentTarget) {
          this.contentTarget.innerHTML = `<div class="text-red-600">Failed to load component</div>`
          this.contentTarget.classList.remove('hidden')
        }
        
        if (this.hasPlaceholderTarget) {
          this.placeholderTarget.classList.add('hidden')
        }
      }
    }
  }
}