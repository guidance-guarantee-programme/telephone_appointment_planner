class User < ApplicationRecord
  include GDS::SSO::User

  ALL_PERMISSIONS = [
    RESOURCE_MANAGER_PERMISSION = 'resource_manager'.freeze,
    GUIDER_PERMISSION = 'guider'.freeze,
    AGENT_PERMISSION = 'agent'.freeze
  ].freeze

  default_scope { order(:position, :name) }

  has_many :schedules, dependent: :destroy
  has_many :bookable_slots, dependent: :destroy, foreign_key: :guider_id
  has_many :appointments, foreign_key: :guider_id
  has_many :holidays, dependent: :destroy

  has_many :group_assignments
  has_many :groups, through: :group_assignments
  has_many :activities, -> { order('created_at DESC') }, foreign_key: :owner_id

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
