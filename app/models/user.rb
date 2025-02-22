class User < ApplicationRecord # rubocop:disable Metrics/ClassLength
  include GDS::SSO::User

  RESOURCE_MANAGER_EXCEPTIONS = %w[6f338640-808d-0133-2100-36ff48a3bf62].freeze

  ALL_PERMISSIONS = [
    SIGNIN_PERMISSION           = 'signin'.freeze,
    ADMINISTRATOR_PERMISSION    = 'administrator'.freeze,
    PENSION_WISE_API_PERMISSION = 'pension_wise_api'.freeze,
    RESOURCE_MANAGER_PERMISSION = 'resource_manager'.freeze,
    GUIDER_PERMISSION           = 'guider'.freeze,
    AGENT_PERMISSION            = 'agent'.freeze,
    BUSINESS_ANALYST_PERMISSION = 'business_analyst'.freeze,
    USER_UPDATE_PERMISSION      = 'user_update_permission'.freeze,
    CONTACT_CENTRE_TEAM_LEADER_PERMISSION = 'contact_centre_team_leader'.freeze
  ].freeze

  ALL_SCHEDULE_TYPES = [
    PENSION_WISE_SCHEDULE_TYPE  = 'pension_wise'.freeze,
    DUE_DILIGENCE_SCHEDULE_TYPE = 'due_diligence'.freeze
  ].freeze

  after_update :terminate_guider_availability

  default_scope { order(:position, :name) }

  has_many :schedules, dependent: :destroy
  has_many :bookable_slots, dependent: :destroy, foreign_key: :guider_id
  has_many :appointments, foreign_key: :guider_id, dependent: :destroy
  has_many :holidays, dependent: :destroy

  has_many :group_assignments, dependent: :destroy
  has_many :groups, through: :group_assignments
  has_many :activities, -> { order('created_at DESC') }, foreign_key: :owner_id, dependent: :destroy
  has_many :colleagues, class_name: 'User', primary_key: :organisation_content_id,
                        foreign_key: :organisation_content_id

  scope :guiders, -> { where('permissions @> ?', %(["#{GUIDER_PERMISSION}"])) }
  scope :active, -> { where(active: true) }
  scope :enabled, -> { where(disabled: false) }
  scope :unexcluded, -> { where.not(uid: RESOURCE_MANAGER_EXCEPTIONS) }

  ALL_PERMISSIONS.each do |permission|
    define_method "#{permission}?" do
      has_permission?(permission)
    end
  end

  def casebook_pushable?
    casebook_guider_id? && casebook_location_id?
  end

  def resource_managers
    colleagues
      .where('permissions @> ?', %(["#{RESOURCE_MANAGER_PERMISSION}"]))
      .enabled
      .unexcluded
  end

  def tp?
    organisation_content_id == Provider::TP.id
  end

  def tpas?
    organisation_content_id == Provider::TPAS.id
  end

  def cas?
    organisation_content_id == Provider::CAS.id
  end

  def ni?
    organisation_content_id == Provider::NI.id
  end

  def lancashire_west?
    organisation_content_id == Provider::LANCS_WEST.id
  end

  def cita?
    Provider.find(organisation_content_id)&.cita?
  end

  def cardiff_and_vale?
    organisation_content_id == Provider::CARDIFF_AND_VALE.id
  end

  def tp_agent?
    tp? && agent?
  end

  def tpas_guider?
    tpas? && guider?
  end

  def tpas_agent?
    tpas? && (guider? || resource_manager?)
  end

  def tpas_resource_manager?
    tpas? && resource_manager?
  end

  def non_tpas_resource_manager?
    !tpas? && resource_manager?
  end

  def lloyds_signposter?
    return true if tp_agent? || administrator?

    cita?
  end

  def organisation
    Provider.find(organisation_content_id)&.name
  end

  def delete_future_slots!
    bookable_slots.where('start_at > ?', Time.current).delete_all
  end

  def due_diligence?
    schedule_type == DUE_DILIGENCE_SCHEDULE_TYPE
  end

  def self.guider_organisation_match?(guider, original_guider_id)
    original = find(original_guider_id)

    guider.organisation_content_id == original.organisation_content_id
  end

  protected

  def terminate_guider_availability
    return unless permissions_previously_changed?
    return unless permission_revoked?(GUIDER_PERMISSION) || permission_revoked?(SIGNIN_PERMISSION)

    transaction do
      update!(active: false)
      delete_future_slots!
    end
  end

  def permission_revoked?(permission)
    permissions_previous_change.first.include?(permission) &&
      permissions_previous_change.last.exclude?(permission)
  end
end
