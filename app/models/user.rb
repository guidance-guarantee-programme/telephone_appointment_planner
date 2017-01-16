class User < ApplicationRecord
  include GDS::SSO::User

  ALL_PERMISSIONS = [
    PENSION_WISE_API_PERMISSION = 'pension_wise_api'.freeze,
    RESOURCE_MANAGER_PERMISSION = 'resource_manager'.freeze,
    GUIDER_PERMISSION           = 'guider'.freeze,
    AGENT_PERMISSION            = 'agent'.freeze,
    CONTACT_CENTRE_TEAM_LEADER_PERMISSION = 'contact_centre_team_leader'.freeze
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
  scope :active, -> { where(active: true) }

  def guider?
    has_permission?(GUIDER_PERMISSION)
  end

  def resource_manager?
    has_permission?(RESOURCE_MANAGER_PERMISSION)
  end

  def agent?
    has_permission?(AGENT_PERMISSION)
  end

  def contact_centre_team_leader?
    has_permission?(CONTACT_CENTRE_TEAM_LEADER_PERMISSION)
  end

  def pension_wise_api?
    has_permission?(PENSION_WISE_API_PERMISSION)
  end
end
