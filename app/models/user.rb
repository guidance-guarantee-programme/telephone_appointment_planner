class User < ApplicationRecord
  include GDS::SSO::User

  RESOURCE_MANAGER_PERMISSION = 'resource_manager'.freeze
  GUIDER_PERMISSION = 'guider'.freeze
  AGENT_PERMISSION = 'agent'.freeze

  default_scope { order(:name) }

  has_many :schedules, dependent: :destroy
  has_many :bookable_slots
  has_many :appointments, foreign_key: :guider_id
  has_many :holidays

  has_many :group_assignments
  has_many :groups, through: :group_assignments

  def self.guiders
    # This can't really be made faster because we're storing
    # permissions as a serialized string. We only really should have a maximum of
    # 50 (guiders) + 3 (resource managers) in the database though.
    select(&:guider?)
  end

  def guider?
    has_permission?(GUIDER_PERMISSION)
  end

  def resource_manager?
    has_permission?(RESOURCE_MANAGER_PERMISSION)
  end

  def agent?
    has_permission?(AGENT_PERMISSION)
  end
end
