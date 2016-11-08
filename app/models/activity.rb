class Activity < ApplicationRecord
  belongs_to :appointment
  belongs_to :user
  belongs_to :owner, class_name: User
  belongs_to :prior_owner, class_name: User
  validates :owner, presence: true

  def user_name
    user.try(:name) || 'Someone'
  end

  def to_partial_path
    "activities/#{model_name.singular}"
  end
end
