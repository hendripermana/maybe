import { Controller } from "@hotwired/stimulus"
import UiMonitoringService from "../services/ui_monitoring_service"

// Monitors theme switching and reports performance metrics
export default class extends Controller {
  static targets = ["themeSwitch"]
  
  connect() {
    this.observeThemeChanges()
    
    // Log initial theme on page load
    const currentTheme = document.documentElement.dataset.theme || 'light'
    UiMonitoringService.logEvent('theme_initial_load', { theme: currentTheme })
  }
  
  observeThemeChanges() {
    // Use MutationObserver to detect theme attribute changes
    this.observer = new MutationObserver((mutations) => {
      mutations.forEach((mutation) => {
        if (mutation.attributeName === 'data-theme') {
          const newTheme = document.documentElement.dataset.theme
          const oldTheme = mutation.oldValue
          
          // Dispatch custom event that our monitoring service listens for
          document.dispatchEvent(new CustomEvent('theme:switched', { 
            detail: { from: oldTheme, to: newTheme }
          }))
          
          // Log the successful theme change
          UiMonitoringService.logEvent('theme_switched', { 
            from: oldTheme, 
            to: newTheme,
            duration: performance.now() - this.themeChangeStartTime
          })
        }
      })
    })
    
    // Start observing document for theme changes
    this.observer.observe(document.documentElement, { 
      attributes: true, 
      attributeFilter: ['data-theme'],
      attributeOldValue: true
    })
  }
  
  // Called when user clicks theme toggle
  toggleTheme(event) {
    this.themeChangeStartTime = performance.now()
    
    const currentTheme = document.documentElement.dataset.theme || 'light'
    const newTheme = currentTheme === 'dark' ? 'light' : 'dark'
    
    // Dispatch event before theme changes
    document.dispatchEvent(new CustomEvent('theme:switching', { 
      detail: { from: currentTheme, to: newTheme }
    }))
    
    try {
      // Let the regular theme toggle logic happen
    } catch (error) {
      document.dispatchEvent(new CustomEvent('theme:error', { 
        detail: { error, theme: newTheme }
      }))
    }
  }
  
  disconnect() {
    if (this.observer) {
      this.observer.disconnect()
    }
  }
}