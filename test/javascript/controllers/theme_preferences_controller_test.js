import { Application } from "@hotwired/stimulus"
import { beforeEach, describe, expect, it, vi } from "vitest"
import ThemePreferencesController from "../../../app/javascript/controllers/theme_preferences_controller"

describe("ThemePreferencesController", () => {
  let application
  let element
  let controller

  beforeEach(() => {
    // Create a fresh Stimulus application for each test
    application = Application.start()
    application.register("theme-preferences", ThemePreferencesController)

    // Create the HTML element with the necessary structure
    document.body.innerHTML = `
      <div data-controller="theme-preferences" data-theme-preferences-current-theme-value="light" data-theme-preferences-preview-delay-value="100">
        <div data-theme-preferences-target="option">
          <input type="radio" name="theme" value="light">
        </div>
        <div data-theme-preferences-target="option">
          <input type="radio" name="theme" value="dark">
        </div>
        <div data-theme-preferences-target="option">
          <input type="radio" name="theme" value="system">
        </div>
        <div data-theme-preferences-target="preview"></div>
        <form data-theme-preferences-target="form"></form>
      </div>
    `

    // Get the element and controller
    element = document.querySelector("[data-controller='theme-preferences']")
    controller = application.getControllerForElementAndIdentifier(element, "theme-preferences")

    // Mock setTimeout
    vi.useFakeTimers()
  })

  afterEach(() => {
    vi.useRealTimers()
  })

  it("connects and initializes properly", () => {
    expect(controller).toBeDefined()
  })

  it("highlights the selected option on connect", () => {
    // Mock the highlightSelectedOption method
    controller.highlightSelectedOption = vi.fn()
    
    // Call connect
    controller.connect()
    
    expect(controller.highlightSelectedOption).toHaveBeenCalled()
  })

  it("selects an option when clicked", () => {
    // Mock methods
    controller.highlightSelectedOption = vi.fn()
    controller.dispatchThemeChangeEvent = vi.fn()
    
    // Create event with currentTarget
    const option = controller.optionTargets[0]
    const event = { currentTarget: option }
    
    // Call selectOption
    controller.selectOption(event)
    
    expect(controller.currentThemeValue).toBe("light")
    expect(controller.highlightSelectedOption).toHaveBeenCalled()
    expect(controller.dispatchThemeChangeEvent).toHaveBeenCalledWith("light")
  })

  it("shows theme preview on hover", () => {
    // Mock showThemePreview method
    controller.showThemePreview = vi.fn()
    
    // Create event with currentTarget
    const option = controller.optionTargets[1]
    const event = { currentTarget: option }
    
    // Call handleOptionHover
    controller.handleOptionHover(event)
    
    // Fast-forward timer
    vi.advanceTimersByTime(100)
    
    expect(controller.showThemePreview).toHaveBeenCalledWith("dark")
  })

  it("restores selected theme on hover leave", () => {
    // Set current theme
    controller.currentThemeValue = "light"
    
    // Mock showThemePreview method
    controller.showThemePreview = vi.fn()
    
    // Call handleOptionLeave
    controller.handleOptionLeave()
    
    // Fast-forward timer
    vi.advanceTimersByTime(50)
    
    expect(controller.showThemePreview).toHaveBeenCalledWith("light")
  })

  it("shows theme preview for a specific theme", () => {
    // Call showThemePreview
    controller.showThemePreview("dark")
    
    const preview = controller.previewTarget
    expect(preview.getAttribute("data-theme")).toBe("dark")
  })

  it("handles system theme in preview", () => {
    // Mock matchMedia
    window.matchMedia = vi.fn().mockImplementation((query) => {
      return {
        matches: query === "(prefers-color-scheme: dark)",
      }
    })
    
    // Call showThemePreview with system
    controller.showThemePreview("system")
    
    const preview = controller.previewTarget
    expect(preview.getAttribute("data-theme")).toBe("system")
    expect(preview.getAttribute("data-system-theme")).toBe("dark")
  })

  it("handles theme change event", () => {
    // Mock methods
    controller.currentThemeValue = "light"
    controller.highlightSelectedOption = vi.fn()
    controller.showThemePreview = vi.fn()
    
    // Create theme change event
    const event = {
      detail: {
        theme: "dark",
        preference: "dark",
        isDark: true
      }
    }
    
    // Call handleThemeChange
    controller.handleThemeChange(event)
    
    expect(controller.currentThemeValue).toBe("dark")
    expect(controller.highlightSelectedOption).toHaveBeenCalled()
    expect(controller.showThemePreview).toHaveBeenCalledWith("dark")
  })

  it("highlights the selected option", () => {
    // Set current theme
    controller.currentThemeValue = "dark"
    
    // Call highlightSelectedOption
    controller.highlightSelectedOption()
    
    // Check that the correct option is selected
    const options = controller.optionTargets
    expect(options[0].classList.contains("selected")).toBe(false)
    expect(options[1].classList.contains("selected")).toBe(true)
    expect(options[2].classList.contains("selected")).toBe(false)
    
    // Check that the radio button is checked
    const radioButton = options[1].querySelector("input")
    expect(radioButton.checked).toBe(true)
  })

  it("dispatches theme change event", () => {
    // Mock dispatchEvent
    element.dispatchEvent = vi.fn()
    
    // Call dispatchThemeChangeEvent
    controller.dispatchThemeChangeEvent("dark")
    
    expect(element.dispatchEvent).toHaveBeenCalled()
    const event = element.dispatchEvent.mock.calls[0][0]
    expect(event.type).toBe("theme:preferenceChanged")
    expect(event.detail.preference).toBe("dark")
  })
})