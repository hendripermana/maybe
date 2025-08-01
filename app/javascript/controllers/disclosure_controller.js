import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="disclosure"
export default class extends Controller {
  static targets = ["content", "chevron"];

  connect() {
    // Check if the content should be open by default
    const shouldBeOpen = this.element.hasAttribute("data-disclosure-open");

    if (shouldBeOpen) {
      this.show();
    } else {
      this.hide();
    }
  }

  toggle() {
    if (this.isHidden()) {
      this.show();
    } else {
      this.hide();
    }
  }

  show() {
    if (this.hasContentTarget) {
      this.contentTarget.classList.remove("hidden");
    }

    if (this.hasChevronTarget) {
      this.chevronTarget.classList.add("rotate-180");
    }
  }

  hide() {
    if (this.hasContentTarget) {
      this.contentTarget.classList.add("hidden");
    }

    if (this.hasChevronTarget) {
      this.chevronTarget.classList.remove("rotate-180");
    }
  }

  isHidden() {
    return (
      this.hasContentTarget && this.contentTarget.classList.contains("hidden")
    );
  }
}
