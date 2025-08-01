// app/javascript/services/performance_monitor.js

/**
 * Performance Monitor Service
 *
 * This service provides utilities for measuring and reporting component performance.
 * It tracks render times, interaction responsiveness, and reports metrics for optimization.
 */
export default class PerformanceMonitor {
  constructor() {
    this.metrics = {
      renders: {},
      interactions: {},
      resources: {},
    };

    this.observer = null;
    this.setupPerformanceObserver();
  }

  /**
   * Set up a Performance Observer to track long tasks and layout shifts
   */
  setupPerformanceObserver() {
    if ("PerformanceObserver" in window) {
      // Track long tasks (tasks that block the main thread for more than 50ms)
      try {
        const longTaskObserver = new PerformanceObserver((list) => {
          list.getEntries().forEach((entry) => {
            console.warn(
              "Long task detected:",
              entry.duration.toFixed(2) + "ms",
              entry,
            );
            this.metrics.resources.longTasks =
              this.metrics.resources.longTasks || [];
            this.metrics.resources.longTasks.push({
              duration: entry.duration,
              timestamp: performance.now(),
              attribution: entry.attribution,
            });
          });
        });

        longTaskObserver.observe({ entryTypes: ["longtask"] });
      } catch (e) {
        console.warn("Long task observation not supported", e);
      }

      // Track layout shifts (Cumulative Layout Shift metric)
      try {
        const layoutShiftObserver = new PerformanceObserver((list) => {
          list.getEntries().forEach((entry) => {
            if (!entry.hadRecentInput) {
              console.warn(
                "Layout shift detected:",
                entry.value.toFixed(4),
                entry,
              );
              this.metrics.resources.layoutShifts =
                this.metrics.resources.layoutShifts || [];
              this.metrics.resources.layoutShifts.push({
                value: entry.value,
                timestamp: performance.now(),
              });
            }
          });
        });

        layoutShiftObserver.observe({ entryTypes: ["layout-shift"] });
      } catch (e) {
        console.warn("Layout shift observation not supported", e);
      }

      // Track resource loading performance
      try {
        const resourceObserver = new PerformanceObserver((list) => {
          list.getEntries().forEach((entry) => {
            // Only track CSS and JS resources
            if (
              entry.initiatorType === "link" ||
              entry.initiatorType === "script"
            ) {
              this.metrics.resources.entries =
                this.metrics.resources.entries || [];
              this.metrics.resources.entries.push({
                name: entry.name,
                duration: entry.duration,
                size: entry.transferSize,
                type: entry.initiatorType,
              });
            }
          });
        });

        resourceObserver.observe({ entryTypes: ["resource"] });
      } catch (e) {
        console.warn("Resource observation not supported", e);
      }
    }
  }

  /**
   * Start measuring a component render
   * @param {string} componentId - Unique identifier for the component
   */
  startMeasure(componentId) {
    if (!this.metrics.renders[componentId]) {
      this.metrics.renders[componentId] = {
        counts: 0,
        totalTime: 0,
        lastStart: performance.now(),
        history: [],
      };
    } else {
      this.metrics.renders[componentId].lastStart = performance.now();
    }

    // Create a performance mark
    if (performance.mark) {
      performance.mark(`${componentId}-start`);
    }
  }

  /**
   * End measuring a component render and record metrics
   * @param {string} componentId - Unique identifier for the component
   */
  endMeasure(componentId) {
    if (!this.metrics.renders[componentId]) return;

    const endTime = performance.now();
    const startTime = this.metrics.renders[componentId].lastStart;
    const duration = endTime - startTime;

    // Update metrics
    this.metrics.renders[componentId].counts++;
    this.metrics.renders[componentId].totalTime += duration;
    this.metrics.renders[componentId].lastDuration = duration;
    this.metrics.renders[componentId].average =
      this.metrics.renders[componentId].totalTime /
      this.metrics.renders[componentId].counts;

    // Keep history of last 10 renders
    this.metrics.renders[componentId].history.push({
      timestamp: endTime,
      duration: duration,
    });

    if (this.metrics.renders[componentId].history.length > 10) {
      this.metrics.renders[componentId].history.shift();
    }

    // Create a performance measure
    if (performance.measure) {
      try {
        performance.measure(`${componentId}-render`, `${componentId}-start`);
      } catch (e) {
        console.warn("Could not create performance measure", e);
      }
    }

    // Log slow renders (over 100ms)
    if (duration > 100) {
      console.warn(
        `Slow render detected for ${componentId}: ${duration.toFixed(2)}ms`,
      );
    }

    return duration;
  }

  /**
   * Track an interaction event (click, input, etc.)
   * @param {string} interactionId - Identifier for the interaction type
   * @param {function} callback - The interaction handler to measure
   */
  trackInteraction(interactionId, callback) {
    const start = performance.now();

    // Execute the callback
    callback();

    const duration = performance.now() - start;

    // Record the interaction time
    if (!this.metrics.interactions[interactionId]) {
      this.metrics.interactions[interactionId] = {
        counts: 0,
        totalTime: 0,
        history: [],
      };
    }

    this.metrics.interactions[interactionId].counts++;
    this.metrics.interactions[interactionId].totalTime += duration;
    this.metrics.interactions[interactionId].average =
      this.metrics.interactions[interactionId].totalTime /
      this.metrics.interactions[interactionId].counts;

    // Keep history of last 10 interactions
    this.metrics.interactions[interactionId].history.push({
      timestamp: performance.now(),
      duration: duration,
    });

    if (this.metrics.interactions[interactionId].history.length > 10) {
      this.metrics.interactions[interactionId].history.shift();
    }

    // Log slow interactions (over 50ms)
    if (duration > 50) {
      console.warn(
        `Slow interaction detected for ${interactionId}: ${duration.toFixed(2)}ms`,
      );
    }

    return duration;
  }

  /**
   * Get performance report for all tracked components and interactions
   */
  getReport() {
    return {
      timestamp: new Date().toISOString(),
      renders: this.metrics.renders,
      interactions: this.metrics.interactions,
      resources: this.metrics.resources,
      summary: this.generateSummary(),
    };
  }

  /**
   * Generate a summary of performance metrics
   */
  generateSummary() {
    const summary = {
      slowestRender: { id: null, time: 0 },
      slowestInteraction: { id: null, time: 0 },
      totalRenders: 0,
      totalInteractions: 0,
      layoutShifts: 0,
      longTasks: 0,
    };

    // Find slowest render
    Object.entries(this.metrics.renders).forEach(([id, data]) => {
      summary.totalRenders += data.counts;

      if (data.average > summary.slowestRender.time) {
        summary.slowestRender = { id, time: data.average };
      }
    });

    // Find slowest interaction
    Object.entries(this.metrics.interactions).forEach(([id, data]) => {
      summary.totalInteractions += data.counts;

      if (data.average > summary.slowestInteraction.time) {
        summary.slowestInteraction = { id, time: data.average };
      }
    });

    // Count layout shifts and long tasks
    if (this.metrics.resources.layoutShifts) {
      summary.layoutShifts = this.metrics.resources.layoutShifts.length;
    }

    if (this.metrics.resources.longTasks) {
      summary.longTasks = this.metrics.resources.longTasks.length;
    }

    return summary;
  }

  /**
   * Clear all recorded metrics
   */
  clearMetrics() {
    this.metrics = {
      renders: {},
      interactions: {},
      resources: {},
    };
  }
}

// Create a singleton instance
const performanceMonitor = new PerformanceMonitor();
export { performanceMonitor };
