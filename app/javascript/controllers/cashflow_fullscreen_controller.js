import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="cashflow-fullscreen"
export default class extends Controller {
  static targets = [
    "container",
    "toggleButton", 
    "expandIcon",
    "collapseIcon",
    "chartContainer",
    "regularContainer",
    "fullscreenOverlay",
    "fullscreenContainer"
  ];

  connect() {
    console.log("🖼️ Fullscreen controller connected!");
    console.log("Element:", this.element);
    console.log("Element tag:", this.element.tagName);
    console.log("Element classes:", this.element.className);
    console.log("Targets found:", {
      fullscreenOverlay: this.hasFullscreenOverlayTarget,
      toggleButton: this.hasToggleButtonTarget,
      chartContainer: this.hasChartContainerTarget,
      expandIcon: this.hasExpandIconTarget,
      collapseIcon: this.hasCollapseIconTarget
    });
    
    if (this.hasFullscreenOverlayTarget) {
      console.log("✅ Fullscreen overlay target found:", this.fullscreenOverlayTarget);
      console.log("Overlay classes:", this.fullscreenOverlayTarget.className);
    } else {
      console.warn("❌ Fullscreen overlay target NOT found");
      console.log("Available targets in element:", this.element.querySelectorAll('[data-cashflow-fullscreen-target]'));
    }
    
    if (this.hasToggleButtonTarget) {
      console.log("✅ Toggle button found:", this.toggleButtonTarget);
    } else {
      console.warn("❌ Toggle button NOT found");
    }
    
    // Listen for escape key to exit fullscreen
    this.handleEscapeKey = this.handleEscapeKey.bind(this);
    document.addEventListener('keydown', this.handleEscapeKey);
    
    // Store original overflow style
    this.originalBodyOverflow = document.body.style.overflow;

    // Restore fullscreen state if it was active before Turbo Frame update
    if (window.sessionStorage.getItem('maybe-cashflow-fullscreen') === 'true') {
      setTimeout(() => {
        this.enterFullscreen();
      }, 50);
    }
  }

  disconnect() {
    document.removeEventListener('keydown', this.handleEscapeKey);
    // Restore body overflow if we're disconnecting while in fullscreen
    if (this.isFullscreen) {
      document.body.style.overflow = this.originalBodyOverflow;
    }
  }

  get isFullscreen() {
    if (!this.hasFullscreenOverlayTarget) {
      console.warn("No fullscreenOverlay target found for isFullscreen check");
      return false;
    }
    const isHidden = this.fullscreenOverlayTarget.classList.contains('hidden');
    const currentState = !isHidden;
    console.log("🔍 Checking fullscreen state - hidden class:", isHidden, "isFullscreen:", currentState);
    return currentState;
  }

  toggleFullscreen(event) {
    // Prevent event bubbling to avoid double-triggering
    if (event) {
      event.preventDefault();
      event.stopPropagation();
    }
    
    console.log("🔄 Toggle fullscreen clicked! Current state:", this.isFullscreen);
    console.log("Has targets:", {
      fullscreenOverlay: this.hasFullscreenOverlayTarget,
      toggleButton: this.hasToggleButtonTarget,
      chartContainer: this.hasChartContainerTarget
    });
    
    if (!this.hasFullscreenOverlayTarget) {
      console.error("❌ Cannot toggle fullscreen: missing fullscreenOverlay target");
      return;
    }
    
    // Add a small delay to prevent double-click issues
    if (this.toggleInProgress) {
      console.log("⏳ Toggle already in progress, ignoring...");
      return;
    }
    
    this.toggleInProgress = true;
    
    // Check state at the moment of click
    const currentlyFullscreen = this.isFullscreen;
    console.log("🎯 Action decision - currently fullscreen:", currentlyFullscreen);
    
    if (currentlyFullscreen) {
      console.log("➡️ Exiting fullscreen...");
      this.exitFullscreen();
    } else {
      console.log("➡️ Entering fullscreen...");
      this.enterFullscreen();
    }
    
    // Reset the flag after a delay
    setTimeout(() => {
      this.toggleInProgress = false;
    }, 500);
  }

  enterFullscreen() {
    if (!this.hasFullscreenOverlayTarget) {
      console.error("❌ Cannot enter fullscreen: missing fullscreenOverlay target");
      return;
    }
    
    // Persist fullscreen state
    window.sessionStorage.setItem('maybe-cashflow-fullscreen', 'true');

    // Hide regular container and show fullscreen overlay
    this.fullscreenOverlayTarget.classList.remove('hidden');
    
    // Update icons if available
    if (this.hasExpandIconTarget) this.expandIconTarget.classList.add('hidden');
    if (this.hasCollapseIconTarget) this.collapseIconTarget.classList.remove('hidden');
    
    // Add body classes to prevent scrolling and ensure proper sizing
    document.body.classList.add('fullscreen-active');
    document.documentElement.classList.add('fullscreen-active');
    document.body.style.overflow = 'hidden';
    document.documentElement.style.overflow = 'hidden';
    
    // Trigger resize event for charts to redraw in new dimensions
    setTimeout(() => {
      window.dispatchEvent(new Event('resize'));
      // Also trigger any chart controllers to redraw
      this.triggerChartRedraw();
    }, 100);
    
    // Add animation class for smooth transition
    this.fullscreenOverlayTarget.style.opacity = '0';
    this.fullscreenOverlayTarget.style.transform = 'scale(0.95)';
    
    setTimeout(() => {
      this.fullscreenOverlayTarget.style.transition = 'opacity 0.2s ease-out, transform 0.2s ease-out';
      this.fullscreenOverlayTarget.style.opacity = '1';
      this.fullscreenOverlayTarget.style.transform = 'scale(1)';
    }, 10);
    
    console.log("✅ Entered fullscreen mode");
  }

  exitFullscreen() {
    if (!this.hasFullscreenOverlayTarget) {
      console.error("❌ Cannot exit fullscreen: missing fullscreenOverlay target");
      return;
    }
    
    // Remove fullscreen state
    window.sessionStorage.removeItem('maybe-cashflow-fullscreen');

    // Animate out
    this.fullscreenOverlayTarget.style.transition = 'opacity 0.15s ease-in, transform 0.15s ease-in';
    this.fullscreenOverlayTarget.style.opacity = '0';
    this.fullscreenOverlayTarget.style.transform = 'scale(0.95)';
    
    setTimeout(() => {
      // Hide fullscreen overlay and show regular container
      this.fullscreenOverlayTarget.classList.add('hidden');
      
      // Update icons if available
      if (this.hasExpandIconTarget) this.expandIconTarget.classList.remove('hidden');
      if (this.hasCollapseIconTarget) this.collapseIconTarget.classList.add('hidden');
      
      // Remove body classes and restore scrolling
      document.body.classList.remove('fullscreen-active');
      document.documentElement.classList.remove('fullscreen-active');
      document.body.style.overflow = this.originalBodyOverflow;
      document.documentElement.style.overflow = '';
      
      // Reset styles
      this.fullscreenOverlayTarget.style.transition = '';
      this.fullscreenOverlayTarget.style.opacity = '';
      this.fullscreenOverlayTarget.style.transform = '';
      
      // Trigger resize event for charts to redraw in regular dimensions
      setTimeout(() => {
        window.dispatchEvent(new Event('resize'));
        this.triggerChartRedraw();
      }, 50);
    }, 150);
    
    console.log("✅ Exited fullscreen mode");
  }

  handleEscapeKey(event) {
    if (event.key === 'Escape' && this.isFullscreen) {
      event.preventDefault();
      this.exitFullscreen();
    }
  }

  triggerChartRedraw() {
    // Find all sankey chart controllers and trigger a redraw
    const chartElements = this.element.querySelectorAll('[data-controller*="sankey-chart"]');
    chartElements.forEach(element => {
      try {
        const controller = this.application.getControllerForElementAndIdentifier(element, 'sankey-chart');
        if (controller && typeof controller.redraw === 'function') {
          controller.redraw();
        }
      } catch (error) {
        console.warn('Could not trigger redraw for sankey chart:', error);
      }
    });
  }
}
