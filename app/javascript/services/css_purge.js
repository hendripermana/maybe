// app/javascript/services/css_purge.js

/**
 * CSS Purge Service
 *
 * This service analyzes the DOM to identify and optionally remove unused CSS rules.
 * It can be used to dynamically optimize CSS bundle size at runtime.
 */
export default class CssPurge {
  constructor(options = {}) {
    this.options = {
      removeUnused: false,
      preservePrefixes: ["tw-", "js-"],
      preserveMediaQueries: true,
      preserveKeyframes: true,
      ...options,
    };

    this.stats = {
      totalRules: 0,
      unusedRules: 0,
      removedRules: 0,
      preservedRules: 0,
    };
  }

  /**
   * Analyze all stylesheets to find unused CSS rules
   * @returns {Object} Statistics about unused CSS rules
   */
  analyze() {
    this.stats = {
      totalRules: 0,
      unusedRules: 0,
      removedRules: 0,
      preservedRules: 0,
    };

    const unusedRules = [];

    // Process each stylesheet
    Array.from(document.styleSheets).forEach((sheet) => {
      try {
        // Skip external stylesheets (CORS restrictions)
        if (
          sheet.href &&
          sheet.href.startsWith("http") &&
          !sheet.href.startsWith(window.location.origin)
        ) {
          return;
        }

        this.processStylesheet(sheet, unusedRules);
      } catch (e) {
        console.warn("Could not process stylesheet", e);
      }
    });

    return {
      ...this.stats,
      unusedRules,
    };
  }

  /**
   * Process a single stylesheet to find unused rules
   * @param {CSSStyleSheet} sheet - The stylesheet to process
   * @param {Array} unusedRules - Array to collect unused rules
   */
  processStylesheet(sheet, unusedRules) {
    try {
      const rules = Array.from(sheet.cssRules || []);

      this.stats.totalRules += rules.length;

      rules.forEach((rule, index) => {
        // Handle different rule types
        if (rule.type === CSSRule.STYLE_RULE) {
          this.processStyleRule(rule, sheet, index, unusedRules);
        } else if (rule.type === CSSRule.MEDIA_RULE) {
          if (this.options.preserveMediaQueries) {
            this.stats.preservedRules++;
          } else {
            // Process rules inside media queries
            Array.from(rule.cssRules).forEach((mediaRule, mediaIndex) => {
              if (mediaRule.type === CSSRule.STYLE_RULE) {
                this.processStyleRule(
                  mediaRule,
                  rule,
                  mediaIndex,
                  unusedRules,
                  rule,
                );
              }
            });
          }
        } else if (rule.type === CSSRule.KEYFRAMES_RULE) {
          // Always preserve keyframes
          this.stats.preservedRules++;
        } else {
          // Other rule types (imports, etc.)
          this.stats.preservedRules++;
        }
      });
    } catch (e) {
      console.warn("Error processing stylesheet", e);
    }
  }

  /**
   * Process a single CSS style rule
   * @param {CSSStyleRule} rule - The CSS rule to process
   * @param {CSSStyleSheet|CSSMediaRule} parent - The parent stylesheet or media rule
   * @param {number} index - The index of the rule in its parent
   * @param {Array} unusedRules - Array to collect unused rules
   * @param {CSSMediaRule} mediaRule - Optional media rule if this is inside a media query
   */
  processStyleRule(rule, parent, index, unusedRules, mediaRule = null) {
    const selector = rule.selectorText;

    // Skip rules with complex selectors we can't easily check
    if (this.isComplexSelector(selector)) {
      this.stats.preservedRules++;
      return;
    }

    // Skip rules with preserved prefixes
    if (this.hasPreservedPrefix(selector)) {
      this.stats.preservedRules++;
      return;
    }

    // Check if the selector is used in the DOM
    const isUsed = this.isSelectorUsed(selector);

    if (!isUsed) {
      this.stats.unusedRules++;

      // Add to unused rules list
      unusedRules.push({
        selector,
        cssText: rule.cssText,
        mediaQuery: mediaRule ? mediaRule.conditionText : null,
      });

      // Remove the rule if option is enabled
      if (this.options.removeUnused) {
        try {
          parent.deleteRule(index);
          this.stats.removedRules++;
        } catch (e) {
          console.warn(`Could not remove rule: ${selector}`, e);
        }
      }
    }
  }

  /**
   * Check if a selector is used in the current DOM
   * @param {string} selector - The CSS selector to check
   * @returns {boolean} True if the selector is used
   */
  isSelectorUsed(selector) {
    try {
      // Split multiple selectors (e.g., "a, .class, #id")
      const individualSelectors = selector.split(",").map((s) => s.trim());

      // Check if any of the individual selectors are used
      return individualSelectors.some((individualSelector) => {
        try {
          return document.querySelector(individualSelector) !== null;
        } catch (e) {
          // Invalid selector, consider it used to be safe
          return true;
        }
      });
    } catch (e) {
      // If there's an error, consider the selector used to be safe
      console.warn(`Error checking selector: ${selector}`, e);
      return true;
    }
  }

  /**
   * Check if a selector has a preserved prefix
   * @param {string} selector - The CSS selector to check
   * @returns {boolean} True if the selector has a preserved prefix
   */
  hasPreservedPrefix(selector) {
    return this.options.preservePrefixes.some(
      (prefix) =>
        selector.includes(`.${prefix}`) || selector.includes(`#${prefix}`),
    );
  }

  /**
   * Check if a selector is too complex to reliably check
   * @param {string} selector - The CSS selector to check
   * @returns {boolean} True if the selector is complex
   */
  isComplexSelector(selector) {
    // Consider pseudo-elements and certain pseudo-classes complex
    const complexPatterns = [
      ":before",
      ":after",
      "::before",
      "::after",
      ":hover",
      ":focus",
      ":active",
      ":nth-child",
      ":first-child",
      ":last-child",
      "@supports",
      "@document",
    ];

    return complexPatterns.some((pattern) => selector.includes(pattern));
  }

  /**
   * Get statistics about the CSS analysis
   * @returns {Object} Statistics about CSS usage
   */
  getStats() {
    return {
      ...this.stats,
      usedRules: this.stats.totalRules - this.stats.unusedRules,
      unusedPercentage:
        this.stats.totalRules > 0
          ? ((this.stats.unusedRules / this.stats.totalRules) * 100).toFixed(
              2,
            ) + "%"
          : "0%",
    };
  }
}

// Create a singleton instance
const cssPurge = new CssPurge();
export { cssPurge };
