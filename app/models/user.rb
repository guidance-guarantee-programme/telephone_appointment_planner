class User < ApplicationRecord
  include GDS::SSO::User

  RESOURCE_MANAGER_PERMISSION = 'resource_manager'.freeze
  GUIDER_PERMISSION = 'guider'.freeze
  AGENT_PERMISSION = 'agent'.freeze

  default_scope { order(:name) }

  has_many :schedules, dependent: :destroy
  has_many :bookable_slots, dependent: :destroy
  has_many :appointments, foreign_key: :guider_id
  has_many :holidays

  has_many :group_assignments
  has_many :groups, through: :group_assignments

  scope :guiders, -> { where('permissions @> ?', %(["#{GUIDER_PERMISSION}"])) }

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
