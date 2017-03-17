class Activity < ApplicationRecord
  belongs_to :appointment
  belongs_to :user
  belongs_to :owner, class_name: User
  belongs_to :prior_owner, class_name: User
  belongs_to :resolver, class_name: User
  validates :owner, presence: true

  scope :resolved, -> { where.not(resolved_at: nil) }
  scope :unresolved, -> { where(resolved_at: nil) }

  def self.from(audit, appointment)
    if audit.action == 'create'
      CreateActivity.from(audit, appointment)
    else
      AuditActivity.from(audit, appointment)
    end

    AssignmentActivity.from(audit, appointment)
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
end
