class User < ApplicationRecord
  include GDS::SSO::User

  TPAS_ORGANISATION_ID = '14a48488-a42f-422d-969d-526e30922fe4'.freeze
  TP_ORGANISATION_ID   = '41075b50-6385-4e8b-a17d-a7b9aae5d220'.freeze

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
  has_many :colleagues, class_name: 'User', primary_key: :organisation_content_id, foreign_key: :organisation_content_id

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
