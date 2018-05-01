# rubocop:disable Metrics/ClassLength
class Appointment < ApplicationRecord
  audited on: %i(create update)

  acts_as_copy_target

  APPOINTMENT_LENGTH_MINUTES = 70.minutes.freeze

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

  enum status: %i(
    pending
    complete
    no_show
    incomplete
    ineligible_age
    ineligible_pension_type
    cancelled_by_customer
    cancelled_by_pension_wise
    cancelled_by_customer_sms
  )

  belongs_to :agent, class_name: 'User'

  belongs_to :guider, class_name: 'User'

  belongs_to :rebooked_from, class_name: 'Appointment'

  has_many :activities, -> { order('created_at DESC') }

  has_many :status_transitions

  attr_accessor :ad_hoc_start_at

  scope :cancelled, -> { where(status: %i(cancelled_by_customer cancelled_by_pension_wise)) }
  scope :not_cancelled, -> { where.not(status: %i(cancelled_by_customer cancelled_by_pension_wise)) }
  scope :with_mobile_number, -> { where("mobile != '' or phone like '07%'") }

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

  validate :not_within_grace_period, unless: :agent_is_resource_manager?
  validate :valid_within_booking_window
  validate :not_during_guider_conference
  validate :date_of_birth_valid
  validate :email_valid, if: :pension_wise_api?, on: :create
  validate :address_or_email_valid, if: :regular_agent?, on: :create

  before_validation :format_name, on: :create
  before_create :track_initial_status
  before_update :track_status_transitions

  def mark_rescheduled!
    self.batch_processed_at = nil
    self.rescheduled_at     = Time.zone.now
  end

  def address?
    [address_line_one, town, postcode].all?(&:present?)
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

  def allocate(via_slot: true)
    if via_slot
      allocate_slot
    else
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

  def agent_is_pension_wise_api?
    agent && agent.pension_wise_api?
  end

  def unable_to_assign?
    errors.key?(:guider) || errors.key?(:start_at)
  end

  def mark_batch_processed!
    transaction do
      touch(:batch_processed_at)

      PrintBatchActivity.from(self)
    end
  end

  def cancel!
    without_auditing do
      transaction do
        update!(status: :cancelled_by_customer_sms)

        SmsCancellationActivity.from(self)
      end
    end
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

  def self.needing_print_confirmation
    pending
      .where(batch_processed_at: nil, email: '')
      .where.not(address_line_one: '')
  end

  def self.needing_sms_reminder
    window = 2.days.from_now.beginning_of_day..2.days.from_now.end_of_day

    pending
      .where(start_at: window)
      .with_mobile_number
  end

  def self.needing_reminder
    window = 3.hours.from_now..48.hours.from_now.in_time_zone

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

  def self.for_sms_cancellation(number)
    pending
      .order(created_at: :desc)
      .find_by("REPLACE(mobile, ' ', '') = :number OR REPLACE(phone, ' ', '') = :number", number: number)
  end

  private

  def track_initial_status
    status_transitions << StatusTransition.new(status: status)
  end

  def track_status_transitions
    track_initial_status if status_changed?
  end

  def allocate_slot
    slot = BookableSlot.find_available_slot(start_at)
    self.guider = nil
    return unless slot

    self.end_at = slot.end_at
    self.guider = slot.guider
  end

  def format_name
    self.first_name = first_name.titleize if first_name
    self.last_name  = last_name.titleize  if last_name
  end

  def after_audit
    Activity.from(audits.last, self)
  end

  def not_during_guider_conference
    return unless start_at

    if BookableSlot::GUIDER_CONFERENCE_DAYS.cover?(start_at.to_date) # rubocop:disable Style/GuardClause
      errors.add(:start_at, 'must not be during the guider conference')
    end
  end

  def not_within_grace_period
    return unless new_record? && start_at?

    too_soon = start_at < BookableSlot.next_valid_start_date
    errors.add(:start_at, 'must be more than one business day from now') if too_soon
  end

  def valid_within_booking_window
    return unless start_at

    too_late = start_at > BusinessDays.from_now(45)
    errors.add(:start_at, 'must be less than 45 business days from now') if too_late
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
    unless address? || email?
      errors.add(:email, 'Please supply either an email or confirmation address')
    end

    if email? && address? # rubocop:disable GuardClause
      errors.add(:email, 'Please supply only an email or confirmation address, not both')
    end
  end

  def date_of_birth_pre_cut_off?
    date_of_birth? && date_of_birth < FAKE_DATE_OF_BIRTH
  end

  def agent_is_resource_manager?
    agent.present? && agent.resource_manager?
  end

  def pension_wise_api?
    agent&.pension_wise_api?
  end

  def regular_agent?
    agent && !agent.pension_wise_api?
  end
end

module Models
  Appointment = ::Appointment
end
