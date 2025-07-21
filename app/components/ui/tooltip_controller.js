import { Controller } from "@hotwired/stimulus"

// Tooltip controller for showing/hiding tooltips
export default class extends Controller {
  static targets = ["tooltip", "content"]
  static values = {
    delayShow: { type: Number, default: 300 },
    delayHide: { type: Number, default: 100 }
  }

  connect() {
    this.showTimeout = null
    this.hideTimeout = null
    
    this.contentTarget.addEventListener("mouseenter", this.scheduleShow.bind(this))
    this.contentTarget.addEventListener("mouseleave", this.scheduleHide.bind(this))
    this.contentTarget.addEventListener("focus", this.show.bind(this))
    this.contentTarget.addEventListener("blur", this.hide.bind(this))
  }

  disconnect() {
    this.clearTimeouts()
    
    this.contentTarget.removeEventListener("mouseenter", this.scheduleShow.bind(this))
    this.contentTarget.removeEventListener("mouseleave", this.scheduleHide.bind(this))
    this.contentTarget.removeEventListener("focus", this.show.bind(this))
    this.contentTarget.removeEventListener("blur", this.hide.bind(this))
  }

  scheduleShow() {
    this.clearTimeouts()
    this.showTimeout = setTimeout(this.show.bind(this), this.delayShowValue)
  }

  scheduleHide() {
    this.clearTimeouts()
    this.hideTimeout = setTimeout(this.hide.bind(this), this.delayHideValue)
  }

  show() {
    this.tooltipTarget.classList.remove("opacity-0")
    this.tooltipTarget.classList.add("opacity-100")
  }

  hide() {
    this.tooltipTarget.classList.remove("opacity-100")
    this.tooltipTarget.classList.add("opacity-0")
  }

  clearTimeouts() {
    if (this.showTimeout) clearTimeout(this.showTimeout)
    if (this.hideTimeout) clearTimeout(this.hideTimeout)
  }
}