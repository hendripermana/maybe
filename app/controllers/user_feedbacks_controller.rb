class UserFeedbacksController < ApplicationController
  def create
    @feedback = UserFeedback.new(feedback_params)
    @feedback.user = current_user if user_signed_in?
    
    respond_to do |format|
      if @feedback.save
        format.html do
          flash[:notice] = "Thank you for your feedback!"
          redirect_back(fallback_location: root_path)
        end
        format.json { render json: { status: 'success' }, status: :created }
      else
        format.html do
          flash[:alert] = "There was a problem submitting your feedback: #{@feedback.errors.full_messages.join(', ')}"
          redirect_back(fallback_location: root_path)
        end
        format.json { render json: { status: 'error', error: @feedback.errors.full_messages.join(', ') }, status: :unprocessable_entity }
      end
    end
  end
  
  private
  
  def feedback_params
    params.require(:user_feedback).permit(:feedback_type, :message, :page, :browser, :theme)
  end
end