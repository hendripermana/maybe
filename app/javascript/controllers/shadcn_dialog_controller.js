import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["overlay", "dialog"]

  connect() {
    this.close()
  }

  open() {
    this.overlayTarget.setAttribute("data-state", "open")
    this.dialogTarget.setAttribute("data-state", "open")
    document.body.style.overflow = "hidden"
  }

  close() {
    this.overlayTarget.setAttribute("data-state", "closed")
    this.dialogTarget.setAttribute("data-state", "closed")
    document.body.style.overflow = ""
  }

  disconnect() {
    document.body.style.overflow = ""
  }
} 