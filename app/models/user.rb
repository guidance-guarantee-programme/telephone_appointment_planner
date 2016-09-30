class User < ApplicationRecord
  include GDS::SSO::User
  serialize :permissions, Array
  RESOURCE_MANAGER_PERMISSION = 'resource_manager'.freeze
  GUIDER_PERMISSION = 'guider'.freeze

  has_many :schedules, dependent: :destroy

  has_and_belongs_to_many :groups # rubocop:disable Rails/HasAndBelongsToMany

  def self.guiders
    # This can't really be made faster because we're storing
    # permissions as a serialized string. We only really should have a maximum of
    # 50 (guiders) + 3 (resource managers) in the database though.
    User.all.select(&:guider?)
  end

  def guider?
    permissions.include?(GUIDER_PERMISSION)
  end

  def resource_manager?
    permissions.include?(RESOURCE_MANAGER_PERMISSION)
  end
end
