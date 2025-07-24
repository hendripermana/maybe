import { Application } from "@hotwired/stimulus"
import { beforeEach, describe, expect, it, jest } from "@jest/globals"
import FeedbackFormController from "../../../app/javascript/controllers/feedback_form_controller"

describe("FeedbackFormController", () => {
  let application
  let controller
  let element
  
  beforeEach(() => {
    // Set up DOM
    document.body.innerHTML = `
      <div data-controller="feedback-form">
        <button 
          type="button" 
          data-action="click->feedback-form#toggleForm" 
          data-feedback-form-target="toggleButton">
          Feedback
        </button>
        
        <div data-feedback-form-target="panel" class="hidden">
          <form data-feedback-form-target="form" data-action="submit->feedback-form#submitFeedback">
            <select data-feedback-form-target="type" name="user_feedback[feedback_type]">
              <option value="">Select a type</option>
              <option value="bug_report">Bug Report</option>
            </select>
            
            <textarea data-feedback-form-target="message" name="user_feedback[message]"></textarea>
            
            <input type="hidden" data-feedback-form-target="page" name="user_feedback[page]" value="">
            <input type="hidden" data-feedback-form-target="theme" name="user_feedback[theme]" value="">
            <input type="hidden" data-feedback-form-target="browser" name="user_feedback[browser]" value="">
            
            <button type="button" data-action="feedback-form#closeForm">Cancel</button>
            <button type="submit" data-feedback-form-target="submitButton">Submit</button>
          </form>
          
          <div data-feedback-form-target="successMessage" class="hidden"></div>
          <div data-feedback-form-target="errorMessage" class="hidden"></div>
        </div>
      </div>
    `
    
    // Create a mock for fetch
    global.fetch = jest.fn(() =>
      Promise.resolve({
        ok: true,
        json: () => Promise.resolve({ status: 'success' })
      })
    )
    
    // Create a mock for CSRF token
    document.head.innerHTML = '<meta name="csrf-token" content="test-token">'
    
    // Set up Stimulus controller
    element = document.querySelector('[data-controller="feedback-form"]')
    application = Application.start()
    application.register("feedback-form", FeedbackFormController)
    
    // Get the controller instance
    controller = application.getControllerForElementAndIdentifier(element, "feedback-form")
  })
  
  it("toggles the form visibility when the button is clicked", () => {
    const toggleButton = element.querySelector('[data-feedback-form-target="toggleButton"]')
    const panel = element.querySelector('[data-feedback-form-target="panel"]')
    
    // Initially hidden
    expect(panel.classList.contains("hidden")).toBe(true)
    expect(toggleButton.getAttribute("aria-expanded")).toBe(null)
    
    // Click to open
    toggleButton.click()
    expect(panel.classList.contains("hidden")).toBe(false)
    expect(toggleButton.getAttribute("aria-expanded")).toBe("true")
    
    // Click to close
    toggleButton.click()
    expect(panel.classList.contains("hidden")).toBe(true)
    expect(toggleButton.getAttribute("aria-expanded")).toBe("false")
  })
  
  it("closes the form when the cancel button is clicked", () => {
    const toggleButton = element.querySelector('[data-feedback-form-target="toggleButton"]')
    const panel = element.querySelector('[data-feedback-form-target="panel"]')
    const cancelButton = element.querySelector('button[data-action="feedback-form#closeForm"]')
    
    // Open the form first
    toggleButton.click()
    expect(panel.classList.contains("hidden")).toBe(false)
    
    // Click cancel
    cancelButton.click()
    expect(panel.classList.contains("hidden")).toBe(true)
  })
  
  it("validates the form before submission", async () => {
    const toggleButton = element.querySelector('[data-feedback-form-target="toggleButton"]')
    const submitButton = element.querySelector('[data-feedback-form-target="submitButton"]')
    const errorMessage = element.querySelector('[data-feedback-form-target="errorMessage"]')
    
    // Open the form
    toggleButton.click()
    
    // Submit without filling required fields
    submitButton.click()
    
    // Should show error for missing type
    expect(errorMessage.classList.contains("hidden")).toBe(false)
    expect(errorMessage.textContent).toContain("Please select a feedback type")
    
    // Fill type but not message
    const typeSelect = element.querySelector('[data-feedback-form-target="type"]')
    typeSelect.value = "bug_report"
    
    // Reset error message
    errorMessage.classList.add("hidden")
    
    // Submit again
    submitButton.click()
    
    // Should show error for missing message
    expect(errorMessage.classList.contains("hidden")).toBe(false)
    expect(errorMessage.textContent).toContain("Please enter your feedback")
  })
  
  it("submits the form successfully when all fields are filled", async () => {
    const toggleButton = element.querySelector('[data-feedback-form-target="toggleButton"]')
    const submitButton = element.querySelector('[data-feedback-form-target="submitButton"]')
    const successMessage = element.querySelector('[data-feedback-form-target="successMessage"]')
    
    // Open the form
    toggleButton.click()
    
    // Fill required fields
    const typeSelect = element.querySelector('[data-feedback-form-target="type"]')
    const messageTextarea = element.querySelector('[data-feedback-form-target="message"]')
    
    typeSelect.value = "bug_report"
    messageTextarea.value = "This is a test message"
    
    // Submit the form
    submitButton.click()
    
    // Wait for async operations
    await new Promise(resolve => setTimeout(resolve, 0))
    
    // Should show success message
    expect(successMessage.classList.contains("hidden")).toBe(false)
    expect(successMessage.textContent).toContain("Thank you for your feedback")
    
    // Should have called fetch with the right parameters
    expect(global.fetch).toHaveBeenCalledWith(
      '/user_feedbacks',
      expect.objectContaining({
        method: 'POST',
        headers: expect.objectContaining({
          'X-CSRF-Token': 'test-token',
          'Accept': 'application/json'
        })
      })
    )
  })
  
  it("handles keyboard navigation with Escape key", () => {
    const toggleButton = element.querySelector('[data-feedback-form-target="toggleButton"]')
    const panel = element.querySelector('[data-feedback-form-target="panel"]')
    
    // Open the form
    toggleButton.click()
    expect(panel.classList.contains("hidden")).toBe(false)
    
    // Press Escape
    const escapeEvent = new KeyboardEvent('keydown', { key: 'Escape', bubbles: true })
    document.dispatchEvent(escapeEvent)
    
    // Form should be closed
    expect(panel.classList.contains("hidden")).toBe(true)
  })
})