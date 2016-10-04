class User < ApplicationRecord
  include GDS::SSO::User
  serialize :permissions, Array
  RESOURCE_MANAGER_PERMISSION = 'resource_manager'.freeze
  GUIDER_PERMISSION = 'guider'.freeze
  CONTACT_CENTRE_AGENT_PERMISSION = 'contact_centre_agent'.freeze

  has_many :schedules, dependent: :destroy
  has_many :appointments

  has_many :group_assignments
  has_many :groups, through: :group_assignments

  def self.guiders
    # This can't really be made faster because we're storing
    # permissions as a serialized string. We only really should have a maximum of
    # 50 (guiders) + 3 (resource managers) in the database though.
    User.includes(:groups).all.select(&:guider?)
  end

  def guider?
    permissions.include?(GUIDER_PERMISSION)
  end

  def resource_manager?
    permissions.include?(RESOURCE_MANAGER_PERMISSION)
  end

  def contact_centre_agent?
    permissions.include?(CONTACT_CENTRE_AGENT_PERMISSION)
  end
end
