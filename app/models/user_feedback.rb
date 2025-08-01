class UserFeedback < ApplicationRecord
  # Associations
  belongs_to :user, optional: true

  # Validations
  validates :feedback_type, presence: true
  validates :message, presence: true
  validates :page, presence: true

  # Enums
  enum :feedback_type, {
    bug_report: "bug_report",
    feature_request: "feature_request",
    ui_feedback: "ui_feedback",
    accessibility_issue: "accessibility_issue",
    performance_issue: "performance_issue",
    general_feedback: "general_feedback"
  }

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :unresolved, -> { where(resolved: false) }
  scope :ui_related, -> { where(feedback_type: [ "ui_feedback", "accessibility_issue" ]) }

  # Instance methods
  def mark_as_resolved(admin_user = nil, notes = nil)
    update(
      resolved: true,
      resolved_at: Time.current,
      resolved_by: admin_user&.id,
      resolution_notes: notes
    )
  end

  def resolver
    return nil unless resolved_by
    User.find_by(id: resolved_by)
  end

  def resolution_info
    return nil unless resolved

    info = "Resolved #{resolved_at.strftime('%Y-%m-%d %H:%M')}"
    if resolver
      info += " by #{resolver.email}"
    end

    info
  end

  def summary
    "#{feedback_type.humanize}: #{message.truncate(50)}"
  end

  # Data privacy methods
  def anonymize!
    return if data_anonymized?

    DataPrivacyService.anonymize_user_feedback(self)
    update!(data_anonymized: true, anonymized_at: Time.current)
  end

  def contains_pii?
    return false if data_anonymized?
    return true if user_id.present?
    return true if browser.present? && !browser.include?("anonymized")

    # Check message for potential PII patterns
    if message.present?
      return true if message =~ /\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}\b/ # Email
      return true if message =~ /\b(\+\d{1,2}\s?)?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}\b/ # Phone
      return true if message =~ /\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b/ # Card
      return true if message =~ /\b\d{3}-?\d{2}-?\d{4}\b/ # SSN
    end

    false
  end

  # Scope for old records that should be purged
  scope :old_resolved_records, ->(retention_days = 365) {
    where(resolved: true).where("resolved_at < ?", retention_days.days.ago)
  }

  scope :old_unresolved_records, ->(retention_days = 730) {
    where(resolved: false).where("created_at < ?", retention_days.days.ago)
  }

  # Scope for records that need anonymization
  scope :needs_anonymization, -> { where(data_anonymized: false).where.not(user_id: nil) }

  # Scope for anonymized records
  scope :anonymized, -> { where(data_anonymized: true) }

  # GDPR compliance methods
  def self.purge_old_resolved_records(retention_days = 365)
    old_resolved_records(retention_days).delete_all
  end

  def self.purge_old_unresolved_records(retention_days = 730)
    old_unresolved_records(retention_days).delete_all
  end

  def self.anonymize_user_data(user)
    where(user: user).find_each(&:anonymize!)
  end

  def self.export_user_data(user)
    where(user: user).map do |feedback|
      {
        id: feedback.id,
        feedback_type: feedback.feedback_type,
        message: DataPrivacyService.send(:sanitize_message, feedback.message),
        page: feedback.page,
        theme: feedback.theme,
        browser: DataPrivacyService.send(:anonymize_user_agent, feedback.browser),
        resolved: feedback.resolved,
        created_at: feedback.created_at.iso8601,
        resolved_at: feedback.resolved_at&.iso8601
      }
    end
  end

  # Schedule anonymization for privacy compliance
  def schedule_anonymization
    # For now, just mark as needing anonymization
    # In a real implementation, this would schedule a background job
    return if data_anonymized?
    
    if contains_pii?
      anonymize!
    end
  end
end
