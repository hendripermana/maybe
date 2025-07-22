// app/javascript/controllers/optimized_render_controller.js
import { Controller } from "@hotwired/stimulus"

/**
 * Optimized Render Controller
 * 
 * This controller implements performance optimizations for component rendering:
 * 1. Debounced updates to prevent excessive re-renders
 * 2. Request animation frame for smooth animations
 * 3. Virtualized rendering for large lists
 * 4. Throttled event handlers
 * 
 * Usage:
 * <div data-controller="optimized-render" 
 *      data-optimized-render-debounce-value="200"
 *      data-optimized-render-virtualize-value="true"
 *      data-optimized-render-item-height-value="50">
 *   <div data-optimized-render-target="container">
 *     <!-- Items will be rendered here -->
 *   </div>
 * </div>
 */
export default class extends Controller {
  static targets = ["container", "item"]
  static values = { 
    debounce: { type: Number, default: 200 },
    throttle: { type: Number, default: 100 },
    virtualize: { type: Boolean, default: false },
    itemHeight: { type: Number, default: 50 },
    items: Array
  }

  connect() {
    // Initialize debounce and throttle timers
    this.debounceTimer = null
    this.throttleTimer = null
    this.lastThrottleTime = 0
    
    // Set up scroll handler if virtualizing
    if (this.virtualizeValue) {
      this.setupVirtualScroll()
    }
    
    // Initial render using requestAnimationFrame for optimal timing
    requestAnimationFrame(() => this.render())
  }

  // Debounced render method - waits until user input has stopped
  debouncedRender() {
    clearTimeout(this.debounceTimer)
    this.debounceTimer = setTimeout(() => {
      requestAnimationFrame(() => this.render())
    }, this.debounceValue)
  }

  // Throttled event handler - limits how often an event can fire
  throttledHandler(callback) {
    const now = Date.now()
    
    if (now - this.lastThrottleTime >= this.throttleValue) {
      this.lastThrottleTime = now
      callback()
    } else if (!this.throttleTimer) {
      this.throttleTimer = setTimeout(() => {
        this.throttleTimer = null
        this.lastThrottleTime = Date.now()
        callback()
      }, this.throttleValue - (now - this.lastThrottleTime))
    }
  }

  // Setup virtual scrolling for large lists
  setupVirtualScroll() {
    // Get the container element that will be scrolled
    const container = this.containerTarget
    
    // Set a fixed height on the container to enable scrolling
    container.style.height = '400px' // Can be customized via data attribute
    container.style.overflowY = 'auto'
    container.style.position = 'relative'
    
    // Create a spacer element to maintain scroll height
    this.spacerElement = document.createElement('div')
    this.spacerElement.style.height = '0px'
    this.spacerElement.style.width = '100%'
    container.appendChild(this.spacerElement)
    
    // Add scroll event listener with throttling
    container.addEventListener('scroll', () => {
      this.throttledHandler(() => this.handleScroll())
    })
  }

  // Handle scroll events for virtual list
  handleScroll() {
    if (!this.virtualizeValue || !this.hasItemsValue) return
    
    requestAnimationFrame(() => {
      const container = this.containerTarget
      const scrollTop = container.scrollTop
      const containerHeight = container.clientHeight
      
      // Calculate which items should be visible
      const startIndex = Math.floor(scrollTop / this.itemHeightValue)
      const endIndex = Math.min(
        startIndex + Math.ceil(containerHeight / this.itemHeightValue) + 1,
        this.itemsValue.length
      )
      
      // Update the DOM with only the visible items
      this.renderVisibleItems(startIndex, endIndex)
    })
  }

  // Render only the visible items in a virtualized list
  renderVisibleItems(startIndex, endIndex) {
    // Clear existing items
    const container = this.containerTarget
    const existingItems = container.querySelectorAll('[data-optimized-render-target="item"]')
    existingItems.forEach(item => item.remove())
    
    // Update spacer height to maintain scroll position
    this.spacerElement.style.height = `${startIndex * this.itemHeightValue}px`
    
    // Render only the visible items
    const fragment = document.createDocumentFragment()
    
    for (let i = startIndex; i < endIndex; i++) {
      const item = this.itemsValue[i]
      const element = document.createElement('div')
      element.dataset.optimizedRenderTarget = 'item'
      element.style.height = `${this.itemHeightValue}px`
      element.textContent = item.text || `Item ${i}`
      fragment.appendChild(element)
    }
    
    // Append all items at once for better performance
    container.insertBefore(fragment, this.spacerElement)
    
    // Add a bottom spacer for remaining items
    const bottomSpacerHeight = (this.itemsValue.length - endIndex) * this.itemHeightValue
    const bottomSpacer = document.createElement('div')
    bottomSpacer.style.height = `${bottomSpacerHeight}px`
    bottomSpacer.style.width = '100%'
    container.appendChild(bottomSpacer)
  }

  // Main render method
  render() {
    if (this.virtualizeValue && this.hasItemsValue) {
      // For virtualized lists, render only visible items
      this.handleScroll()
    } else {
      // For normal rendering, update the entire container
      // This would be customized based on your specific component needs
      console.log('Rendering component with optimized performance')
    }
  }
}