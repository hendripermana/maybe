// app/javascript/controllers/css_optimizer_controller.js
import { Controller } from "@hotwired/stimulus"
import { cssPurge } from "../services/css_purge"

/**
 * CSS Optimizer Controller
 * 
 * This controller integrates with the CssPurge service to analyze and optimize
 * CSS usage on the page.
 * 
 * Usage:
 * <div data-controller="css-optimizer" 
 *      data-css-optimizer-auto-analyze-value="true"
 *      data-css-optimizer-remove-unused-value="false">
 *   <!-- Page content -->
 * </div>
 */
export default class extends Controller {
  static values = { 
    autoAnalyze: { type: Boolean, default: false },
    removeUnused: { type: Boolean, default: false },
    preservePrefixes: { type: Array, default: ['tw-', 'js-'] },
    delay: { type: Number, default: 1000 }
  }

  connect() {
    // Initialize the CSS purge service with options
    this.cssPurge = cssPurge
    
    // Run analysis automatically if enabled
    if (this.autoAnalyzeValue) {
      // Wait for the page to fully load and render
      window.addEventListener('load', () => {
        // Add a small delay to ensure dynamic content is loaded
        setTimeout(() => {
          this.analyze()
        }, this.delayValue)
      })
    }
  }
  
  /**
   * Analyze CSS usage on the page
   */
  analyze() {
    // Configure the CSS purge service
    this.cssPurge.options = {
      removeUnused: this.removeUnusedValue,
      preservePrefixes: this.preservePrefixesValue
    }
    
    // Run the analysis
    const results = this.cssPurge.analyze()
    
    // Dispatch event with results
    this.dispatch('analyzed', { 
      detail: { 
        stats: this.cssPurge.getStats(),
        unusedRules: results.unusedRules.slice(0, 100) // Limit to 100 rules for event payload
      }
    })
    
    // Log results to console
    console.log('CSS Optimization Results:', this.cssPurge.getStats())
    
    return results
  }
  
  /**
   * Remove unused CSS rules
   */
  removeUnused() {
    // Set option to remove unused rules
    this.cssPurge.options.removeUnused = true
    
    // Run the analysis which will also remove unused rules
    const results = this.cssPurge.analyze()
    
    // Dispatch event with results
    this.dispatch('optimized', { 
      detail: { 
        stats: this.cssPurge.getStats(),
        removedRules: results.unusedRules.slice(0, 100) // Limit to 100 rules for event payload
      }
    })
    
    return results
  }
  
  /**
   * Get statistics about CSS usage
   */
  getStats() {
    return this.cssPurge.getStats()
  }
}