// Sentry Integration Service
// Connects UI monitoring with Sentry for unified error tracking

export default class SentryIntegrationService {
  static init() {
    // Only initialize if Sentry is available
    if (!window.Sentry) {
      console.log("Sentry not available, skipping integration");
      return;
    }

    this.setupErrorBreadcrumbs();
    this.setupPerformanceTracking();
    this.setupContextEnrichment();
    
    console.log("Sentry Integration Service initialized");
  }

  // Set up breadcrumbs for UI monitoring events
  static setupErrorBreadcrumbs() {
    // Listen for UI monitoring events and add them as breadcrumbs in Sentry
    document.addEventListener('ui-monitoring:event', (event) => {
      const { eventType, data } = event.detail;
      
      window.Sentry.addBreadcrumb({
        category: 'ui-monitoring',
        message: `UI Monitoring: ${eventType}`,
        data: data,
        level: this.getSentryLevel(eventType)
      });
    });
    
    // Listen for theme switching events
    document.addEventListener('theme:switching', (event) => {
      window.Sentry.addBreadcrumb({
        category: 'theme',
        message: `Theme switching from ${event.detail.from} to ${event.detail.to}`,
        level: 'info'
      });
    });
    
    document.addEventListener('theme:switched', (event) => {
      window.Sentry.addBreadcrumb({
        category: 'theme',
        message: `Theme switched to ${document.documentElement.dataset.theme}`,
        level: 'info'
      });
    });
    
    document.addEventListener('theme:error', (event) => {
      window.Sentry.addBreadcrumb({
        category: 'theme',
        message: `Theme switching error: ${event.detail.error?.message || 'Unknown error'}`,
        level: 'error'
      });
    });
  }

  // Set up performance tracking integration
  static setupPerformanceTracking() {
    // Create Sentry transactions for important UI operations
    document.addEventListener('ui-monitoring:performance', (event) => {
      const { metricName, value, context } = event.detail;
      
      // Only create transactions for significant metrics
      if (['page_load', 'turbo_navigation', 'theme_switch_duration'].includes(metricName)) {
        const transaction = window.Sentry.startTransaction({
          name: `ui.${metricName}`,
          op: 'ui.performance'
        });
        
        // Add spans for context data if available
        if (context) {
          Object.entries(context).forEach(([key, val]) => {
            if (typeof val === 'number') {
              const span = transaction.startChild({
                op: 'ui.metric',
                description: key
              });
              span.finish(val);
            }
          });
        }
        
        // Set transaction metadata
        transaction.setTag('metric_name', metricName);
        transaction.setTag('metric_value', value);
        transaction.setData('context', context);
        
        // Finish the transaction with the measured value
        transaction.finish(value);
      }
    });
  }

  // Enrich Sentry events with UI monitoring context
  static setupContextEnrichment() {
    // Store the original Sentry beforeSend function
    const originalBeforeSend = window.Sentry.getClient().getOptions().beforeSend;
    
    // Override beforeSend to add UI monitoring context
    window.Sentry.getClient().getOptions().beforeSend = (event, hint) => {
      // Add UI monitoring event ID if available
      if (window.lastUiMonitoringEventId) {
        event.tags = event.tags || {};
        event.tags.ui_monitoring_event_id = window.lastUiMonitoringEventId;
        
        // Add link to UI monitoring dashboard in the event
        event.contexts = event.contexts || {};
        event.contexts.ui_monitoring = {
          event_id: window.lastUiMonitoringEventId,
          dashboard_url: `${window.location.origin}/monitoring/events?search=${window.lastUiMonitoringEventId}`
        };
      }
      
      // Add current theme information
      event.tags = event.tags || {};
      event.tags.theme = document.documentElement.dataset.theme || 'light';
      
      // Call the original beforeSend if it exists
      return originalBeforeSend ? originalBeforeSend(event, hint) : event;
    };
  }

  // Map UI monitoring event types to Sentry severity levels
  static getSentryLevel(eventType) {
    switch (eventType) {
      case 'ui_error':
        return 'error';
      case 'performance_issue':
        return 'warning';
      case 'performance_metric':
        return 'info';
      default:
        return 'debug';
    }
  }

  // Check if an error has already been reported to Sentry
  // This helps prevent duplicate error reporting
  static isDuplicateError(error, context) {
    // This is a simplified check - in a real implementation,
    // you might want to use more sophisticated fingerprinting
    const errorKey = `${error.name}:${error.message}:${JSON.stringify(context)}`;
    
    if (this.recentErrors && this.recentErrors.has(errorKey)) {
      return true;
    }
    
    // Store in recent errors cache with a 5-minute expiration
    if (!this.recentErrors) {
      this.recentErrors = new Map();
    }
    
    this.recentErrors.set(errorKey, Date.now());
    
    // Clean up old entries
    this.cleanupRecentErrors();
    
    return false;
  }
  
  // Clean up errors older than 5 minutes
  static cleanupRecentErrors() {
    if (!this.recentErrors) return;
    
    const now = Date.now();
    const expirationTime = 5 * 60 * 1000; // 5 minutes
    
    for (const [key, timestamp] of this.recentErrors.entries()) {
      if (now - timestamp > expirationTime) {
        this.recentErrors.delete(key);
      }
    }
  }
}