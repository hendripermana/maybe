import { Controller } from "@hotwired/stimulus";
import UiMonitoringService from "../services/ui_monitoring_service";

// Monitors component rendering and interactions
export default class extends Controller {
  static values = {
    name: String,
    critical: Boolean,
  };

  connect() {
    this.setupErrorHandling();

    // Log component render for critical components
    if (this.criticalValue) {
      UiMonitoringService.logEvent("critical_component_rendered", {
        component:
          this.nameValue || this.element.dataset.component || "unknown",
        path: window.location.pathname,
      });
    }
  }

  setupErrorHandling() {
    // Add error boundary to component
    this.element.addEventListener("error", this.handleError.bind(this), true);

    // Monitor for specific component interactions if this is a critical component
    if (this.criticalValue) {
      this.element.addEventListener(
        "click",
        this.handleInteraction.bind(this),
        true,
      );
      this.element.addEventListener(
        "change",
        this.handleInteraction.bind(this),
        true,
      );
    }
  }

  handleError(event) {
    const componentName =
      this.nameValue || this.element.dataset.component || "unknown";

    UiMonitoringService.reportError("component_runtime_error", event.error, {
      componentName,
      elementId: this.element.id,
      elementClasses: this.element.className,
      eventType: event.type,
    });

    // Prevent the error from bubbling up if possible
    event.stopPropagation();
  }

  handleInteraction(event) {
    const componentName =
      this.nameValue || this.element.dataset.component || "unknown";
    const interactionType = event.type;
    const targetElement = event.target.tagName;

    UiMonitoringService.logEvent("critical_component_interaction", {
      componentName,
      interactionType,
      targetElement,
      targetId: event.target.id || "none",
      targetClasses: event.target.className || "none",
    });
  }

  disconnect() {
    // Clean up event listeners if needed
  }
}
