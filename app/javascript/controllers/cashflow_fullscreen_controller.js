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
    // Listen for escape key to exit fullscreen
    this.handleEscapeKey = this.handleEscapeKey.bind(this);
    document.addEventListener('keydown', this.handleEscapeKey);
    
    // Store original overflow style
    this.originalBodyOverflow = document.body.style.overflow;
  }

  disconnect() {
    document.removeEventListener('keydown', this.handleEscapeKey);
    // Restore body overflow if we're disconnecting while in fullscreen
    if (this.isFullscreen) {
      document.body.style.overflow = this.originalBodyOverflow;
    }
  }

  get isFullscreen() {
    return !this.fullscreenOverlayTarget.classList.contains('hidden');
  }

  toggleFullscreen() {
    if (this.isFullscreen) {
      this.exitFullscreen();
    } else {
      this.enterFullscreen();
    }
  }

  enterFullscreen() {
    // Hide regular container and show fullscreen overlay
    this.fullscreenOverlayTarget.classList.remove('hidden');
    
    // Update icons
    this.expandIconTarget.classList.add('hidden');
    this.collapseIconTarget.classList.remove('hidden');
    
    // Prevent body scrolling
    document.body.style.overflow = 'hidden';
    
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
  }

  exitFullscreen() {
    // Animate out
    this.fullscreenOverlayTarget.style.transition = 'opacity 0.15s ease-in, transform 0.15s ease-in';
    this.fullscreenOverlayTarget.style.opacity = '0';
    this.fullscreenOverlayTarget.style.transform = 'scale(0.95)';
    
    setTimeout(() => {
      // Hide fullscreen overlay and show regular container
      this.fullscreenOverlayTarget.classList.add('hidden');
      
      // Update icons
      this.expandIconTarget.classList.remove('hidden');
      this.collapseIconTarget.classList.add('hidden');
      
      // Restore body scrolling
      document.body.style.overflow = this.originalBodyOverflow;
      
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
  }

  handleEscapeKey(event) {
    if (event.key === 'Escape' && this.isFullscreen) {
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
