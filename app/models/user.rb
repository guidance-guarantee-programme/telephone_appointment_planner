class User < ApplicationRecord
  include GDS::SSO::User

  ALL_ORGANISATIONS = [
    TPAS_ORGANISATION_ID = '14a48488-a42f-422d-969d-526e30922fe4'.freeze,
    TP_ORGANISATION_ID   = '41075b50-6385-4e8b-a17d-a7b9aae5d220'.freeze,
    CAS_ORGANISATION_ID  = '0c686436-de02-4d92-8dc7-26c97bb7c5bb'.freeze,
    NI_ORGANISATION_ID   = '1de9b76c-c349-4e2a-a3a7-bb0f59b0807e'.freeze,
    CITA_WALLSEND_ID     = 'b805d50f-2f56-4dc7-a3cd-0e3ef2ce1e6e'.freeze,
    CITA_LANCS_WEST      = 'c554946e-7b79-4446-b2cd-d930f668e54b'.freeze
  ].freeze

  BANK_HOLIDAY_OBSERVING_ORGANISATIONS = [
    TPAS_ORGANISATION_ID,
    TP_ORGANISATION_ID,
    NI_ORGANISATION_ID,
    CITA_WALLSEND_ID,
    CITA_LANCS_WEST
  ].freeze

  ORGANISATIONS = {
    TPAS_ORGANISATION_ID => 'TPAS'.freeze,
    TP_ORGANISATION_ID   => 'TP'.freeze,
    CAS_ORGANISATION_ID  => 'CAS'.freeze,
    NI_ORGANISATION_ID   => 'NI'.freeze,
    CITA_WALLSEND_ID     => 'CITA Wallsend'.freeze,
    CITA_LANCS_WEST      => 'CITA Lancs West'.freeze
  }.freeze

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
  scope :enabled, -> { where(disabled: false) }

  ALL_PERMISSIONS.each do |permission|
    define_method "#{permission}?" do
      has_permission?(permission)
    end
  end

  def resource_managers
    colleagues
      .where('permissions @> ?', %(["#{RESOURCE_MANAGER_PERMISSION}"]))
      .enabled
      .active
  end

  def tp?
    organisation_content_id == TP_ORGANISATION_ID
  end

  def tpas?
    organisation_content_id == TPAS_ORGANISATION_ID
  end

  def tp_agent?
    tp? && agent?
  end

  def organisation
    ORGANISATIONS[organisation_content_id].to_s
  end

  def delete_future_slots!
    bookable_slots.where('start_at > ?', Time.current).delete_all
  end

  def self.guider_organisation_match?(guider, original_guider_id)
    original = find(original_guider_id)

    guider.organisation_content_id == original.organisation_content_id
  end
end
