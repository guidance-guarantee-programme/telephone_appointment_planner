class Appointment < ApplicationRecord
  include PgSearch

  pg_search_scope :search, against: %i(id first_name last_name), associated_against: { guider: :name }

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

  validate :not_within_two_business_days
  validate :not_more_than_thirty_business_days_in_future
  validate :date_of_birth_valid

  has_many :activities, -> { order('created_at DESC') }

  audited on: %i(create update)

  def self.copy_or_new_by(id)
    return new unless id

    find(id).dup.tap do |appointment|
      appointment.start_at = nil
      appointment.end_at   = nil
      appointment.rebooked_from_id = id
    end
  end

  def self.full_search(query, start_at, end_at)
    results = query.present? ? search(query) : order(created_at: :desc)

    if start_at && end_at
      results = results
                .where('start_at > ?', start_at)
                .where('end_at < ?', end_at)
    end
    results
  end

  def name
    "#{first_name} #{last_name}"
  end

  def cancelled?
    status.start_with?('cancelled')
  end

  def assign_to_guider
    slot = BookableSlot
           .without_appointments
           .without_holidays
           .where(start_at: start_at, end_at: end_at)
           .sample(1)
           .first
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

  private

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
  end
end
