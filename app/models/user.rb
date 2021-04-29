class User < ApplicationRecord
  include GDS::SSO::User

  RESOURCE_MANAGER_EXCEPTIONS = %w(6f338640-808d-0133-2100-36ff48a3bf62).freeze

  ALL_PERMISSIONS = [
    ADMINISTRATOR_PERMISSION    = 'administrator'.freeze,
    PENSION_WISE_API_PERMISSION = 'pension_wise_api'.freeze,
    RESOURCE_MANAGER_PERMISSION = 'resource_manager'.freeze,
    GUIDER_PERMISSION           = 'guider'.freeze,
    AGENT_PERMISSION            = 'agent'.freeze,
    BUSINESS_ANALYST_PERMISSION = 'business_analyst'.freeze,
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
  scope :unexcluded, -> { where.not(uid: RESOURCE_MANAGER_EXCEPTIONS) }

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

  def lancs_west?
    organisation_content_id == Provider::LANCS_WEST.id
  end

  def tp_agent?
    tp? && agent?
  end

  def lloyds_signposter?
    return true if tp_agent? || administrator?

    Provider.lloyds_providers.map(&:id).include?(organisation_content_id)
  end

  def organisation
    Provider.find(organisation_content_id)&.name
  end

  def delete_future_slots!
    bookable_slots.where('start_at > ?', Time.current).delete_all
  end

  def self.guider_organisation_match?(guider, original_guider_id)
    original = find(original_guider_id)

    guider.organisation_content_id == original.organisation_content_id
  end
end
