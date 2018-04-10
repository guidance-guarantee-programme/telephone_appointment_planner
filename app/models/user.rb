class User < ApplicationRecord
  include GDS::SSO::User

  ALL_ORGANISATIONS = [
    TPAS_ORGANISATION_ID = '14a48488-a42f-422d-969d-526e30922fe4'.freeze,
    TP_ORGANISATION_ID   = '41075b50-6385-4e8b-a17d-a7b9aae5d220'.freeze,
    CAS_ORGANISATION_ID  = '272e2a93-c7f5-43f7-bd40-c21bddb2d56b'.freeze
  ].freeze

  ALL_PERMISSIONS = [
    ADMINISTRATOR_PERMISSION    = 'administrator'.freeze,
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

  ALL_PERMISSIONS.each do |permission|
    define_method "#{permission}?" do
      has_permission?(permission)
    end
  end

  def tp?
    organisation_content_id == TP_ORGANISATION_ID
  end

  def tp_agent?
    tp? && agent?
  end
end
