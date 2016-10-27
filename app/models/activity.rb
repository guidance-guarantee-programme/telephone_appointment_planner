class Activity < ApplicationRecord
  POLLING_KEY = 'POLL_INTERVAL_MILLISECONDS'.freeze

  belongs_to :appointment
  belongs_to :user

  scope :since, -> (since) { where('created_at > ?', since) }

  def owner_name
    user.try(:name) || 'Someone'
  end

  def to_partial_path
    "activities/#{model_name.singular}"
  end
end
