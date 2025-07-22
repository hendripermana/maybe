import { Controller } from "@hotwired/stimulus"

// This controller handles browser-specific compatibility issues
export default class extends Controller {
  connect() {
    this.detectBrowser()
    this.applyBrowserSpecificFixes()
  }
  
  detectBrowser() {
    // Use feature detection instead of user agent when possible
    this.isWebkit = 'WebkitAppearance' in document.documentElement.style
    this.isFirefox = typeof InstallTrigger !== 'undefined'
    this.isEdge = /Edg/.test(navigator.userAgent)
    this.isSafari = /^((?!chrome|android).)*safari/i.test(navigator.userAgent)
    
    // Add browser class to html element for CSS targeting if absolutely necessary
    if (this.isWebkit) document.documentElement.classList.add('webkit-browser')
    if (this.isFirefox) document.documentElement.classList.add('firefox-browser')
    if (this.isEdge) document.documentElement.classList.add('edge-browser')
    if (this.isSafari) document.documentElement.classList.add('safari-browser')
  }
  
  applyBrowserSpecificFixes() {
    this.fixFlexGapSupport()
    this.fixSafariThemeTransitions()
    this.fixEdgeCustomProperties()
    this.fixFocusRingStyles()
  }
  
  // Fix for browsers that don't support gap in flexbox
  fixFlexGapSupport() {
    // Feature detection for flexbox gap support
    const hasFlexGap = () => {
      // Create test elements
      const flex = document.createElement("div")
      flex.style.display = "flex"
      flex.style.flexDirection = "column"
      flex.style.gap = "1px"
      
      // Append to the DOM to check computed style
      document.body.appendChild(flex)
      const hasGap = getComputedStyle(flex).gap === "1px"
      document.body.removeChild(flex)
      
      return hasGap
    }
    
    // If gap is not supported, add a class to the document for alternative styling
    if (!hasFlexGap()) {
      document.documentElement.classList.add('no-flex-gap')
    }
  }
  
  // Fix Safari theme transition flickering
  fixSafariThemeTransitions() {
    if (this.isSafari) {
      // Add specific optimizations for Safari theme transitions
      document.querySelectorAll('[data-theme-transition]').forEach(el => {
        el.style.webkitBackfaceVisibility = 'hidden'
      })
      
      // Apply additional fixes for Safari theme transition flickering
      const themeToggle = document.querySelector('[data-action*="theme#toggle"]')
      if (themeToggle) {
        // Use requestAnimationFrame to smooth transitions
        themeToggle.addEventListener('click', () => {
          // Add a class that temporarily disables animations
          document.documentElement.classList.add('theme-changing')
          
          // Use requestAnimationFrame to ensure smooth transition
          requestAnimationFrame(() => {
            requestAnimationFrame(() => {
              // Remove the class after the theme has changed
              document.documentElement.classList.remove('theme-changing')
            })
          })
        })
      }
      
      // Add specific styles for Safari
      const style = document.createElement('style')
      style.textContent = `
        @media not all and (min-resolution:.001dpcm) {
          @supports (-webkit-appearance:none) {
            .theme-changing * {
              transition: none !important;
            }
            
            /* Improve Safari rendering performance during theme changes */
            [data-theme] {
              transform: translateZ(0);
            }
          }
        }
      `
      document.head.appendChild(style)
    }
  }
  
  // Fix Edge custom properties issues
  fixEdgeCustomProperties() {
    if (this.isEdge) {
      // Check if CSS.registerProperty is supported
      if (typeof CSS !== 'undefined' && CSS.registerProperty) {
        try {
          // Register custom properties for better Edge support
          CSS.registerProperty({
            name: '--color-background',
            syntax: '<color>',
            inherits: true,
            initialValue: '#ffffff'
          })
          
          CSS.registerProperty({
            name: '--color-foreground',
            syntax: '<color>',
            inherits: true,
            initialValue: '#000000'
          })
        } catch (e) {
          console.warn('CSS Custom Properties registration not fully supported')
        }
      }
    }
  }
  
  // Ensure consistent focus styles across browsers
  fixFocusRingStyles() {
    // Check if :focus-visible is supported
    const supportsFocusVisible = CSS.supports('selector(:focus-visible)')
    
    if (!supportsFocusVisible) {
      // Add polyfill behavior for :focus-visible
      document.addEventListener('keydown', e => {
        if (e.key === 'Tab') {
          document.documentElement.classList.add('keyboard-focus-mode')
        }
      })
      
      document.addEventListener('mousedown', () => {
        document.documentElement.classList.remove('keyboard-focus-mode')
      })
    }
  }
}