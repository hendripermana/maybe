// UI Monitoring Service
// Handles monitoring for theme switching, component errors, and critical UI interactions
import SentryIntegrationService from './sentry_integration_service';

export default class UiMonitoringService {
  static init() {
    this.setupThemeSwitchingMonitoring();
    this.setupComponentErrorMonitoring();
    this.setupCriticalInteractionLogging();
    this.setupPerformanceMonitoring();
    
    // Initialize Sentry integration if available
    if (window.Sentry) {
      SentryIntegrationService.init();
    }
    
    console.log("UI Monitoring Service initialized");
  }

  // Monitor theme switching events and performance
  static setupThemeSwitchingMonitoring() {
    document.addEventListener('theme:switching', (event) => {
      const startTime = performance.now();
      const { from, to } = event.detail;
      
      // Log the theme switch attempt
      console.log(`Theme switching from ${from} to ${to}`);
      
      // Send to monitoring service
      this.logEvent('theme_switch_started', { from, to });
      
      // Listen for completion
      document.addEventListener('theme:switched', () => {
        const duration = performance.now() - startTime;
        
        // Log performance data
        this.logPerformanceMetric('theme_switch_duration', duration);
        
        // Report to monitoring if switch took too long
        if (duration > 300) { // 300ms threshold
          this.reportPerformanceIssue('slow_theme_switch', { 
            duration, 
            from, 
            to,
            userAgent: navigator.userAgent
          });
        }
      }, { once: true });
    });
    
    // Listen for theme switching errors
    document.addEventListener('theme:error', (event) => {
      const { error, theme } = event.detail;
      this.reportError('theme_switch_error', error, { theme });
    });
  }

  // Monitor for component rendering errors
  static setupComponentErrorMonitoring() {
    // Create a global error boundary for component errors
    window.addEventListener('error', (event) => {
      // Check if error is from a component
      if (event.target && event.target.closest('[data-component]')) {
        const componentName = event.target.closest('[data-component]').dataset.component;
        this.reportError('component_render_error', event.error, { 
          componentName,
          componentId: event.target.id,
          errorMessage: event.error?.message || 'Unknown component error'
        });
      } else if (event.error) {
        // Handle general JavaScript errors
        this.reportError('javascript_error', event.error, {
          url: window.location.href,
          userAgent: navigator.userAgent
        });
      }
    });
    
    // Monitor for Stimulus controller errors
    document.addEventListener('stimulus:error', (event) => {
      const { error, controller } = event.detail;
      this.reportError('stimulus_controller_error', error, { 
        controllerName: controller.identifier,
        controllerElement: controller.element.outerHTML.substring(0, 100) // First 100 chars for context
      });
    });
    
    // Monitor for unhandled promise rejections
    window.addEventListener('unhandledrejection', (event) => {
      const error = event.reason instanceof Error ? event.reason : new Error(String(event.reason));
      this.reportError('unhandled_promise_rejection', error, {
        url: window.location.href,
        userAgent: navigator.userAgent
      });
    });
    
    // Add MutationObserver to detect failed component renders
    const observer = new MutationObserver((mutations) => {
      mutations.forEach((mutation) => {
        if (mutation.type === 'childList') {
          mutation.addedNodes.forEach((node) => {
            if (node.nodeType === Node.ELEMENT_NODE) {
              // Check for error indicators in the DOM
              const errorElements = node.querySelectorAll('[data-error], .error-boundary, .component-error');
              if (errorElements.length > 0) {
                errorElements.forEach((element) => {
                  this.reportError('component_render_failure', new Error(element.dataset.error || 'Component failed to render properly'), { 
                    componentName: element.dataset.component || 'unknown',
                    element: element.outerHTML.substring(0, 500)
                  });
                });
              }
            }
          });
        }
      });
    });
    
    // Start observing the document
    observer.observe(document.body, {
      childList: true,
      subtree: true
    });
  }

  // Log critical UI interactions
  static setupCriticalInteractionLogging() {
    // Monitor navigation events
    document.addEventListener('turbo:before-visit', (event) => {
      this.logEvent('page_navigation', { 
        from: window.location.pathname,
        to: event.detail.url
      });
    });
    
    // Monitor modal dialogs
    document.addEventListener('dialog:opened', (event) => {
      const dialogId = event.target.id;
      this.logEvent('dialog_opened', { dialogId });
    });
    
    document.addEventListener('dialog:closed', (event) => {
      const dialogId = event.target.id;
      this.logEvent('dialog_closed', { dialogId });
    });
    
    // Monitor form submissions
    document.addEventListener('turbo:submit-start', (event) => {
      const form = event.target;
      this.logEvent('form_submission', { 
        formId: form.id || 'unknown',
        formAction: form.action
      });
    });
  }
  
  // Setup performance monitoring
  static setupPerformanceMonitoring() {
    // Track page load performance
    window.addEventListener('load', () => {
      if (window.performance && window.performance.timing) {
        const timing = window.performance.timing;
        
        // Calculate key metrics
        const loadTime = timing.loadEventEnd - timing.navigationStart;
        const domReadyTime = timing.domComplete - timing.domLoading;
        const networkLatency = timing.responseEnd - timing.fetchStart;
        
        // Log performance metrics
        this.logPerformanceMetric('page_load', loadTime, {
          dom_ready_time: domReadyTime,
          network_latency: networkLatency,
          url: window.location.href
        });
      }
    });
    
    // Monitor Turbo navigation performance
    let navigationStartTime;
    
    document.addEventListener('turbo:before-visit', () => {
      navigationStartTime = performance.now();
    });
    
    document.addEventListener('turbo:load', () => {
      if (navigationStartTime) {
        const duration = performance.now() - navigationStartTime;
        this.logPerformanceMetric('turbo_navigation', duration, {
          url: window.location.href
        });
      }
    });
    
    // Monitor resource loading performance
    const observer = new PerformanceObserver((list) => {
      list.getEntries().forEach((entry) => {
        // Only log resources that take longer than 1 second to load
        if (entry.duration > 1000) {
          this.logPerformanceMetric('slow_resource_load', entry.duration, {
            resource_type: entry.initiatorType,
            resource_name: entry.name.split('/').pop(),
            resource_url: entry.name
          });
        }
      });
    });
    
    observer.observe({ entryTypes: ['resource'] });
  }

  // Report errors to monitoring service
  static reportError(errorType, error, context = {}) {
    console.error(`[${errorType}]`, error, context);
    
    // Check for duplicate errors if Sentry integration is available
    if (window.Sentry && SentryIntegrationService.isDuplicateError(error, context)) {
      console.log(`Skipping duplicate error report: ${error?.message}`);
      return;
    }
    
    // Send to our UI monitoring system first
    this.sendToUiMonitoring('ui_error', {
      error_type: errorType,
      message: error?.message || 'Unknown error',
      stack: error?.stack,
      context: JSON.stringify(context),
      url: window.location.href,
      user_agent: navigator.userAgent,
      sentry_event_id: window.Sentry ? window.Sentry.lastEventId() : null
    });
    
    // Send to Sentry if available, with reference to our monitoring event
    if (window.Sentry) {
      window.Sentry.captureException(error, {
        tags: { 
          errorType,
          ui_monitoring: true
        },
        extra: {
          ...context,
          ui_monitoring_event_type: errorType
        }
      });
    }
  }

  // Log performance metrics
  static logPerformanceMetric(metricName, value, context = {}) {
    console.log(`[Performance] ${metricName}: ${value}`, context);
    
    // Report to monitoring service if available
    if (window.Sentry) {
      window.Sentry.captureMessage(`Performance: ${metricName}`, {
        level: 'info',
        extra: { value, ...context }
      });
    }
    
    // Send to our UI monitoring system
    this.sendToUiMonitoring('performance_metric', {
      metric_name: metricName,
      value: value,
      context: JSON.stringify(context),
      url: window.location.href
    });
  }

  // Log general UI events
  static logEvent(eventName, data = {}) {
    console.log(`[Event] ${eventName}`, data);
    
    // Only log important events to server to avoid excessive data
    if (['theme_switch_started', 'theme_switch_error', 'component_render_error'].includes(eventName)) {
      this.sendToUiMonitoring('ui_event', {
        event_name: eventName,
        data: JSON.stringify(data),
        url: window.location.href
      });
    }
  }

  // Report performance issues that exceed thresholds
  static reportPerformanceIssue(issueType, data = {}) {
    console.warn(`[Performance Issue] ${issueType}`, data);
    
    if (window.Sentry) {
      window.Sentry.captureMessage(`Performance issue: ${issueType}`, {
        level: 'warning',
        extra: data
      });
    }
    
    this.sendToUiMonitoring('performance_issue', {
      issue_type: issueType,
      data: JSON.stringify(data),
      url: window.location.href
    });
  }
  
  // Send data to our UI monitoring system
  static sendToUiMonitoring(eventType, data) {
    // Get CSRF token
    const token = document.querySelector('meta[name="csrf-token"]')?.content;
    
    // Dispatch event for Sentry integration
    document.dispatchEvent(new CustomEvent('ui-monitoring:event', {
      detail: { eventType, data }
    }));
    
    // For performance metrics, dispatch a specific event
    if (eventType === 'performance_metric') {
      document.dispatchEvent(new CustomEvent('ui-monitoring:performance', {
        detail: {
          metricName: data.metric_name,
          value: parseFloat(data.value),
          context: data.context ? JSON.parse(data.context) : {}
        }
      }));
    }
    
    fetch('/api/ui_monitoring_events', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': token
      },
      body: JSON.stringify({
        ui_monitoring_event: {
          event_type: eventType,
          data: data
        }
      }),
      // Use keepalive to ensure the request completes even if page is unloading
      keepalive: true
    })
    .then(response => response.json())
    .then(result => {
      if (result.event_id) {
        // Store the event ID for Sentry integration
        window.lastUiMonitoringEventId = result.event_id;
      }
    })
    .catch(error => {
      console.error('Error sending monitoring data:', error);
    });
  }

  // Send data to server endpoint (legacy method)
  static sendToServer(endpoint, data) {
    // Get CSRF token
    const token = document.querySelector('meta[name="csrf-token"]')?.content;
    
    // Only send if we're not in development mode
    if (process.env.NODE_ENV !== 'development') {
      fetch(endpoint, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': token
        },
        body: JSON.stringify(data),
        // Use keepalive to ensure the request completes even if page is unloading
        keepalive: true
      }).catch(error => {
        console.error('Error sending monitoring data:', error);
      });
    }
  }
  
  // Capture an error and send it to the monitoring system
  static captureError(error, componentName = null, context = {}) {
    this.reportError('captured_error', error, {
      component_name: componentName,
      ...context
    });
  }
  
  // Measure component render performance
  static measureComponentRender(componentName, callback) {
    const startTime = performance.now();
    
    try {
      const result = callback();
      const duration = performance.now() - startTime;
      
      this.logPerformanceMetric('component_render_time', duration, {
        component_name: componentName
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
}