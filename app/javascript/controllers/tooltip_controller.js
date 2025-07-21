import { Controller } from "@hotwired/stimulus"

/**
 * Tooltip Controller
 * 
 * Controls the behavior of tooltips
 */
export default class extends Controller {
  static targets = ["tooltip"]
  
  connect() {
    // Hide tooltip initially
    this.hideTooltip()
    
    // Add event listeners
    this.element.addEventListener("mouseenter", this.showTooltip.bind(this))
    this.element.addEventListener("mouseleave", this.hideTooltip.bind(this))
    this.element.addEventListener("focus", this.showTooltip.bind(this))
    this.element.addEventListener("blur", this.hideTooltip.bind(this))
  }
  
  disconnect() {
    // Remove event listeners
    this.element.removeEventListener("mouseenter", this.showTooltip.bind(this))
    this.element.removeEventListener("mouseleave", this.hideTooltip.bind(this))
    this.element.removeEventListener("focus", this.showTooltip.bind(this))
    this.element.removeEventListener("blur", this.hideTooltip.bind(this))
  }
  
  showTooltip() {
    this.tooltipTarget.classList.remove("opacity-0", "invisible")
    this.tooltipTarget.classList.add("opacity-100", "visible")
    
    // Position the tooltip
    this.positionTooltip()
  }
  
  hideTooltip() {
    this.tooltipTarget.classList.add("opacity-0", "invisible")
    this.tooltipTarget.classList.remove("opacity-100", "visible")
  }
  
  positionTooltip() {
    // Default position is bottom
    const tooltipRect = this.tooltipTarget.getBoundingClientRect()
    const elementRect = this.element.getBoundingClientRect()
    
    // Position tooltip centered above the element
    this.tooltipTarget.style.bottom = `${elementRect.height + 8}px`
    this.tooltipTarget.style.left = `${(elementRect.width - tooltipRect.width) / 2}px`
    
    // Check if tooltip is off-screen and adjust if needed
    const tooltipLeft = elementRect.left + (elementRect.width - tooltipRect.width) / 2
    const tooltipRight = tooltipLeft + tooltipRect.width
    
    if (tooltipLeft < 0) {
      this.tooltipTarget.style.left = `-${elementRect.left - 8}px`
    } else if (tooltipRight > window.innerWidth) {
      this.tooltipTarget.style.left = `${elementRect.width - tooltipRect.width - (tooltipRight - window.innerWidth) - 8}px`
    }
  }
}