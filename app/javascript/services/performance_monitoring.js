/**
 * Performance Monitoring Service
 *
 * This service provides utilities for measuring and tracking performance metrics
 * in the application, with a focus on UI performance.
 */
import { UiMonitoringService } from "./ui_monitoring";

export class PerformanceMonitoringService {
  /**
   * Measure the performance of a function execution
   *
   * @param {string} operationName - Name of the operation being measured
   * @param {Function} callback - Function to measure
   * @param {Object} context - Additional context information
   * @returns {*} - Result of the callback function
   */
  static measure(operationName, callback, context = {}) {
    const startTime = performance.now();

    try {
      const result = callback();
      const duration = performance.now() - startTime;

      UiMonitoringService.sendEvent("performance_metric", {
        metric_name: operationName,
        duration: duration,
        value: duration,
        context: context,
      });

      return result;
    } catch (error) {
      UiMonitoringService.captureError(error, null, {
        operation: operationName,
        duration: performance.now() - startTime,
        ...context,
      });
      throw error;
    }
  }

  /**
   * Track a specific performance metric
   *
   * @param {string} metricName - Name of the metric
   * @param {number} value - Value of the metric
   * @param {Object} context - Additional context information
   */
  static trackMetric(metricName, value, context = {}) {
    UiMonitoringService.sendEvent("performance_metric", {
      metric_name: metricName,
      value: value,
      context: context,
    });
  }

  /**
   * Start tracking a long-running operation
   *
   * @param {string} operationName - Name of the operation
   * @param {Object} context - Additional context information
   * @returns {Function} - Function to call when the operation is complete
   */
  static startTracking(operationName, context = {}) {
    const startTime = performance.now();

    UiMonitoringService.sendEvent("performance_metric", {
      metric_name: `${operationName}_started`,
      timestamp: startTime,
      context: context,
    });

    return () => {
      const duration = performance.now() - startTime;

      UiMonitoringService.sendEvent("performance_metric", {
        metric_name: `${operationName}_completed`,
        duration: duration,
        value: duration,
        context: context,
      });

      return duration;
    };
  }

  /**
   * Initialize performance monitoring for the application
   */
  static initialize() {
    // Track page load performance
    window.addEventListener("load", () => {
      if (window.performance && window.performance.timing) {
        const timing = window.performance.timing;

        // Calculate key metrics
        const loadTime = timing.loadEventEnd - timing.navigationStart;
        const domReadyTime = timing.domComplete - timing.domLoading;
        const networkLatency = timing.responseEnd - timing.fetchStart;

        // Send metrics
        UiMonitoringService.sendEvent("performance_metric", {
          metric_name: "page_load",
          value: loadTime,
          dom_ready_time: domReadyTime,
          network_latency: networkLatency,
          url: window.location.href,
        });
      }
    });

    // Set up observer for theme switching
    document.addEventListener("theme:switching", () => {
      PerformanceMonitoringService.startTracking("theme_switch");
    });

    // Monitor Turbo navigation
    document.addEventListener("turbo:load", () => {
      UiMonitoringService.sendEvent("performance_metric", {
        metric_name: "turbo_navigation",
        url: window.location.href,
      });
    });
  }
}
