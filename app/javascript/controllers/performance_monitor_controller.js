import { Controller } from "@hotwired/stimulus"

// This controller monitors and reports performance metrics
export default class extends Controller {
  static targets = ["result"]
  
  connect() {
    this.monitorPageLoad()
    this.monitorThemeSwitching()
    this.detectLayoutShifts()
  }
  
  monitorPageLoad() {
    // Use Performance API to measure page load
    if (window.performance) {
      const perfData = window.performance.timing
      const pageLoadTime = perfData.loadEventEnd - perfData.navigationStart
      
      this.logMetric("Page Load Time", pageLoadTime + "ms")
      
      // Report to server
      this.reportMetric("page_load", pageLoadTime)
    }
  }
  
  monitorThemeSwitching() {
    // Add listener for theme changes
    document.addEventListener("theme-changed", (event) => {
      const switchTime = event.detail.switchTime
      this.logMetric("Theme Switch Time", switchTime + "ms")
      
      // Report to server
      this.reportMetric("theme_switch", switchTime)
    })
  }
  
  detectLayoutShifts() {
    // Use Layout Instability API if available
    if ("LayoutShift" in window) {
      let cumulativeLayoutShift = 0
      
      const observer = new PerformanceObserver((list) => {
        for (const entry of list.getEntries()) {
          // Only count layout shifts without recent user input
          if (!entry.hadRecentInput) {
            cumulativeLayoutShift += entry.value
          }
        }
        
        this.logMetric("Cumulative Layout Shift", cumulativeLayoutShift.toFixed(3))
        
        // Report to server if significant
        if (cumulativeLayoutShift > 0.1) {
          this.reportMetric("layout_shift", cumulativeLayoutShift)
        }
      })
      
      observer.observe({ type: "layout-shift", buffered: true })
    }
  }
  
  logMetric(name, value) {
    if (this.hasResultTarget) {
      const item = document.createElement("div")
      item.classList.add("performance-metric")
      item.innerHTML = `<strong>${name}:</strong> ${value}`
      this.resultTarget.appendChild(item)
    }
    
    // Also log to console
    console.log(`Performance: ${name} = ${value}`)
  }
  
  reportMetric(name, value) {
    // Send metric to server for logging
    const csrfToken = document.querySelector("meta[name='csrf-token']").content
    
    fetch("/performance/metrics", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": csrfToken
      },
      body: JSON.stringify({
        metric: {
          name: name,
          value: value,
          path: window.location.pathname,
          user_agent: navigator.userAgent
        }
      })
    }).catch(error => console.error("Error reporting metric:", error))
  }
}