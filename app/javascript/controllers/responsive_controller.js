import { Controller } from "@hotwired/stimulus";

// This controller handles responsive behavior and orientation changes
export default class extends Controller {
  static targets = ["mobileMenu", "desktopMenu", "content", "sidebar"];

  static values = {
    breakpoint: { type: Number, default: 1024 }, // Desktop breakpoint in pixels
    currentOrientation: String,
  };

  connect() {
    // Set initial state
    this.checkViewportSize();
    this.detectOrientation();

    // Add event listeners
    this.resizeObserver = new ResizeObserver((entries) => {
      this.checkViewportSize();
    });

    this.resizeObserver.observe(document.documentElement);

    // Listen for orientation changes
    window.addEventListener(
      "orientationchange",
      this.handleOrientationChange.bind(this),
    );

    // Fallback for browsers that don't support orientationchange
    window.addEventListener("resize", this.detectOrientation.bind(this));
  }

  disconnect() {
    // Clean up event listeners
    if (this.resizeObserver) {
      this.resizeObserver.disconnect();
    }

    window.removeEventListener(
      "orientationchange",
      this.handleOrientationChange.bind(this),
    );
    window.removeEventListener("resize", this.detectOrientation.bind(this));
  }

  checkViewportSize() {
    const isMobile = window.innerWidth < this.breakpointValue;

    // Toggle mobile/desktop UI elements
    if (this.hasMobileMenuTarget && this.hasDesktopMenuTarget) {
      this.mobileMenuTarget.classList.toggle("hidden", !isMobile);
      this.desktopMenuTarget.classList.toggle("hidden", isMobile);
    }

    // Add appropriate class to the body
    document.body.classList.toggle("is-mobile", isMobile);
    document.body.classList.toggle("is-desktop", !isMobile);

    // Dispatch custom event for other components to respond
    window.dispatchEvent(
      new CustomEvent("viewport-changed", {
        detail: {
          isMobile,
          width: window.innerWidth,
          height: window.innerHeight,
        },
      }),
    );
  }

  detectOrientation() {
    const isLandscape = window.innerWidth > window.innerHeight;
    const orientation = isLandscape ? "landscape" : "portrait";

    // Only update if orientation has changed
    if (this.currentOrientationValue !== orientation) {
      this.currentOrientationValue = orientation;

      // Add appropriate class to the body
      document.body.classList.toggle("is-landscape", isLandscape);
      document.body.classList.toggle("is-portrait", !isLandscape);

      // Optimize layout for orientation
      this.optimizeForOrientation(orientation);
    }
  }

  handleOrientationChange() {
    // Small delay to ensure dimensions have updated
    setTimeout(() => {
      this.detectOrientation();
    }, 100);
  }

  optimizeForOrientation(orientation) {
    // Skip if we don't have the required targets
    if (!this.hasContentTarget || !this.hasSidebarTarget) return;

    const isMobile = window.innerWidth < this.breakpointValue;

    if (isMobile && orientation === "landscape") {
      // Mobile landscape optimizations
      this.element.classList.add("landscape-optimized");
      this.sidebarTarget.classList.add("landscape-sidebar");
      this.contentTarget.classList.add("landscape-content");
    } else {
      // Reset to default layout
      this.element.classList.remove("landscape-optimized");
      this.sidebarTarget.classList.remove("landscape-sidebar");
      this.contentTarget.classList.remove("landscape-content");
    }

    // Dispatch custom event for other components to respond
    window.dispatchEvent(
      new CustomEvent("orientation-changed", {
        detail: { orientation, isMobile },
      }),
    );
  }

  // Action to toggle mobile menu
  toggleMobileMenu(event) {
    if (!this.hasMobileMenuTarget) return;

    const isVisible = !this.mobileMenuTarget.classList.contains("hidden");
    this.mobileMenuTarget.classList.toggle("hidden", isVisible);

    // Update aria attributes
    if (event.currentTarget.hasAttribute("aria-expanded")) {
      event.currentTarget.setAttribute("aria-expanded", !isVisible);
    }
  }
}
