import { Controller } from "@hotwired/stimulus"

// Controls the settings navigation tabs on mobile
export default class extends Controller {
  static targets = ["tab", "panel"]

  connect() {
    // Select the first tab by default
    if (this.tabTargets.length > 0) {
      this.select({ currentTarget: this.tabTargets[0] })
    }
  }

  select(event) {
    const selectedTab = event.currentTarget
    const index = selectedTab.dataset.index

    // Update tab states
    this.tabTargets.forEach(tab => {
      const isSelected = tab.dataset.index === index
      tab.classList.remove(tab.dataset.selectedClass, tab.dataset.unselectedClass)
      tab.classList.add(isSelected ? tab.dataset.selectedClass : tab.dataset.unselectedClass)
      tab.setAttribute("aria-selected", isSelected)
    })

    // Update panel states
    this.panelTargets.forEach(panel => {
      const isSelected = panel.dataset.index === index
      panel.classList.remove(panel.dataset.selectedClass, panel.dataset.unselectedClass)
      panel.classList.add(isSelected ? panel.dataset.selectedClass : panel.dataset.unselectedClass)
      panel.setAttribute("aria-hidden", !isSelected)
    })
  }
}