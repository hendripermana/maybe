class UserFeedback < ApplicationRecord
  # Associations
  belongs_to :user, optional: true

  # Validations
  validates :feedback_type, presence: true
  validates :message, presence: true
  validates :page, presence: true

  # Enums
  enum feedback_type: {
    bug_report: 'bug_report',
    feature_request: 'feature_request',
    ui_feedback: 'ui_feedback',
    accessibility_issue: 'accessibility_issue',
    performance_issue: 'performance_issue',
    general_feedback: 'general_feedback'
  }

  # Scopes
  scope :recent, -> { order(created_at: :desc) }
  scope :unresolved, -> { where(resolved: false) }
  scope :ui_related, -> { where(feedback_type: ['ui_feedback', 'accessibility_issue']) }
  
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
end