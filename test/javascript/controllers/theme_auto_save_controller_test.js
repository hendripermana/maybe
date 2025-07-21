import { Application } from "@hotwired/stimulus"
import { beforeEach, describe, expect, it, vi } from "vitest"
import ThemeAutoSaveController from "../../../app/javascript/controllers/theme_auto_save_controller"

describe("ThemeAutoSaveController", () => {
  let application
  let element
  let controller
  let fetchMock

  beforeEach(() => {
    // Create a fresh Stimulus application for each test
    application = Application.start()
    application.register("theme-auto-save", ThemeAutoSaveController)

    // Create the HTML element with the necessary structure
    document.body.innerHTML = `
      <div data-controller="theme-auto-save" 
           data-theme-auto-save-url-value="/settings/preferences/update_theme" 
           data-theme-auto-save-csrf-token-value="test-csrf-token">
        <input type="hidden" name="theme" value="light" data-theme-auto-save-target="themeInput">
        <form data-theme-auto-save-target="form"></form>
      </div>
    `

    // Get the element and controller
    element = document.querySelector("[data-controller='theme-auto-save']")
    controller = application.getControllerForElementAndIdentifier(element, "theme-auto-save")

    // Mock fetch
    fetchMock = vi.fn().mockResolvedValue({
      ok: true,
      json: () => Promise.resolve({ success: true })
    })
    global.fetch = fetchMock
  })

  it("connects and initializes properly", () => {
    expect(controller).toBeDefined()
  })

  it("handles theme preference change event with form submission", () => {
    // Mock form submission
    controller.formTarget.requestSubmit = vi.fn()
    
    // Create theme preference change event
    const event = new CustomEvent("theme:preferenceChanged", {
      detail: { preference: "dark" },
      bubbles: true
    })
    
    // Dispatch event
    document.dispatchEvent(event)
    
    // Check that the input value was updated
    expect(controller.themeInputTarget.value).toBe("dark")
    
    // Check that the form was submitted
    expect(controller.formTarget.requestSubmit).toHaveBeenCalled()
  })

  it("handles theme preference change event with AJAX when no form", () => {
    // Remove form target
    element.removeChild(controller.formTarget)
    
    // Create theme preference change event
    const event = new CustomEvent("theme:preferenceChanged", {
      detail: { preference: "dark" },
      bubbles: true
    })
    
    // Dispatch event
    document.dispatchEvent(event)
    
    // Check that the input value was updated
    expect(controller.themeInputTarget.value).toBe("dark")
    
    // Check that fetch was called with correct parameters
    expect(fetchMock).toHaveBeenCalledWith(
      "/settings/preferences/update_theme",
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": "test-csrf-token"
        },
        body: JSON.stringify({ theme: "dark" })
      }
    )
  })

  it("handles theme preference change event with AJAX when no input target", () => {
    // Remove input target
    element.removeChild(controller.themeInputTarget)
    // Remove form target
    element.removeChild(controller.formTarget)
    
    // Create theme preference change event
    const event = new CustomEvent("theme:preferenceChanged", {
      detail: { preference: "dark" },
      bubbles: true
    })
    
    // Dispatch event
    document.dispatchEvent(event)
    
    // Check that fetch was called with correct parameters
    expect(fetchMock).toHaveBeenCalledWith(
      "/settings/preferences/update_theme",
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": "test-csrf-token"
        },
        body: JSON.stringify({ theme: "dark" })
      }
    )
  })

  it("handles fetch errors gracefully", async () => {
    // Mock console.error
    console.error = vi.fn()
    
    // Mock fetch to reject
    global.fetch = vi.fn().mockRejectedValue(new Error("Network error"))
    
    // Remove form target
    element.removeChild(controller.formTarget)
    
    // Create theme preference change event
    const event = new CustomEvent("theme:preferenceChanged", {
      detail: { preference: "dark" },
      bubbles: true
    })
    
    // Dispatch event
    document.dispatchEvent(event)
    
    // Wait for promise to resolve
    await new Promise(resolve => setTimeout(resolve, 0))
    
    // Check that error was logged
    expect(console.error).toHaveBeenCalled()
  })

  it("handles non-OK response gracefully", async () => {
    // Mock console.error
    console.error = vi.fn()
    
    // Mock fetch to return non-OK response
    global.fetch = vi.fn().mockResolvedValue({
      ok: false,
      status: 500,
      statusText: "Internal Server Error"
    })
    
    // Remove form target
    element.removeChild(controller.formTarget)
    
    // Create theme preference change event
    const event = new CustomEvent("theme:preferenceChanged", {
      detail: { preference: "dark" },
      bubbles: true
    })
    
    // Dispatch event
    document.dispatchEvent(event)
    
    // Wait for promise to resolve
    await new Promise(resolve => setTimeout(resolve, 0))
    
    // Check that error was logged
    expect(console.error).toHaveBeenCalled()
  })

  it("cleans up event listeners on disconnect", () => {
    // Mock removeEventListener
    document.removeEventListener = vi.fn()
    
    // Call disconnect
    controller.disconnect()
    
    // Check that event listener was removed
    expect(document.removeEventListener).toHaveBeenCalledWith(
      "theme:preferenceChanged",
      expect.any(Function)
    )
  })
})