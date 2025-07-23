// UI Monitoring Service
// Handles monitoring for theme switching, component errors, and critical UI interactions

export default class UiMonitoringService {
  static init() {
    this.setupThemeSwitchingMonitoring();
    this.setupComponentErrorMonitoring();
    this.setupCriticalInteractionLogging();
    
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

  // Report errors to monitoring service (Sentry)
  static reportError(errorType, error, context = {}) {
    console.error(`[${errorType}]`, error, context);
    
    // Send to Sentry if available
    if (window.Sentry) {
      window.Sentry.captureException(error, {
        tags: { errorType },
        extra: context
      });
    }
    
    // Send to server-side logging
    this.sendToServer('/monitoring/ui_error', {
      error_type: errorType,
      message: error?.message || 'Unknown error',
      stack: error?.stack,
      context: JSON.stringify(context),
      url: window.location.href,
      user_agent: navigator.userAgent
    });
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
    
    // Send to server for aggregation
    this.sendToServer('/monitoring/performance_metric', {
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
      this.sendToServer('/monitoring/ui_event', {
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
    
    this.sendToServer('/monitoring/performance_issue', {
      issue_type: issueType,
      data: JSON.stringify(data),
      url: window.location.href
    });
  }

  // Send data to server endpoint
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
}