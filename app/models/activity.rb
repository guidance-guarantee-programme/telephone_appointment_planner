class Activity < ApplicationRecord
  belongs_to :appointment
  belongs_to :user
  belongs_to :owner, class_name: User
  belongs_to :prior_owner, class_name: User
  belongs_to :resolver, class_name: User
  validates :owner, presence: true

  scope :resolved, -> { where('resolved_at IS NOT NULL') }
  scope :unresolved, -> { where('resolved_at IS NULL') }

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

  def resolved?
    resolved_at?
  end
end
