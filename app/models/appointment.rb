# rubocop:disable Metrics/ClassLength
class Appointment < ApplicationRecord
  acts_as_copy_target

  FAKE_DATE_OF_BIRTH = Date.parse('1900-01-01').freeze

  NON_NOTIFY_COLUMNS = %w(
    agent_id
    guider_id
    notes
    opt_out_of_market_research
    status
    dc_pot_confirmed
    updated_at
    type_of_appointment
    where_you_heard
  ).freeze

  belongs_to :agent, class_name: 'User'

  enum status: %i(
    pending
    complete
    no_show
    incomplete
    ineligible_age
    ineligible_pension_type
    cancelled_by_customer
    cancelled_by_pension_wise
  )

  belongs_to :guider, class_name: 'User'

  belongs_to :rebooked_from, class_name: 'Appointment'

  scope :cancelled, -> { where(status: %i(cancelled_by_customer cancelled_by_pension_wise)) }
  scope :not_cancelled, -> { where.not(status: %i(cancelled_by_customer cancelled_by_pension_wise)) }
  scope :with_mobile_number, -> { where("mobile != '' or phone like '07%'") }

  def self.needing_sms_reminder
    window = 2.days.from_now.beginning_of_day..2.days.from_now.end_of_day

    pending
      .where(start_at: window)
      .with_mobile_number
  end

  def self.needing_reminder
    window = Time.zone.now..48.hours.from_now.in_time_zone

    pending
      .where(start_at: window)
      .where.not(email: '', id: reminded_ids)
  end

  def self.reminded_ids
    window = 48.hours.ago.in_time_zone..Time.zone.now

    ReminderActivity
      .where(created_at: window)
      .pluck(:appointment_id)
  end

  validates :agent, presence: true
  validates :start_at, presence: true
  validates :end_at, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone, presence: true
  validates :date_of_birth, presence: true
  validates :memorable_word, presence: true
  validates :dc_pot_confirmed, inclusion: [true, false]
  validates :type_of_appointment, inclusion: %w(standard 50-54)
  validates :where_you_heard, inclusion: WhereYouHeard.options_for_inclusion, on: :create, unless: :rebooked_from_id?

  validates :status, presence: true
  validates :guider, presence: true

  validate :not_within_two_business_days, unless: :agent_is_resource_manager?
  validate :valid_within_booking_window
  validate :date_of_birth_valid
  validate :email_valid, if: :agent_is_pension_wise_api?, on: :create

  has_many :activities, -> { order('created_at DESC') }

  audited on: %i(create update)

  before_validation :format_name, on: :create

  def self.copy_or_new_by(id)
    return new unless id

    find(id).dup.tap do |appointment|
      break if appointment.pending?

      appointment.start_at = nil
      appointment.end_at   = nil
      appointment.rebooked_from_id = id
    end
  end

  def canonical_sms_number
    mobile.present? ? mobile : phone
  end

  def potential_duplicates
    self.class.where.not(id: id)
        .where(
          first_name: first_name,
          last_name: last_name,
          start_at: start_at.beginning_of_day..start_at.end_of_day
        )
        .order(:id)
        .pluck(:id)
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

  def assign_to_guider
    slot = BookableSlot.find_available_slot(start_at)
    self.guider = nil
    return unless slot
    self.end_at = slot.end_at
    self.guider = slot.guider
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

  def memorable_word(obscure: false)
    return super() unless obscure

    super().to_s.gsub(/(?!\A).(?!\Z)/, '*')
  end

  def can_be_rescheduled_by?(user)
    user.resource_manager? || start_at >= BusinessDays.from_now(2)
  end

  def can_create_summary?
    complete? || ineligible_age? || ineligible_pension_type?
  end

  def future?
    start_at > Time.zone.now
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

  def agent_is_pension_wise_api?
    agent && agent.pension_wise_api?
  end

  private

  def format_name
    self.first_name = first_name.titleize if first_name
    self.last_name  = last_name.titleize  if last_name
  end

  def after_audit
    Activity.from(audits.last, self)
  end

  def not_within_two_business_days
    return unless new_record? && start_at?

    too_soon = start_at < BookableSlot.next_valid_start_date
    errors.add(:start_at, 'must be more than two business days from now') if too_soon
  end

  def valid_within_booking_window
    return unless start_at

    too_late = start_at > BusinessDays.from_now(40)
    errors.add(:start_at, 'must be less than 40 business days from now') if too_late
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

  def date_of_birth_pre_cut_off?
    date_of_birth? && date_of_birth < FAKE_DATE_OF_BIRTH
  end

  def agent_is_resource_manager?
    agent.present? && agent.resource_manager?
  end
end

module Models
  Appointment = ::Appointment
end
