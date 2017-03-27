class Activity < ApplicationRecord
  HIGH_PRIORITY_ACTIVITY_CLASS_NAMES = %w(DropActivity).freeze

  belongs_to :appointment
  belongs_to :user
  belongs_to :owner, class_name: User
  belongs_to :prior_owner, class_name: User
  belongs_to :resolver, class_name: User
  validates :owner, presence: true

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
    high_priority
      .joins(:appointment)
      .where('appointments.agent_id = :user OR appointments.guider_id = :user', user: user)
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

  def pusher_notify_user_ids
    []
  end

  after_commit on: :create do
    Array(pusher_notify_user_ids).each do |user_id|
      PusherActivityCreatedJob.perform_later(user_id, id)
    end
  end

  after_commit if: :high_priority? do
    PusherHighPriorityCountChangedJob.perform_later(owner)
    PusherHighPriorityCountChangedJob.perform_later(user) if user

    unless appointment.agent == owner
      PusherHighPriorityCountChangedJob.perform_later(appointment.agent)
    end
  end
end
