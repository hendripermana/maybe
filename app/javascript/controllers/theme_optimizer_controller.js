import { Controller } from "@hotwired/stimulus";

// This controller optimizes theme switching performance
export default class extends Controller {
  static targets = ["themeSwitch"];

  connect() {
    this.preloadThemes();
    this.optimizeThemeSwitching();
  }

  preloadThemes() {
    // Preload both themes to make switching faster
    const themes = ["light", "dark"];
    const currentTheme =
      document.documentElement.getAttribute("data-theme") || "light";

    // Preload the non-active theme
    const themeToPreload = themes.find((theme) => theme !== currentTheme);

    if (themeToPreload) {
      // Create a hidden div with the other theme to force browser to process styles
      const preloadDiv = document.createElement("div");
      preloadDiv.setAttribute("data-theme", themeToPreload);
      preloadDiv.style.display = "none";
      document.body.appendChild(preloadDiv);

      // Remove after a short delay
      setTimeout(() => {
        document.body.removeChild(preloadDiv);
      }, 1000);
    }
  }

  optimizeThemeSwitching() {
    if (this.hasThemeSwitchTarget) {
      this.themeSwitchTarget.addEventListener(
        "click",
        this.handleThemeSwitch.bind(this),
      );
    }

    // Listen for theme changes from other sources
    document.addEventListener(
      "theme-changed",
      this.measureThemeSwitch.bind(this),
    );
  }

  handleThemeSwitch(event) {
    // Measure theme switch performance
    const startTime = performance.now();

    // Get current and new theme
    const currentTheme =
      document.documentElement.getAttribute("data-theme") || "light";
    const newTheme = currentTheme === "light" ? "dark" : "light";

    // Apply containment to limit repaints during theme switch
    document.body.style.contain = "paint";

    // Switch theme
    document.documentElement.setAttribute("data-theme", newTheme);

    // Remove containment after switch is complete
    requestAnimationFrame(() => {
      document.body.style.contain = "";

      // Measure and report switch time
      const endTime = performance.now();
      const switchTime = Math.round(endTime - startTime);

      // Dispatch event with timing information
      document.dispatchEvent(
        new CustomEvent("theme-changed", {
          detail: {
            theme: newTheme,
            switchTime: switchTime,
          },
        }),
      );

      console.log(`Theme switch to ${newTheme} took ${switchTime}ms`);
    });
  }

  measureThemeSwitch(event) {
    // This method is called when theme is changed from any source
    const { theme, switchTime } = event.detail;

    // Log theme switch performance
    if (switchTime > 200) {
      console.warn(
        `Theme switch to ${theme} took ${switchTime}ms, which is slower than the 200ms target`,
      );
    }
  }
}
