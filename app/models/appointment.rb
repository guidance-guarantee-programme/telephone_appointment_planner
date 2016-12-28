# rubocop:disable Metrics/ClassLength
class Appointment < ApplicationRecord
  FAKE_DATE_OF_BIRTH = Date.parse('1900-01-01').freeze

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

  belongs_to :rebooked_from, class_name: Appointment

  scope :cancelled, -> { where(status: %i(cancelled_by_customer cancelled_by_pension_wise)) }
  scope :not_cancelled, -> { where.not(status: %i(cancelled_by_customer cancelled_by_pension_wise)) }

  def self.needing_reminder
    pending
      .includes(:activities)
      .where(start_at: Time.zone.now..24.hours.from_now)
      .where.not(
        email: nil,
        activities: {
          type: 'ReminderActivity', created_at: 12.hours.ago..12.hours.from_now
        }
      )
  end

  validates :agent, presence: true
  validates :start_at, presence: true
  validates :end_at, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone, presence: true
  validates :date_of_birth, presence: true
  validates :memorable_word, presence: true
  validates :status, presence: true
  validates :guider, presence: true

  validate :not_within_two_business_days, unless: :agent_is_resource_manager?
  validate :not_more_than_thirty_business_days_in_future
  validate :date_of_birth_valid

  has_many :activities, -> { order('created_at DESC') }

  audited on: %i(create update)

  before_validation :format_name

  def self.copy_or_new_by(id)
    return new unless id

    find(id).dup.tap do |appointment|
      appointment.start_at = nil
      appointment.end_at   = nil
      appointment.rebooked_from_id = id
    end
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
    slot = BookableSlot.find_available_slot(start_at, end_at)
    self.guider = nil
    self.guider = slot.guider if slot
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

    too_soon = start_at < BusinessDays.from_now(2)
    errors.add(:start_at, 'must be more than two business days from now') if too_soon
  end

  def not_more_than_thirty_business_days_in_future
    return unless start_at

    too_late = start_at > BusinessDays.from_now(30)
    errors.add(:start_at, 'must be less than thirty business days from now') if too_late
  end

  def date_of_birth_valid
    errors.add(:date_of_birth, 'must be valid') if @date_of_birth_invalid

    errors.add(:date_of_birth, 'must be at least 1900') if date_of_birth_pre_cut_off?
  end

  def date_of_birth_pre_cut_off?
    date_of_birth? && date_of_birth < FAKE_DATE_OF_BIRTH
  end

  def agent_is_resource_manager?
    agent.present? && agent.resource_manager?
  end
end
