import { Controller } from "@hotwired/stimulus";

/**
 * Dismissible Controller
 *
 * Controls the behavior of dismissible elements like alerts and notifications
 */
export default class extends Controller {
  connect() {
    // Add any initialization if needed
  }

  dismiss() {
    // Add fade out animation
    this.element.classList.add("animate-fadeOut");

    // Remove element after animation completes
    setTimeout(() => {
      this.element.remove();
    }, 300);
  }
}

// Add this to the stylesheet
document.head.insertAdjacentHTML(
  "beforeend",
  `
  <style>
    @keyframes fadeOut {
      from { opacity: 1; transform: translateY(0); }
      to { opacity: 0; transform: translateY(-10px); }
    }
    
    .animate-fadeOut {
      animation: fadeOut 0.3s ease-out forwards;
    }
  </style>
`,
);
