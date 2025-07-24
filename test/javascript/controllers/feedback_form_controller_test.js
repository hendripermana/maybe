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
        <button data-action="click->feedback-form#toggleForm">Feedback</button>
        <div data-feedback-form-target="panel">
          <form data-feedback-form-target="form" data-action="submit->feedback-form#submitFeedback">
            <select data-feedback-form-target="type" name="user_feedback[feedback_type]">
              <option value="">Select a type</option>
              <option value="bug_report">Bug Report</option>
            </select>
            <textarea data-feedback-form-target="message" name="user_feedback[message]"></textarea>
            <input type="hidden" data-feedback-form-target="page" name="user_feedback[page]" value="">
            <input type="hidden" data-feedback-form-target="theme" name="user_feedback[theme]" value="">
            <input type="hidden" data-feedback-form-target="browser" name="user_feedback[browser]" value="">
            <button type="submit" data-feedback-form-target="submitButton">Submit</button>
          </form>
          <div data-feedback-form-target="successMessage" class="hidden"></div>
          <div data-feedback-form-target="errorMessage" class="hidden"></div>
        </div>
      </div>
    `
    
    // Set up Stimulus controller
    element = document.querySelector('[data-controller="feedback-form"]')
    application = Application.start()
    application.register("feedback-form", FeedbackFormController)
    
    // Mock fetch
    global.fetch = jest.fn()
    
    // Mock CSRF token
    document.head.innerHTML = '<meta name="csrf-token" content="test-token">'
    
    // Mock window.location
    Object.defineProperty(window, 'location', {
      value: { href: 'http://test.com/dashboard' }
    })
  })
  
  it("toggles the panel visibility", () => {
    const button = element.querySelector('button')
    const panel = element.querySelector('[data-feedback-form-target="panel"]')
    
    button.click()
    expect(panel.classList.contains("open")).toBe(true)
    
    button.click()
    expect(panel.classList.contains("open")).toBe(false)
  })
  
  it("sets the page value on connect", () => {
    const pageInput = element.querySelector('[data-feedback-form-target="page"]')
    expect(pageInput.value).toBe('http://test.com/dashboard')
  })
  
  it("validates the form before submission", async () => {
    const form = element.querySelector('form')
    const errorMessage = element.querySelector('[data-feedback-form-target="errorMessage"]')
    
    // Submit with empty fields
    form.dispatchEvent(new Event('submit'))
    
    expect(errorMessage.classList.contains("hidden")).toBe(false)
    expect(errorMessage.textContent).toContain("Please select a feedback type")
    
    // Fill type but not message
    const typeSelect = element.querySelector('[data-feedback-form-target="type"]')
    typeSelect.value = 'bug_report'
    
    form.dispatchEvent(new Event('submit'))
    
    expect(errorMessage.textContent).toContain("Please enter your feedback")
  })
  
  it("submits the form with valid data", async () => {
    // Mock successful fetch response
    global.fetch.mockImplementation(() => 
      Promise.resolve({
        ok: true,
        json: () => Promise.resolve({ status: 'success' })
      })
    )
    
    const form = element.querySelector('form')
    const typeSelect = element.querySelector('[data-feedback-form-target="type"]')
    const messageTextarea = element.querySelector('[data-feedback-form-target="message"]')
    const successMessage = element.querySelector('[data-feedback-form-target="successMessage"]')
    
    // Fill form with valid data
    typeSelect.value = 'bug_report'
    messageTextarea.value = 'Test feedback message'
    
    // Submit form
    form.dispatchEvent(new Event('submit'))
    
    // Wait for async operations
    await new Promise(resolve => setTimeout(resolve, 0))
    
    // Check that fetch was called with correct data
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
    
    // Check success message is shown
    expect(successMessage.classList.contains("hidden")).toBe(false)
    expect(successMessage.textContent).toContain("Thank you for your feedback")
  })
  
  it("handles submission errors", async () => {
    // Mock failed fetch response
    global.fetch.mockImplementation(() => 
      Promise.resolve({
        ok: false,
        json: () => Promise.resolve({ status: 'error', error: 'Test error' })
      })
    )
    
    const form = element.querySelector('form')
    const typeSelect = element.querySelector('[data-feedback-form-target="type"]')
    const messageTextarea = element.querySelector('[data-feedback-form-target="message"]')
    const errorMessage = element.querySelector('[data-feedback-form-target="errorMessage"]')
    
    // Fill form with valid data
    typeSelect.value = 'bug_report'
    messageTextarea.value = 'Test feedback message'
    
    // Submit form
    form.dispatchEvent(new Event('submit'))
    
    // Wait for async operations
    await new Promise(resolve => setTimeout(resolve, 0))
    
    // Check error message is shown
    expect(errorMessage.classList.contains("hidden")).toBe(false)
    expect(errorMessage.textContent).toContain("Test error")
  })
})