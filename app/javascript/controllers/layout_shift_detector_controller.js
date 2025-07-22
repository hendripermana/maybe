import { Controller } from "@hotwired/stimulus"

// This controller detects and reports layout shifts
export default class extends Controller {
  static targets = ["container"]
  
  connect() {
    this.observeLayoutShifts()
    this.preventImageShifts()
    this.addSkeletonLoaders()
  }
  
  observeLayoutShifts() {
    // Use Layout Instability API if available
    if ("LayoutShift" in window) {
      let cumulativeLayoutShift = 0
      
      const observer = new PerformanceObserver((list) => {
        for (const entry of list.getEntries()) {
          // Only count layout shifts without recent user input
          if (!entry.hadRecentInput) {
            cumulativeLayoutShift += entry.value
            
            // Log significant layout shifts
            if (entry.value > 0.05) {
              console.warn("Significant layout shift detected:", entry)
              
              // Highlight affected elements in development
              if (process.env.NODE_ENV === "development") {
                this.highlightShiftedElements(entry)
              }
            }
          }
        }
      })
      
      observer.observe({ type: "layout-shift", buffered: true })
    }
  }
  
  preventImageShifts() {
    // Add explicit dimensions to images without them
    document.querySelectorAll("img:not([width]):not([height])").forEach(img => {
      img.setAttribute("loading", "lazy")
      
      // Set a default aspect ratio if dimensions are unknown
      if (!img.style.aspectRatio) {
        img.style.aspectRatio = "16/9"
      }
    })
  }
  
  addSkeletonLoaders() {
    // Add skeleton loaders to containers that will load content
    if (this.hasContainerTarget) {
      const containers = this.containerTargets
      
      containers.forEach(container => {
        // Only add skeleton if container is empty or has loading attribute
        if (container.children.length === 0 || container.hasAttribute("data-loading")) {
          this.addSkeletonToContainer(container)
        }
      })
    }
  }
  
  highlightShiftedElements(entry) {
    // Highlight elements that caused layout shifts
    entry.sources.forEach(source => {
      const element = source.node
      
      if (element) {
        // Add temporary highlight
        const originalBackground = element.style.background
        const originalOutline = element.style.outline
        
        element.style.background = "rgba(255, 0, 0, 0.2)"
        element.style.outline = "2px solid red"
        
        // Remove highlight after 3 seconds
        setTimeout(() => {
          element.style.background = originalBackground
          element.style.outline = originalOutline
        }, 3000)
      }
    })
  }
  
  addSkeletonToContainer(container) {
    // Create skeleton loader based on container type
    const type = container.dataset.skeletonType || "default"
    const count = parseInt(container.dataset.skeletonCount || "1", 10)
    
    for (let i = 0; i < count; i++) {
      const skeleton = this.createSkeleton(type)
      container.appendChild(skeleton)
    }
  }
  
  createSkeleton(type) {
    const skeleton = document.createElement("div")
    skeleton.classList.add("skeleton-loader")
    
    switch (type) {
      case "card":
        skeleton.style.height = "120px"
        skeleton.style.borderRadius = "var(--radius-md)"
        break
      case "text":
        skeleton.style.height = "1em"
        skeleton.style.marginBottom = "0.5em"
        skeleton.style.width = `${Math.floor(Math.random() * 50) + 50}%`
        break
      case "image":
        skeleton.style.height = "200px"
        skeleton.style.borderRadius = "var(--radius-md)"
        break
      default:
        skeleton.style.height = "40px"
        skeleton.style.borderRadius = "var(--radius-sm)"
    }
    
    return skeleton
  }
}