// app/javascript/controllers/performance_test_controller.js
import { Controller } from "@hotwired/stimulus";
import { performanceMonitor } from "../services/performance_monitor";
import { cssPurge } from "../services/css_purge";

/**
 * Performance Test Controller
 *
 * This controller runs performance tests and generates reports.
 * It can be used to measure the impact of optimizations.
 *
 * Usage:
 * <div data-controller="performance-test"
 *      data-performance-test-auto-run-value="true">
 *   <button data-action="click->performance-test#runTests">Run Tests</button>
 *   <div data-performance-test-target="results"></div>
 * </div>
 */
export default class extends Controller {
  static targets = ["results"];
  static values = {
    autoRun: { type: Boolean, default: false },
    iterations: { type: Number, default: 5 },
  };

  connect() {
    this.testResults = {
      cssAnalysis: null,
      renderTimes: [],
      interactionTimes: [],
      memoryUsage: [],
      layoutShifts: 0,
    };

    // Run tests automatically if enabled
    if (this.autoRunValue) {
      // Wait for the page to fully load
      window.addEventListener("load", () => {
        setTimeout(() => {
          this.runTests();
        }, 1000);
      });
    }
  }

  /**
   * Run all performance tests
   */
  async runTests() {
    this.showMessage("Running performance tests...");

    // Run CSS analysis
    this.testResults.cssAnalysis = cssPurge.analyze();

    // Measure render times
    await this.measureRenderTimes();

    // Measure interaction times
    await this.measureInteractionTimes();

    // Measure memory usage
    await this.measureMemoryUsage();

    // Count layout shifts
    this.testResults.layoutShifts = this.countLayoutShifts();

    // Generate and display report
    this.generateReport();

    // Dispatch event with results
    this.dispatch("tested", {
      detail: {
        results: this.testResults,
      },
    });
  }

  /**
   * Measure component render times
   */
  async measureRenderTimes() {
    this.showMessage("Measuring render times...");

    // Reset render times
    this.testResults.renderTimes = [];

    // Run multiple iterations
    for (let i = 0; i < this.iterationsValue; i++) {
      // Force re-render of components by toggling a class
      document.body.classList.add("force-rerender");

      // Wait for next frame
      await new Promise((resolve) =>
        requestAnimationFrame(() => {
          requestAnimationFrame(resolve);
        }),
      );

      // Remove the class
      document.body.classList.remove("force-rerender");

      // Wait for next frame
      await new Promise((resolve) =>
        requestAnimationFrame(() => {
          requestAnimationFrame(resolve);
        }),
      );

      // Get render times from performance monitor
      const report = performanceMonitor.getReport();

      // Extract render times
      const renderTimes = Object.entries(report.renders).map(([id, data]) => ({
        id,
        average: data.average,
        lastDuration: data.lastDuration,
      }));

      this.testResults.renderTimes.push(renderTimes);
    }
  }

  /**
   * Measure interaction times
   */
  async measureInteractionTimes() {
    this.showMessage("Measuring interaction times...");

    // Reset interaction times
    this.testResults.interactionTimes = [];

    // Find interactive elements
    const buttons = document.querySelectorAll("button:not([disabled])");
    const inputs = document.querySelectorAll("input:not([disabled])");
    const links = document.querySelectorAll('a[href="#"]');

    // Sample a few elements for testing
    const elements = [
      ...Array.from(buttons).slice(0, 3),
      ...Array.from(inputs).slice(0, 3),
      ...Array.from(links).slice(0, 3),
    ];

    // Measure interaction times for each element
    for (const element of elements) {
      const elementType = element.tagName.toLowerCase();
      const elementId =
        element.id ||
        `${elementType}-${Math.random().toString(36).substring(2, 9)}`;

      // Start measuring
      performanceMonitor.startMeasure(`interaction-${elementId}`);

      // Simulate interaction
      if (elementType === "button" || elementType === "a") {
        // Create and dispatch click event
        const clickEvent = new MouseEvent("click", {
          bubbles: true,
          cancelable: true,
          view: window,
        });

        element.dispatchEvent(clickEvent);
      } else if (elementType === "input") {
        // Create and dispatch input event
        element.value = "test";

        const inputEvent = new Event("input", {
          bubbles: true,
          cancelable: true,
        });

        element.dispatchEvent(inputEvent);
      }

      // End measuring
      const duration = performanceMonitor.endMeasure(
        `interaction-${elementId}`,
      );

      // Record result
      this.testResults.interactionTimes.push({
        element: elementId,
        type: elementType,
        duration,
      });

      // Wait a bit before next interaction
      await new Promise((resolve) => setTimeout(resolve, 100));
    }
  }

  /**
   * Measure memory usage
   */
  async measureMemoryUsage() {
    this.showMessage("Measuring memory usage...");

    // Reset memory usage
    this.testResults.memoryUsage = [];

    // Check if performance.memory is available (Chrome only)
    if (performance.memory) {
      // Measure memory usage multiple times
      for (let i = 0; i < 3; i++) {
        this.testResults.memoryUsage.push({
          totalJSHeapSize: performance.memory.totalJSHeapSize / (1024 * 1024),
          usedJSHeapSize: performance.memory.usedJSHeapSize / (1024 * 1024),
          jsHeapSizeLimit: performance.memory.jsHeapSizeLimit / (1024 * 1024),
        });

        // Wait a bit between measurements
        await new Promise((resolve) => setTimeout(resolve, 500));
      }
    } else {
      this.testResults.memoryUsage.push({
        error: "Memory API not available in this browser",
      });
    }
  }

  /**
   * Count layout shifts
   */
  countLayoutShifts() {
    // Get layout shifts from performance monitor
    const report = performanceMonitor.getReport();

    if (report.resources.layoutShifts) {
      return report.resources.layoutShifts.length;
    }

    return 0;
  }

  /**
   * Generate and display performance report
   */
  generateReport() {
    if (!this.hasResultsTarget) return;

    // Calculate average render time
    const averageRenderTime = this.calculateAverageRenderTime();

    // Calculate average interaction time
    const averageInteractionTime = this.calculateAverageInteractionTime();

    // Calculate average memory usage
    const averageMemoryUsage = this.calculateAverageMemoryUsage();

    // Generate HTML report
    const reportHtml = `
      <div class="performance-report p-4 bg-container border border-secondary rounded-lg">
        <h3 class="text-lg font-medium mb-4">Performance Test Results</h3>
        
        <div class="mb-4">
          <h4 class="font-medium">CSS Analysis</h4>
          <ul class="list-disc pl-5">
            <li>Total CSS Rules: ${this.testResults.cssAnalysis?.totalRules || "N/A"}</li>
            <li>Unused CSS Rules: ${this.testResults.cssAnalysis?.unusedRules || "N/A"} (${this.calculateUnusedCssPercentage()}%)</li>
            <li>Preserved Rules: ${this.testResults.cssAnalysis?.preservedRules || "N/A"}</li>
          </ul>
        </div>
        
        <div class="mb-4">
          <h4 class="font-medium">Render Performance</h4>
          <ul class="list-disc pl-5">
            <li>Average Render Time: ${averageRenderTime.toFixed(2)} ms</li>
            <li>Components Measured: ${this.testResults.renderTimes[0]?.length || 0}</li>
            <li>Test Iterations: ${this.testResults.renderTimes.length}</li>
          </ul>
        </div>
        
        <div class="mb-4">
          <h4 class="font-medium">Interaction Performance</h4>
          <ul class="list-disc pl-5">
            <li>Average Interaction Time: ${averageInteractionTime.toFixed(2)} ms</li>
            <li>Interactions Measured: ${this.testResults.interactionTimes.length}</li>
          </ul>
        </div>
        
        <div class="mb-4">
          <h4 class="font-medium">Memory Usage</h4>
          <ul class="list-disc pl-5">
            <li>Used JS Heap: ${averageMemoryUsage.usedJSHeapSize?.toFixed(2) || "N/A"} MB</li>
            <li>Total JS Heap: ${averageMemoryUsage.totalJSHeapSize?.toFixed(2) || "N/A"} MB</li>
            <li>Heap Limit: ${averageMemoryUsage.jsHeapSizeLimit?.toFixed(2) || "N/A"} MB</li>
          </ul>
        </div>
        
        <div class="mb-4">
          <h4 class="font-medium">Layout Stability</h4>
          <ul class="list-disc pl-5">
            <li>Layout Shifts: ${this.testResults.layoutShifts}</li>
          </ul>
        </div>
        
        <div class="text-sm text-secondary mt-4">
          Tests completed at ${new Date().toLocaleTimeString()}
        </div>
      </div>
    `;

    // Update results target
    this.resultsTarget.innerHTML = reportHtml;
  }

  /**
   * Calculate average render time across all components and iterations
   */
  calculateAverageRenderTime() {
    if (this.testResults.renderTimes.length === 0) return 0;

    let totalTime = 0;
    let count = 0;

    this.testResults.renderTimes.forEach((iteration) => {
      iteration.forEach((component) => {
        totalTime += component.average || 0;
        count++;
      });
    });

    return count > 0 ? totalTime / count : 0;
  }

  /**
   * Calculate average interaction time
   */
  calculateAverageInteractionTime() {
    if (this.testResults.interactionTimes.length === 0) return 0;

    const totalTime = this.testResults.interactionTimes.reduce(
      (sum, interaction) => sum + (interaction.duration || 0),
      0,
    );

    return totalTime / this.testResults.interactionTimes.length;
  }

  /**
   * Calculate average memory usage
   */
  calculateAverageMemoryUsage() {
    if (
      this.testResults.memoryUsage.length === 0 ||
      this.testResults.memoryUsage[0].error
    ) {
      return {
        usedJSHeapSize: 0,
        totalJSHeapSize: 0,
        jsHeapSizeLimit: 0,
      };
    }

    const totalUsed = this.testResults.memoryUsage.reduce(
      (sum, memory) => sum + (memory.usedJSHeapSize || 0),
      0,
    );

    const totalSize = this.testResults.memoryUsage.reduce(
      (sum, memory) => sum + (memory.totalJSHeapSize || 0),
      0,
    );

    const totalLimit = this.testResults.memoryUsage.reduce(
      (sum, memory) => sum + (memory.jsHeapSizeLimit || 0),
      0,
    );

    const count = this.testResults.memoryUsage.length;

    return {
      usedJSHeapSize: totalUsed / count,
      totalJSHeapSize: totalSize / count,
      jsHeapSizeLimit: totalLimit / count,
    };
  }

  /**
   * Calculate unused CSS percentage
   */
  calculateUnusedCssPercentage() {
    if (
      !this.testResults.cssAnalysis ||
      !this.testResults.cssAnalysis.totalRules
    ) {
      return 0;
    }

    return (
      (this.testResults.cssAnalysis.unusedRules /
        this.testResults.cssAnalysis.totalRules) *
      100
    ).toFixed(2);
  }

  /**
   * Show a message in the results target
   */
  showMessage(message) {
    if (this.hasResultsTarget) {
      this.resultsTarget.innerHTML = `
        <div class="p-4 bg-container border border-secondary rounded-lg">
          <p>${message}</p>
        </div>
      `;
    }
  }
}
