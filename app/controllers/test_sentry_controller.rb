class TestSentryController < ApplicationController
  # Bypass all authentication and other before_actions for this test endpoint
  skip_before_action :authenticate_user!, only: [:test_error, :test_capture, :test_message]
  skip_before_action :set_sentry_user, only: [:test_error, :test_capture, :test_message]
  skip_before_action :require_onboarding_and_upgrade, only: [:test_error, :test_capture, :test_message]
  skip_before_action :verify_self_host_config, only: [:test_error, :test_capture, :test_message]
  
  def test_error
    # Test different types of errors
    error_type = params[:type] || 'standard'
    
    case error_type
    when 'standard'
      raise StandardError, "This is a test StandardError for Sentry integration verification"
    when 'runtime'
      raise RuntimeError, "This is a test RuntimeError for Sentry integration verification"
    when 'argument'
      raise ArgumentError, "This is a test ArgumentError for Sentry integration verification"
    when 'custom'
      raise CustomTestError, "This is a test CustomTestError for Sentry integration verification"
    else
      raise "Unknown error type for Sentry test"
    end
  end
  
  def test_capture
    # Test explicit error capture
    begin
      raise StandardError, "This is an explicitly captured error for Sentry testing"
    rescue StandardError => e
      Sentry.capture_exception(e, extra: { test: true, timestamp: Time.current })
    end
    
    render json: { 
      message: "Error captured and sent to Sentry", 
      timestamp: Time.current,
      sentry_configured: Sentry.configuration.dsn.present?
    }
  end
  
  def test_message
    # Test message capture
    Sentry.capture_message("Test message from Maybe Finance app", level: :info, extra: {
      test: true,
      timestamp: Time.current,
      user_agent: request.user_agent,
      ip: request.remote_ip
    })
    
    render json: { 
      message: "Test message sent to Sentry", 
      timestamp: Time.current 
    }
  end

  private

  class CustomTestError < StandardError; end
end
