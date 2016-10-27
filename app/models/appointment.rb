class Appointment < ApplicationRecord
  include PgSearch

  pg_search_scope :search, against: %i(id first_name last_name)

  enum status: %i(
    pending
    completed
    no_show
    ineligible_age
    ineligible_pension_type
    cancelled_by_customer
    cancelled_by_pension_wise
  )

  belongs_to :guider, class_name: 'User'

  validates :start_at, presence: true
  validates :end_at, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone, presence: true
  validates :memorable_word, presence: true
  validates :where_did_you_hear_about_pension_wise, presence: true
  validates :status, presence: true

  validate :not_within_two_business_days
  validate :not_more_than_thirty_business_days_in_future

  has_many :activities, -> { order('created_at DESC') }

  audited on: :update

  def self.full_search(query, start_at, end_at)
    results = all
    results = results.search(query) if query.present?
    if start_at && end_at
      results = results
                .where('start_at > ?', start_at)
                .where('end_at < ?', end_at)
    end
    results
  end

  def assign_to_guider
    slot = BookableSlot
           .without_appointments
           .without_holidays
           .where(start_at: start_at, end_at: end_at)
           .sample(1)
           .first
    self.guider = slot.guider if slot
  end

  private

  def after_audit
    AuditActivity.from(audits.last, self)
  end

  def not_within_two_business_days
    return unless start_at

    too_soon = start_at < BusinessDays.from_now(2)
    errors.add(:start_at, 'must be more than two business days from now') if too_soon
  end

  def not_more_than_thirty_business_days_in_future
    return unless start_at

    too_late = start_at > BusinessDays.from_now(30)
    errors.add(:start_at, 'must be less than thirty business days from now') if too_late
  end
end
