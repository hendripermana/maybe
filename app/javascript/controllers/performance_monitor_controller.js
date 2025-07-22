// app/javascript/controllers/performance_monitor_controller.js
import { Controller } from "@hotwired/stimulus"
import { performanceMonitor } from "../services/performance_monitor"

/**
 * Performance Monitor Controller
 * 
 * This controller integrates with the PerformanceMonitor service to track
 * component rendering and interaction performance.
 * 
 * Usage:
 * <div data-controller="performance-monitor" 
 *      data-performance-monitor-id-value="my-component">
 *   <!-- Component content -->
 * </div>
 */
export default class extends Controller {
  static values = { 
    id: String,
    autoStart: { type: Boolean, default: true },
    logReport: { type: Boolean, default: false }
  }

  connect() {
    // Generate a unique ID if none provided
    if (!this.hasIdValue) {
      this.idValue = `component-${Math.random().toString(36).substring(2, 9)}`
    }
    
    // Start measuring render time automatically if autoStart is true
    if (this.autoStartValue) {
      this.startMeasure()
    }
    
    // Track when the component is fully rendered (after all resources are loaded)
    window.addEventListener('load', this.componentLoaded.bind(this), { once: true })
    
    // Set up mutation observer to track DOM changes
    this.setupMutationObserver()
  }
  
  disconnect() {
    // Clean up observers
    if (this.mutationObserver) {
      this.mutationObserver.disconnect()
    }
    
    // Log final report if enabled
    if (this.logReportValue) {
      console.log(`Performance report for ${this.idValue}:`, performanceMonitor.getReport())
    }
  }
  
  /**
   * Start measuring component render time
   */
  startMeasure() {
    performanceMonitor.startMeasure(this.idValue)
  }
  
  /**
   * End measuring component render time
   */
  endMeasure() {
    const duration = performanceMonitor.endMeasure(this.idValue)
    
    // Dispatch custom event with render duration
    this.dispatch('rendered', { 
      detail: { 
        id: this.idValue,
        duration: duration 
      }
    })
    
    return duration
  }
  
  /**
   * Track an interaction within this component
   * @param {Event} event - The DOM event
   */
  trackInteraction(event) {
    const interactionId = `${this.idValue}-${event.type}`
    
    performanceMonitor.trackInteraction(interactionId, () => {
      // The actual interaction handler would go here
      console.log(`Interaction tracked: ${interactionId}`)
    })
  }
  
  /**
   * Called when the component and all its resources are loaded
   */
  componentLoaded() {
    // End the initial render measurement
    if (this.autoStartValue) {
      this.endMeasure()
    }
  }
  
  /**
   * Set up mutation observer to track DOM changes
   */
  setupMutationObserver() {
    this.mutationObserver = new MutationObserver((mutations) => {
      // Only track significant mutations (not style changes)
      const significantMutation = mutations.some(mutation => 
        mutation.type === 'childList' || 
        (mutation.type === 'attributes' && mutation.attributeName !== 'style')
      )
      
      if (significantMutation) {
        // Start a new measurement for this update
        this.startMeasure()
        
        // Use requestAnimationFrame to measure after the browser has rendered
        requestAnimationFrame(() => {
          // End measurement on next frame
          requestAnimationFrame(() => {
            this.endMeasure()
          })
        })
      }
    })
    
    // Start observing the component
    this.mutationObserver.observe(this.element, {
      childList: true,
      attributes: true,
      subtree: true
    })
  }
  
  /**
   * Get the current performance report
   */
  getReport() {
    return performanceMonitor.getReport()
  }
}