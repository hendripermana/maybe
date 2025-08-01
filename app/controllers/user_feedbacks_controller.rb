class UserFeedbacksController < ApplicationController
  # POST /user_feedbacks
  def create
    @feedback = UserFeedback.new(feedback_params)

    # Associate feedback with authenticated user (requirement 2.4)
    @feedback.user = current_user if user_signed_in?

    # Sanitize any potentially sensitive information from the message
    sanitize_feedback_message

    respond_to do |format|
      if @feedback.save
        # Success notification (requirement 2.5)
        format.html do
          flash[:notice] = "Thank you for your feedback!"
          redirect_back(fallback_location: root_path)
        end
        format.json { render json: { status: "success" }, status: :created }
      else
        # Error notification (requirement 2.5)
        format.html do
          flash[:alert] = "There was a problem submitting your feedback: #{@feedback.errors.full_messages.join(', ')}"
          redirect_back(fallback_location: root_path)
        end
        format.json { render json: { status: "error", error: @feedback.errors.full_messages.join(", ") }, status: :unprocessable_entity }
      end
    end
  end

  private

    def feedback_params
      # Only permit specific parameters to ensure data privacy (requirement 6.2)
      params.require(:user_feedback).permit(:feedback_type, :message, :page, :browser, :theme)
    end

    # Ensure no sensitive information is stored in feedback messages (requirement 6.2)
    def sanitize_feedback_message
      return unless @feedback.message.present?

      # Remove potential email addresses
      @feedback.message = @feedback.message.gsub(/\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b/, "[EMAIL REDACTED]")

      # Remove potential phone numbers
      @feedback.message = @feedback.message.gsub(/\b(\+\d{1,2}\s)?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}\b/, "[PHONE REDACTED]")

      # Remove potential API keys or tokens (alphanumeric strings of 20+ characters)
      @feedback.message = @feedback.message.gsub(/\b[A-Za-z0-9_-]{20,}\b/, "[TOKEN REDACTED]")
    end
end
