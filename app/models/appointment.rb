# rubocop:disable Metrics/ClassLength
class Appointment < ApplicationRecord
  audited on: %i[create update]

  acts_as_copy_target

  attr_accessor :current_user, :internal_availability, :ad_hoc_start_at

  DEFAULT_COUNTRY_CODE = 'GB'.freeze

  RESCHEDULING_REASONS = %w[client_rescheduled office_rescheduled].freeze

  CANCELLED_STATUSES = %i[
    cancelled_by_customer
    cancelled_by_pension_wise
    cancelled_by_customer_sms
  ].freeze

  APPOINTMENT_LENGTH_MINUTES = 70.minutes.freeze

  FAKE_DATE_OF_BIRTH = Date.parse('1900-01-01').freeze
  ACCESSIBILITY_NOTES_CUTOFF = Date.parse('2019-09-25').freeze

  NON_NOTIFY_COLUMNS = %w[
    agent_id
    guider_id
    rescheduled_at
    notes
    status
    secondary_status
    dc_pot_confirmed
    updated_at
    type_of_appointment
    where_you_heard
    gdpr_consent
    bsl_video
    third_party_booking
    data_subject_name
    data_subject_age
    data_subject_date_of_birth
    power_of_attorney
    data_subject_consent_obtained
    printed_consent_form_required
    data_subject_consent_evidence
    power_of_attorney_evidence
    email_consent_form_required
    email_consent
    generated_consent_form
    lloyds_signposted
    unique_reference_number
    referrer
    small_pots
    country_code
    welsh
    rescheduling_reason
  ].freeze

  enum status: { pending: 0, complete: 1, no_show: 2, incomplete: 3, ineligible_age: 4,
                 ineligible_pension_type: 5, cancelled_by_customer: 6, cancelled_by_pension_wise: 7,
                 cancelled_by_customer_sms: 8 }

  AGENT_PERMITTED_SECONDARY = '15'.freeze
  SECONDARY_STATUSES = {
    'incomplete' => {
      '0' => 'Technological issue',
      '1' => 'Guider issue',
      '2' => 'Customer issue',
      '3' => 'Customer had accessibility requirement',
      '4' => 'Customer believed Pension Wise was mandatory',
      '5' => 'Customer wanted specific questions answered',
      '6' => 'Customer did not want to hear all payment options',
      '7' => 'Customer wanted advice not guidance',
      '8' => 'Customer behaviour',
      '9' => 'Other'
    },
    'ineligible_pension_type' => {
      '10' => 'DB pension only and not considering transferring',
      '11' => 'Annuity in payment only',
      '12' => 'State pension only',
      '13' => 'Overseas pension only',
      '14' => 'S32 – No GMP Excess'
    },
    'cancelled_by_customer' => {
      '15' => 'Cancelled prior to appointment',
      '16' => 'Inconvenient time',
      '17' => 'Customer forgot',
      '18' => 'Customer changed their mind',
      '19' => 'Customer not sufficiently prepared to undertake the call',
      '20' => 'Customer did not agree with data protection policy',
      '21' => 'Duplicate appointment booked by customer',
      '22' => 'Customer driving whilst having appointment',
      '23' => 'Third-party consent not received',
      '28' => 'Customer wanted PSG appointment'
    },
    'no_show' => {
      '24' => 'UK number valid – customer did not answer',
      '25' => 'UK number invalid',
      '26' => 'Overseas number valid – customer did not answer',
      '27' => 'Overseas number invalid'
    }
  }.freeze

  belongs_to :agent, class_name: 'User'

  belongs_to :guider, class_name: 'User'

  belongs_to :rebooked_from, class_name: 'Appointment', optional: true

  has_many :activities, -> { order('created_at DESC') }, dependent: :destroy

  has_many :status_transitions, dependent: :destroy

  has_one_attached :power_of_attorney_evidence
  has_one_attached :data_subject_consent_evidence
  has_one_attached :generated_consent_form

  delegate :resource_managers, to: :guider

  scope :cancelled, -> { where(status: CANCELLED_STATUSES) }
  scope :not_cancelled, -> { where.not(status: CANCELLED_STATUSES) }
  scope :with_mobile_number, -> { where("mobile like '07%' or phone like '07%'") }
  scope :not_booked_today, -> { where.not(created_at: Time.current.beginning_of_day..Time.current.end_of_day) }
  scope :for_pension_wise, -> { where(schedule_type: User::PENSION_WISE_SCHEDULE_TYPE) }
  scope :for_due_diligence, -> { where(schedule_type: User::DUE_DILIGENCE_SCHEDULE_TYPE) }

  validates :agent, presence: true
  validates :start_at, presence: true
  validates :end_at, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone, presence: true
  validates :date_of_birth, presence: true
  validates :memorable_word, presence: true
  validates :dc_pot_confirmed, inclusion: [true, false]
  validates :accessibility_requirements, inclusion: [true, false]
  validates :third_party_booking, inclusion: [true, false]
  validates :small_pots, inclusion: [true, false]
  validates :data_subject_name, presence: true, if: :third_party_booking?
  validates :data_subject_date_of_birth, presence: true, if: :require_data_subject_date_of_birth?
  validates :notes, presence: true, if: :validate_adjustment_needs?
  validates :notes, length: { maximum: 1000 }, allow_blank: true
  validates :type_of_appointment, inclusion: %w[standard 50-54]
  validates :where_you_heard, inclusion: WhereYouHeard.options_for_inclusion, on: :create, unless: :rebooked_from_id?
  validates :status, presence: true
  validates :guider, presence: true
  validates :unique_reference_number, uniqueness: true, if: :complete_due_diligence?
  validates :referrer, presence: true, if: :due_diligence?, on: :create
  validates :email, email: true, unless: :sms_confirmation?
  validates :email_consent, presence: true, email: true, if: :email_consent_form_required?

  validate :validate_printed_consent_form_address
  validate :validate_consent_type
  validate :validate_power_of_attorney_or_consent
  validate :not_within_grace_period, unless: :agent_is_resource_manager?
  validate :valid_within_booking_window
  validate :date_of_birth_valid
  validate :data_subject_date_of_birth_valid
  validate :address_or_email_valid, if: :regular_agent?, on: :create
  validate :validate_guider_organisation, on: :update
  validate :validate_guider_available, on: :update
  validate :validate_phone_digits, if: :tp_agent?
  validate :validate_mobile_digits, if: :tp_agent?
  validate :validate_secondary_status
  validate :validate_lloyds_signposted_guider_allocated, if: :lloyds_signposted?, on: :create
  validate :validate_pending_overlaps, if: :due_diligence?, on: :create
  validate :validate_signposting
  validate :validate_small_pots, if: :small_pots?
  validate :validate_tp_agent_statuses
  validate :validate_tpas_agent_statuses, if: :status_changed?, on: :update
  validate :validate_gdpr_consent
  validate :validate_rescheduling_reason, on: :update
  validate :validate_welsh_language, on: :create

  before_validation :format_name, on: :create
  before_create :track_initial_status
  before_update :track_status_transitions

  def resend_email_confirmation
    CustomerUpdateJob.perform_later(self, CustomerUpdateActivity::CONFIRMED_MESSAGE)
  end

  def resend_print_confirmation
    PrintedConfirmationJob.perform_later(self)
  end

  def internal_availability?
    internal_availability.present? && internal_availability == '1'
  end

  def print_confirmation?
    pension_wise? && address? && !email?
  end

  def sms_confirmation?
    nudge_confirmation == 'sms'
  end

  def complete_due_diligence?
    due_diligence? && complete? && unique_reference_number?
  end

  def due_diligence?
    schedule_type == User::DUE_DILIGENCE_SCHEDULE_TYPE
  end

  def pension_wise?
    schedule_type == User::PENSION_WISE_SCHEDULE_TYPE
  end

  def process_casebook!(casebook_identifier)
    without_auditing do
      transaction do
        update!(processed_at: Time.zone.now, casebook_appointment_id: casebook_identifier)

        CasebookProcessedActivity.create!(appointment: self)
      end
    end
  end

  def process_casebook_cancellation!
    CasebookCancelledActivity.create!(appointment: self)
  end

  def process!(by)
    return if processed_at?

    without_auditing do
      transaction do
        touch(:processed_at)

        ProcessedActivity.from(user: by, appointment: self)
      end
    end
  end

  def mark_rescheduled!
    self.batch_processed_at = nil
    self.rescheduled_at     = Time.zone.now
  end

  def adjustments?
    return true if accessibility_requirements? || third_party_booking?
    return false if tpas_guider?
    return true if potential_duplicates? && pension_wise?

    !dc_pot_confirmed? && pension_wise?
  end

  def address?
    [address_line_one, town, postcode].all?(&:present?)
  end

  def canonical_sms_number
    mobile.presence || phone
  end

  def potential_duplicates
    self.class.where.not(id:)
        .where(
          first_name:,
          last_name:,
          date_of_birth:,
          status: :pending
        )
        .order(:id)
        .take(10)
  end

  def potential_duplicates?
    potential_duplicates.size.positive?
  end

  def imported?
    date_of_birth == FAKE_DATE_OF_BIRTH
  end

  def name
    "#{first_name} #{last_name}"
  end

  def cancelled?
    status.start_with?('cancelled')
  end

  def allocate(via_slot: true, agent: nil, scoped: false)
    if via_slot
      allocate_slot(agent, scoped)
    else
      return unless start_at?

      self.end_at = start_at + APPOINTMENT_LENGTH_MINUTES
    end
  end

  def date_of_birth=(value)
    if value.is_a?(Hash)
      super(Date.new(value[1], value[2], value[3]))
    else
      super(value)
    end
  rescue ArgumentError
    @date_of_birth_invalid = true
  end

  def data_subject_date_of_birth=(value)
    if value.is_a?(Hash)
      super(Date.new(value[1], value[2], value[3]))
    else
      super(value)
    end
  rescue ArgumentError
    @data_subject_date_of_birth_invalid = true
  end

  def memorable_word(obscure: false)
    return super() unless obscure

    super().to_s.gsub(/(?!\A).(?!\Z)/, '*')
  end

  def can_be_rescheduled_by?(user)
    return false unless pending?
    return true if user.resource_manager? && owned_by_my_organisation?(user)
    return false if due_diligence?

    start_at >= BookableSlot.next_valid_start_date
  end

  def can_create_summary?
    complete? || ineligible_age? || ineligible_pension_type?
  end

  def summarised?
    activities.where(type: 'SummaryDocumentActivity').size.positive?
  end

  def future?
    start_at.advance(hours: -1) > Time.zone.now
  end

  def age_at_appointment
    return 0 unless date_of_birth? && start_at?

    ((start_at.to_date - date_of_birth) / 365).floor
  end

  def type_of_appointment
    return super if super.present? && persisted?
    return ''    if age_at_appointment.zero?

    age_at_appointment >= 55 ? 'standard' : '50-54'
  end

  def timezone
    start_at.in_time_zone('London').utc_offset.zero? ? 'GMT' : 'BST'
  end

  def tpas_guider?
    guider&.tpas?
  end

  def cas_guider?
    guider&.cas?
  end

  def ni_guider?
    guider&.ni?
  end

  def tp_guider?
    guider&.tp?
  end

  def casebook_pushable_guider?
    guider&.casebook_pushable?
  end

  def agent_is_pension_wise_api?
    agent&.pension_wise_api?
  end

  def unable_to_assign?
    errors.key?(:guider) || errors.key?(:start_at)
  end

  def mobile?
    phone.start_with?('07') || mobile.start_with?('07')
  end

  def owned_by_my_organisation?(myself)
    return true unless guider

    myself.organisation_content_id == guider.organisation_content_id
  end

  def cancel!
    without_auditing do
      transaction do
        update!(status: :cancelled_by_customer_sms)
        SmsCancellationActivity.from(self)
      end

      CancelCasebookAppointmentJob.perform_later(self)
    end
  end

  def customer_research_consent
    gdpr_consent == '' ? 'No response' : gdpr_consent.titleize
  end

  def copy_attachments! # rubocop:disable Metrics/AbcSize
    return unless rebooked_from_id?

    if rebooked_from.data_subject_consent_evidence.attached?
      data_subject_consent_evidence.attach(rebooked_from.data_subject_consent_evidence.blob)
    elsif rebooked_from.power_of_attorney_evidence.attached?
      power_of_attorney_evidence.attach(rebooked_from.power_of_attorney_evidence.blob)
    end
  end

  def self.secondary_status(key)
    SECONDARY_STATUSES.values.reduce(&:merge)[key] || '-'
  end

  def self.for_redaction
    where
      .not(first_name: 'redacted')
      .where('created_at < ?', 2.years.ago.beginning_of_day)
  end

  def self.for_organisation(user)
    return for_pension_wise if user.tp_agent?
    return all if user.tpas_agent?

    joins(:guider)
      .where(users: { organisation_content_id: user.organisation_content_id })
  end

  def self.copy_or_new_by(id)
    return new unless id

    find(id).dup.tap do |appointment|
      break if appointment.pending?

      appointment.start_at = nil
      appointment.end_at   = nil
      appointment.rebooked_from_id   = id
      appointment.batch_processed_at = nil
    end
  end

  def self.needing_sms_reminder
    pending
      .not_booked_today
      .where(start_at: [day_range(2), day_range(7)])
      .with_mobile_number
  end

  def self.needing_reminder
    window = 3.hours.from_now..48.hours.from_now.in_time_zone

    pending
      .not_booked_today
      .where(start_at: window)
      .where.not(email: '')
      .where.not(id: reminded_ids)
  end

  def self.reminded_ids
    window = 48.hours.ago.in_time_zone..Time.zone.now

    ReminderActivity
      .where(created_at: window)
      .pluck(:appointment_id)
  end

  def self.for_sms_cancellation(number, schedule_type: User::PENSION_WISE_SCHEDULE_TYPE)
    pending
      .where(schedule_type:)
      .order(:created_at)
      .find_by("REPLACE(mobile, ' ', '') = :number OR REPLACE(phone, ' ', '') = :number", number:)
  end

  def push_to_casebook?
    pending? && casebook_pushable_guider? && !casebook_appointment_id? && !processed_at?
  end

  private

  def track_initial_status
    status_transitions << StatusTransition.new(status:)
  end

  def track_status_transitions
    track_initial_status if status_changed?

    self.unique_reference_number = '' if status_changed?(from: 'complete') && due_diligence?
  end

  def allocate_slot(agent, scoped)
    args = agent&.tpas_agent? && pension_wise? && scoped ? { external: true } : {}

    slot = BookableSlot.find_available_slot(start_at, agent, schedule_type, scoped:, **args)
    self.guider = nil
    return unless slot

    self.end_at = slot.end_at
    self.guider = slot.guider
  end

  def format_name
    self.first_name = first_name.titleize if first_name != 'redacted'
    self.last_name  = CapitalizeNames.capitalize(last_name) if last_name
  end

  def after_audit
    Activity.from(audits.last, self)
  end

  def not_within_grace_period
    return unless new_record? && start_at?

    too_soon = start_at < BookableSlot.next_valid_start_date(nil, schedule_type)
    errors.add(:start_at, 'must be more than two business days from now') if too_soon
  end

  def valid_within_booking_window
    return unless start_at

    too_late = start_at > BusinessDays.from_now(55)
    errors.add(:start_at, 'must be less than 55 business days from now') if too_late
  end

  def data_subject_date_of_birth_valid
    return unless require_data_subject_date_of_birth?

    errors.add(:data_subject_date_of_birth, 'must be valid') if @data_subject_date_of_birth_invalid
  end

  def require_data_subject_date_of_birth?
    third_party_booking? && data_subject_age.blank?
  end

  def date_of_birth_valid
    errors.add(:date_of_birth, 'must be valid') if @date_of_birth_invalid

    errors.add(:date_of_birth, 'must be at least 1900') if date_of_birth_pre_cut_off?
  end

  def email_valid
    unless /.+@.+\..+/ === email.to_s # rubocop:disable Style/CaseEquality, Style/GuardClause
      errors.add(
        :email,
        'must be valid'
      )
    end
  end

  def address_or_email_valid
    errors.add(:email, 'Please supply either an email or confirmation address') unless address? || email?

    if email? && address? # rubocop:disable Style/GuardClause
      errors.add(:email, 'Please supply only an email or confirmation address, not both')
    end
  end

  def date_of_birth_pre_cut_off?
    date_of_birth? && date_of_birth < FAKE_DATE_OF_BIRTH
  end

  def validate_guider_organisation
    return unless guider_id_changed? && guider
    return if User.guider_organisation_match?(guider, guider_id_was)

    errors.add(:guider, 'The guider is from another provider')
  end

  def validate_guider_available
    return unless pending_from_cancelled?
    return unless existing_appointment?

    errors.add(:guider, 'The guider would be double-booked')
  end

  def pending_from_cancelled?
    CANCELLED_STATUSES.any? { |s| status_changed?(to: 'pending', from: s.to_s) }
  end

  def existing_appointment?
    self.class
        .not_cancelled
        .where(guider_id:, start_at:)
        .where.not(id:)
        .exists?
  end

  def agent_is_resource_manager?
    agent.present? && agent.resource_manager?
  end

  def agent_is_tpas_resource_manager?
    agent_is_resource_manager? && agent.tpas?
  end

  def pension_wise_api?
    agent&.pension_wise_api?
  end

  def tp_agent?
    agent&.tp_agent?
  end

  def regular_agent?
    agent && !agent.pension_wise_api?
  end

  def cita?
    guider&.cita?
  end

  def validate_adjustment_needs?
    date = created_at || Time.zone.today

    accessibility_requirements? && date > ACCESSIBILITY_NOTES_CUTOFF
  end

  def validate_phone_digits
    return if phone.blank?

    errors.add(:phone, 'must have at least 10 digits') if phone.gsub(/[^\d]/, '').length < 10
  end

  def validate_mobile_digits
    return if mobile.blank?

    errors.add(:mobile, 'must have at least 10 digits') if mobile.gsub(/[^\d]/, '').length < 10
  end

  def validate_printed_consent_form_address
    return unless third_party_booking? && printed_consent_form_required?

    errors.add(:printed_consent_form_required, 'must supply a valid address') unless printed_consent_address?
  end

  def validate_power_of_attorney_or_consent
    return unless third_party_booking?

    if printed_consent_form_required? && power_of_attorney?
      errors.add(:printed_consent_form_required, 'cannot be checked when power of attorney is specified')
    end

    if email_consent_form_required? && power_of_attorney? # rubocop:disable Style/GuardClause
      errors.add(:email_consent_form_required, 'cannot be checked when power of attorney is specified')
    end
  end

  def validate_consent_type
    return unless third_party_booking?

    if power_of_attorney? && data_subject_consent_obtained? # rubocop:disable Style/GuardClause
      errors.add(
        :third_party_booking,
        "you may only specify 'data subject consent obtained', 'power of attorney' or neither"
      )
    end
  end

  def email_consent_valid
    unless /.+@.+\..+/ === email_consent.to_s # rubocop:disable Style/CaseEquality, Style/GuardClause
      errors.add(:email_consent, 'must be valid')
    end
  end

  def printed_consent_address?
    [consent_address_line_one, consent_town, consent_postcode].all?(&:present?)
  end

  def validate_secondary_status # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    return if no_show? && created_at < Time.zone.parse(ENV.fetch('SECONDARY_STATUS_CUT_OFF') { '2021-05-04 09:00' })

    return if current_user&.tpas_agent? && !guider.tpas?

    return unless (matches = SECONDARY_STATUSES[status]) && !matches.key?(secondary_status)

    errors.add(:secondary_status, 'must be provided for the chosen status')
  end

  def validate_tp_agent_statuses
    if current_user&.tp_agent? && cancelled_by_customer? && secondary_status != AGENT_PERMITTED_SECONDARY # rubocop:disable Style/GuardClause
      errors.add(:secondary_status, "Contact centre agents should only select 'Cancelled prior to appointment'")
    end
  end

  def validate_tpas_agent_statuses # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
    if current_user&.tpas_agent? && !guider.tpas? # rubocop:disable Style/GuardClause
      unless ineligible_age? || ineligible_pension_type? || cancelled_by_customer?
        errors.add(:status, "Must be one of 'Ineligible Age', 'Ineligible Pension Type', 'Cancelled by Customer'")
      end

      return unless cancelled_by_customer? && secondary_status != AGENT_PERMITTED_SECONDARY

      errors.add(
        :secondary_status,
        "For external appointments, agents should only select 'Cancelled prior to appointment'"
      )

    end
  end

  def validate_lloyds_signposted_guider_allocated
    errors.add(:guider, 'The guider is not from an LBGPTL schedule') unless cita?
  end

  def validate_pending_overlaps # rubocop:disable Metrics/MethodLength
    return unless self
                  .class
                  .pending
                  .where(guider_id:)
                  .where(
                    '(start_at BETWEEN :start_at AND :end_at) OR (end_at BETWEEN :start_at AND :end_at)',
                    start_at:,
                    end_at:
                  )
                  .where.not(id:)
                  .exists?

    errors.add(:guider_id, 'Overlaps another pending appointment')
  end

  def validate_signposting
    message = 'Cannot be both Stronger Nudge and Lloyds Banking Group signposted'

    errors.add(:nudged, message) if nudged? && lloyds_signposted?
  end

  def validate_small_pots
    message = 'Small pots appointments may only be assigned to TPAS guiders'

    errors.add(:small_pots, message) unless guider&.tpas?
  end

  def validate_gdpr_consent
    inclusion = %w[yes no]
    inclusion << '' if persisted? || due_diligence?

    errors.add(:gdpr_consent, :inclusion) unless inclusion.include?(gdpr_consent)
  end

  def validate_rescheduling_reason
    return unless start_at_changed?

    errors.add(:rescheduling_reason, 'must be specified') unless RESCHEDULING_REASONS.include?(rescheduling_reason)
  end

  def validate_welsh_language
    return unless welsh? && guider

    errors.add(:welsh, 'cannot be set for external availability') unless guider.tpas? || guider.cardiff_and_vale?
  end

  class << self
    private

    def day_range(days_from)
      days_from.days.from_now.beginning_of_day.in_time_zone..days_from.days.from_now.end_of_day.in_time_zone
    end
  end
end

module Models
  Appointment = ::Appointment
end
# rubocop:enable Metrics/ClassLength
