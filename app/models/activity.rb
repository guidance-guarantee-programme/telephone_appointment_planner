class Activity < ApplicationRecord
  POLLING_KEY = 'POLL_INTERVAL_MILLISECONDS'.freeze

  belongs_to :appointment
  belongs_to :user
  belongs_to :owner, class_name: User
  belongs_to :prior_owner, class_name: User
  validates :owner, presence: true

  scope :since, -> (since) { where('created_at > ?', since) }

  def user_name
    user.try(:name) || 'Someone'
  end

  def to_partial_path
    "activities/#{model_name.singular}"
  end
end
