// cashflow_filter_controller.js
// This controller intercepts the filter form in fullscreen Sankey modal.
// It fetches new chart data via AJAX and updates the chart directly, without closing/reopening the modal.
// If not in fullscreen, it allows normal Turbo/Turbo Frame behavior.

import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["form", "select"];

  connect() {
    // No-op
  }

  submit(event) {
    // Only intercept if we're in fullscreen mode
    const fullscreenOverlay = document.querySelector('.fullscreen-overlay');
    if (!fullscreenOverlay || fullscreenOverlay.classList.contains('hidden')) {
      // Not in fullscreen, allow normal Turbo behavior
      return;
    }
    event.preventDefault();
    event.stopPropagation();

    // Find the form and get the selected value
    const form = this.formTarget;
    const url = form.action;
    const formData = new FormData(form);
    const params = new URLSearchParams(formData).toString();

    // Show loading state (optional)
    const chartContainer = fullscreenOverlay.querySelector('[data-controller="sankey-chart"]');
    if (chartContainer) {
      chartContainer.classList.add('opacity-50');
    }

    // Fetch new data via AJAX (expects JSON response)
    fetch(url + '?' + params, {
      headers: { 'Accept': 'application/json' }
    })
      .then(response => response.json())
      .then(data => {
        // Update the chart via the sankey-chart controller
        if (chartContainer) {
          const controller = this.application.getControllerForElementAndIdentifier(chartContainer, 'sankey-chart');
          if (controller && typeof controller.updateData === 'function') {
            controller.updateData(data);
          } else {
            // fallback: reload the page if controller not found
            window.location.reload();
          }
        }
      })
      .catch(() => window.location.reload())
      .finally(() => {
        if (chartContainer) {
          chartContainer.classList.remove('opacity-50');
        }
      });
  }
} 