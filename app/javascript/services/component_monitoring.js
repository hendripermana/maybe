/**
 * Component Monitoring Service
 * 
 * This service provides utilities for monitoring ViewComponent rendering
 * and Stimulus controller lifecycle events.
 */
import { UiMonitoringService } from './ui_monitoring';
import { PerformanceMonitoringService } from './performance_monitoring';

export class ComponentMonitoringService {
  /**
   * Initialize component monitoring
   */
  static initialize() {
    this.monitorStimulusControllers();
    this.setupComponentErrorBoundary();
  }
  
  /**
   * Monitor Stimulus controllers for errors and performance
   */
  static monitorStimulusControllers() {
    if (window.Stimulus) {
      const originalControllerConnect = window.Stimulus.Controller.prototype.connect;
      window.Stimulus.Controller.prototype.connect = function() {
        try {
          const startTime = performance.now();
          originalControllerConnect.apply(this, arguments);
          const duration = performance.now() - startTime;
          
          UiMonitoringService.sendEvent('performance_metric', {
            metric_name: 'stimulus_controller_connect',
            component_name: this.identifier,
            value: duration,
            element_id: this.element.id || null,
            element_class: this.element.className || null
          });
        } catch (error) {
          UiMonitoringService.captureError(error, this.identifier, {
            operation: 'stimulus_controller_connect',
            element: this.element.outerHTML.substring(0, 500)
          });
          throw error;
        }
      };
      
      const originalControllerDisconnect = window.Stimulus.Controller.prototype.disconnect;
      window.Stimulus.Controller.prototype.disconnect = function() {
        try {
          originalControllerDisconnect.apply(this, arguments);
        } catch (error) {
          UiMonitoringService.captureError(error, this.identifier, {
            operation: 'stimulus_controller_disconnect',
            element: this.element.outerHTML.substring(0, 500)
          });
          throw error;
        }
      };
    }
  }
  
  /**
   * Set up error boundary for component rendering
   */
  static setupComponentErrorBoundary() {
    // Monitor ViewComponent rendering errors
    // This is a simplified approach since ViewComponent doesn't have built-in error boundaries
    const originalRenderInline = window.ViewComponent?.renderInline;
    if (originalRenderInline) {
      window.ViewComponent.renderInline = function(name, props) {
        try {
          return PerformanceMonitoringService.measure(
            'view_component_render',
            () => originalRenderInline.apply(this, arguments),
            { component_name: name, props: JSON.stringify(props).substring(0, 1000) }
          );
        } catch (error) {
          UiMonitoringService.captureError(error, name, {
            operation: 'view_component_render',
            props: JSON.stringify(props).substring(0, 1000)
          });
          throw error;
        }
      };
    }
    
    // Add MutationObserver to detect failed component renders
    // This is a heuristic approach to detect when components fail to render properly
    const observer = new MutationObserver((mutations) => {
      mutations.forEach((mutation) => {
        if (mutation.type === 'childList') {
          mutation.addedNodes.forEach((node) => {
            if (node.nodeType === Node.ELEMENT_NODE) {
              // Check for error indicators in the DOM
              const errorElements = node.querySelectorAll('[data-error], .error-boundary, .component-error');
              if (errorElements.length > 0) {
                errorElements.forEach((element) => {
                  UiMonitoringService.sendEvent('ui_error', {
                    error_type: 'component_render_failure',
                    component_name: element.dataset.component || 'unknown',
                    message: element.dataset.error || 'Component failed to render properly',
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
  
  /**
   * Monitor a specific component for errors
   * 
   * @param {string} componentName - Name of the component
   * @param {HTMLElement} element - Component's DOM element
   */
  static monitorComponent(componentName, element) {
    // Add error tracking to the component
    element.addEventListener('error', (event) => {
      UiMonitoringService.captureError(event.error, componentName, {
        element: element.outerHTML.substring(0, 500)
      });
    });
    
    // Track component interactions
    element.addEventListener('click', (event) => {
      UiMonitoringService.sendEvent('component_interaction', {
        component_name: componentName,
        interaction_type: 'click',
        target_element: event.target.tagName,
        target_class: event.target.className
      });
    });
  }
}