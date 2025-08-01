# Controller for handling GDPR and data privacy requests
class DataPrivacyController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin, only: [ :admin_index, :admin_purge, :admin_audit ]

  # User's data export (GDPR Article 15 - Right of access)
  def export
    @user_data = DataPrivacyService.export_user_data(current_user)

    respond_to do |format|
      format.json do
        render json: @user_data
      end
      format.html do
        # Render a page showing the data
      end
    end
  end

  # User's data deletion request (GDPR Article 17 - Right to erasure)
  def delete_request
    if request.post?
      # In a real application, you might want to:
      # 1. Send a confirmation email
      # 2. Have a waiting period
      # 3. Allow the user to cancel the request

      results = DataPrivacyService.delete_user_data(current_user)

      flash[:notice] = "Your data has been anonymized. Monitoring events: #{results[:ui_monitoring_events]}, Feedback: #{results[:user_feedbacks]}"
      redirect_to root_path
    end
  end

  # Admin interface for data privacy management
  def admin_index
    @retention_audit = DataPrivacyService.audit_data_retention
    @total_events = UiMonitoringEvent.count
    @total_feedback = UserFeedback.count
    @old_events = @retention_audit[:old_ui_monitoring_events]
    @old_feedback = @retention_audit[:old_resolved_feedbacks] + @retention_audit[:old_unresolved_feedbacks]
  end

  # Admin action to manually trigger data purge
  def admin_purge
    if request.post?
      begin
        results = DataPrivacyService.purge_old_data
        flash[:notice] = "Data purge completed. Events: #{results[:ui_monitoring_events]}, Resolved feedback: #{results[:resolved_feedbacks]}, Old feedback: #{results[:user_feedbacks]}"
      rescue => e
        flash[:alert] = "Data purge failed: #{e.message}"
      end
    end

    redirect_to data_privacy_admin_path
  end

  # Admin audit of data retention compliance
  def admin_audit
    @audit_results = DataPrivacyService.audit_data_retention
    @events_needing_anonymization = UiMonitoringEvent.needs_anonymization.count
    @feedback_needing_anonymization = UserFeedback.needs_anonymization.count

    respond_to do |format|
      format.html
      format.json { render json: @audit_results }
    end
  end

  # Admin action to anonymize data
  def admin_anonymize
    if request.post?
      anonymized_events = 0
      anonymized_feedback = 0

      begin
        # Anonymize monitoring events
        UiMonitoringEvent.needs_anonymization.find_each do |event|
          event.anonymize!
          anonymized_events += 1
        end

        # Anonymize user feedback
        UserFeedback.needs_anonymization.find_each do |feedback|
          feedback.anonymize!
          anonymized_feedback += 1
        end

        flash[:notice] = "Anonymization completed. Events: #{anonymized_events}, Feedback: #{anonymized_feedback}"
      rescue => e
        flash[:alert] = "Anonymization failed: #{e.message}"
      end
    end

    redirect_to data_privacy_admin_path
  end

  private

    def require_admin
      unless current_user&.admin?
        flash[:alert] = "You are not authorized to access this page"
        redirect_to root_path
      end
    end
end
