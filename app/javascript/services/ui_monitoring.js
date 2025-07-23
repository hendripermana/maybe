/**
 * UI Monitoring Service
 * 
 * This service provides client-side monitoring for UI errors, performance issues,
 * and theme switching problems. It captures error details, performance metrics,
 * and sends them to the server for analysis.
 */
export class UiMonitoringService {
  /**
   * Capture an error and send it to the server
   * 
   * @param {Error} error - The error object
   * @param {string} componentName - Optional name of the component where the error occurred
   * @param {Object} context - Optional additional context information
   */
  static captureError(error, componentName = null, context = {}) {
    const eventData = {
      error_type: error.name,
      message: error.message,
      stack: error.stack,
      component_name: componentName,
      context: JSON.stringify(context),
      url: window.location.href,
      user_agent: navigator.userAgent
    };
    
    this.sendEvent('ui_error', eventData);
  }
  
  /**
   * Measure and record theme switching performance
   */
  static measureThemeSwitch() {
    const startTime = performance.now();
    
    // Record the start of theme switching
    this.sendEvent('performance_metric', {
      event_name: 'theme_switch_started',
      timestamp: startTime
    });
    
    // Listen for theme switch completion
    document.addEventListener('theme:switched', () => {
      const duration = performance.now() - startTime;
      
      this.sendEvent('performance_metric', {
        event_name: 'theme_switched',
        duration: duration,
        metric_name: 'theme_switch_duration',
        value: duration
      });
    });
  }
  
  /**
   * Measure component render performance
   * 
   * @param {string} componentName - Name of the component being rendered
   * @param {Function} callback - Function that performs the rendering
   * @returns {*} - Result of the callback function
   */
  static measureComponentRender(componentName, callback) {
    const startTime = performance.now();
    
    try {
      const result = callback();
      const duration = performance.now() - startTime;
      
      this.sendEvent('performance_metric', {
        metric_name: 'component_render_time',
        component_name: componentName,
        value: duration
      });
      
      return result;
    } catch (error) {
      this.captureError(error, componentName, {
        operation: 'component_render',
        duration: performance.now() - startTime
      });
      throw error;
    }
  }
  
  /**
   * Send an event to the server
   * 
   * @param {string} eventType - Type of event (ui_error, performance_metric, etc.)
   * @param {Object} data - Event data
   */
  static sendEvent(eventType, data) {
    fetch('/api/ui_monitoring_events', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]')?.content
      },
      body: JSON.stringify({
        ui_monitoring_event: {
          event_type: eventType,
          data: data
        }
      })
    }).catch(err => console.error('Failed to send monitoring event:', err));
  }
}

// Set up global error handler
window.addEventListener('error', (event) => {
  UiMonitoringService.captureError(event.error);
});

// Set up unhandled promise rejection handler
window.addEventListener('unhandledrejection', (event) => {
  UiMonitoringService.captureError(
    event.reason instanceof Error ? event.reason : new Error(String(event.reason)),
    null,
    { type: 'unhandled_promise_rejection' }
  );
});