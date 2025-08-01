import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="transaction-list"
export default class extends Controller {
  static targets = ["container", "loading"];

  connect() {
    this.setupLoadingState();
  }

  setupLoadingState() {
    // Show loading state when navigating between pages
    document.addEventListener("turbo:before-fetch-request", () => {
      if (this.hasLoadingTarget && this.hasContainerTarget) {
        this.loadingTarget.classList.remove("hidden");
        this.containerTarget.classList.add("opacity-50");
      }
    });

    document.addEventListener("turbo:before-fetch-response", () => {
      if (this.hasLoadingTarget && this.hasContainerTarget) {
        this.loadingTarget.classList.add("hidden");
        this.containerTarget.classList.remove("opacity-50");
      }
    });
  }
}
