import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["trigger"]
  static values = { default: String }

  connect() {
    if (this.defaultValue) {
      this.select(this.defaultValue)
    } else if (this.triggerTargets.length > 0) {
      this.select(this.triggerTargets[0].dataset.shadcnTabsValue)
    }
  }

  select(value) {
    // Update trigger states
    this.triggerTargets.forEach(trigger => {
      if (trigger.dataset.shadcnTabsValue === value) {
        trigger.setAttribute("data-state", "active")
        trigger.setAttribute("aria-selected", "true")
      } else {
        trigger.setAttribute("data-state", "inactive")
        trigger.setAttribute("aria-selected", "false")
      }
    })

    // Dispatch custom event for content switching
    this.dispatch("tabSelected", { detail: { value } })
  }
} 