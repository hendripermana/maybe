import { Application } from "@hotwired/stimulus"
import { beforeEach, describe, expect, it, vi } from "vitest"
import ThemeController from "../../../app/javascript/controllers/theme_controller"

describe("ThemeController", () => {
  let application
  let element
  let controller

  beforeEach(() => {
    // Create a fresh Stimulus application for each test
    application = Application.start()
    application.register("theme", ThemeController)

    // Create the HTML element with the necessary structure
    document.body.innerHTML = `
      <div data-controller="theme" data-theme-user-preference-value="system">
        <button data-theme-target="toggle" aria-pressed="false" data-theme-state="light">Toggle Theme</button>
        <label data-theme-target="lightLabel">Light</label>
        <label data-theme-target="darkLabel">Dark</label>
      </div>
    `

    // Get the element and controller
    element = document.querySelector("[data-controller='theme']")
    controller = application.getControllerForElementAndIdentifier(element, "theme")

    // Mock matchMedia
    window.matchMedia = vi.fn().mockImplementation((query) => {
      return {
        matches: false,
        media: query,
        onchange: null,
        addEventListener: vi.fn(),
        removeEventListener: vi.fn(),
        dispatchEvent: vi.fn(),
      }
    })

    // Mock document.documentElement for theme setting
    Object.defineProperty(document, "documentElement", {
      value: {
        getAttribute: vi.fn(),
        setAttribute: vi.fn(),
        classList: {
          add: vi.fn(),
          remove: vi.fn()
        }
      },
      writable: true
    })
  })

  it("connects and initializes properly", () => {
    expect(controller).toBeDefined()
  })

  it("applies theme based on user preference", () => {
    controller.userPreferenceValue = "light"
    controller.userPreferenceValueChanged()
    
    expect(document.documentElement.setAttribute).toHaveBeenCalledWith("data-theme", "light")
  })

  it("applies dark theme when user preference is dark", () => {
    controller.userPreferenceValue = "dark"
    controller.userPreferenceValueChanged()
    
    expect(document.documentElement.setAttribute).toHaveBeenCalledWith("data-theme", "dark")
  })

  it("applies system theme when user preference is system", () => {
    // Mock system preference to dark
    window.matchMedia = vi.fn().mockImplementation((query) => {
      return {
        matches: query === "(prefers-color-scheme: dark)",
        media: query,
        onchange: null,
        addEventListener: vi.fn(),
        removeEventListener: vi.fn(),
        dispatchEvent: vi.fn(),
      }
    })
    
    controller.userPreferenceValue = "system"
    controller.userPreferenceValueChanged()
    
    expect(document.documentElement.setAttribute).toHaveBeenCalledWith("data-theme", "dark")
  })

  it("toggles theme when toggle is clicked", () => {
    // Mock current theme as light
    document.documentElement.getAttribute.mockReturnValue("light")
    
    // Set up event listener to check for theme change event
    const eventSpy = vi.fn()
    document.addEventListener("theme:preferenceChanged", eventSpy)
    
    // Call toggle method
    controller.toggle()
    
    // Should change to dark
    expect(document.documentElement.setAttribute).toHaveBeenCalledWith("data-theme", "dark")
    expect(eventSpy).toHaveBeenCalled()
    
    // Event should contain preference: dark
    expect(eventSpy.mock.calls[0][0].detail.preference).toBe("dark")
  })

  it("handles system theme changes when preference is system", () => {
    controller.userPreferenceValue = "system"
    
    // Simulate system theme change event
    const mediaQueryList = { matches: true }
    controller.handleSystemThemeChange(mediaQueryList)
    
    expect(document.documentElement.setAttribute).toHaveBeenCalledWith("data-theme", "dark")
  })

  it("ignores system theme changes when preference is not system", () => {
    controller.userPreferenceValue = "light"
    
    // Simulate system theme change event
    const mediaQueryList = { matches: true }
    controller.handleSystemThemeChange(mediaQueryList)
    
    // Should not change theme
    expect(document.documentElement.setAttribute).not.toHaveBeenCalledWith("data-theme", "dark")
  })

  it("adds transition class for smooth theme switching", () => {
    // Mock document.head and appendChild
    document.head = { appendChild: vi.fn() }
    
    controller.addTransitionClass()
    
    expect(document.head.appendChild).toHaveBeenCalled()
  })

  it("cleans up event listeners on disconnect", () => {
    const removeEventListenerSpy = vi.fn()
    controller.darkMediaQuery = { 
      removeEventListener: removeEventListenerSpy 
    }
    
    controller.disconnect()
    
    expect(removeEventListenerSpy).toHaveBeenCalled()
  })
})