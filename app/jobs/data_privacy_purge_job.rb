# Background job for automated data purging based on retention policies
class DataPrivacyPurgeJob < ApplicationJob
  queue_as :default

  # Run this job daily to purge old data
  def perform
    Rails.logger.info "Starting automated data privacy purge"
    
    begin
      # First, auto-anonymize old data if configured
      anonymization_results = DataPrivacyService.auto_anonymize_old_data
      
      # Then purge data that's past retention period
      purge_results = DataPrivacyService.purge_old_data
      
      # Combine results
      total_results = {
        anonymized: anonymization_results,
        purged: purge_results
      }
      
      # Log the results
      Rails.logger.info "Data privacy operations completed successfully: #{total_results}"
      
      # Send notification if significant amount of data was processed
      total_processed = anonymization_results.values.sum + purge_results.values.sum
      if total_processed > 100
        notify_admins_of_operations(total_results)
      end
      
    rescue => e
      Rails.logger.error "Data privacy purge failed: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      
      # Notify admins of the failure
      notify_admins_of_failure(e)
      
      # Re-raise to mark job as failed
      raise e
    end
  end

  private

  def notify_admins_of_operations(results)
    # In a real application, you might send an email or Slack notification
    # For now, we'll just log it
    total_anonymized = results[:anonymized].values.sum
    total_purged = results[:purged].values.sum
    
    Rails.logger.info "Data privacy operations notification: #{total_anonymized} records anonymized, #{total_purged} records purged"
    
    # If you have admin notification system, use it here
    # AdminNotificationService.notify_data_privacy_operations(results) if defined?(AdminNotificationService)
  end

  def notify_admins_of_failure(error)
    Rails.logger.error "Data purge failure notification: #{error.message}"
    
    # If you have error notification system, use it here
    # ErrorNotificationService.notify_data_purge_failure(error) if defined?(ErrorNotificationService)
  end
end