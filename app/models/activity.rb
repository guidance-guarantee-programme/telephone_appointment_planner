class Activity < ApplicationRecord
  HIGH_PRIORITY_ACTIVITY_CLASS_NAMES = %w[
    DropActivity
    DroppedSummaryDocumentActivity
    PrintedConfirmationFailedActivity
  ].freeze

  belongs_to :appointment
  belongs_to :user, optional: true
  belongs_to :owner, class_name: 'User', optional: true
  belongs_to :prior_owner, class_name: 'User', optional: true
  belongs_to :resolver, class_name: 'User', optional: true
  validates :owner, presence: true, if: :owner_required?

  scope :resolved, -> { where.not(resolved_at: nil) }
  scope :unresolved, -> { where(resolved_at: nil) }
  scope :high_priority, -> { where(type: HIGH_PRIORITY_ACTIVITY_CLASS_NAMES) }

  def self.from(audit, appointment)
    if audit.action == 'create'
      CreateActivity.from(audit, appointment)
    else
      AuditActivity.from(audit, appointment)
    end

    AssignmentActivity.from(audit, appointment)
  end

  def self.high_priority_for(user)
    high_priority.where(owner: user)
  end

  def user_name
    user.try(:name) || 'Someone'
  end

  def to_partial_path
    "activities/#{model_name.singular}"
  end

  def resolve!(resolver)
    return if resolved?

    self.resolved_at = Time.zone.now
    self.resolver = resolver
    save!
  end

  def resolved?
    resolved_at?
  end

  def high_priority?
    HIGH_PRIORITY_ACTIVITY_CLASS_NAMES.include?(self.class.to_s)
  end

  def owner_required?
    true
  end

  after_commit on: :create do
    PusherActivityCreatedJob.perform_later(id)
  end
end
