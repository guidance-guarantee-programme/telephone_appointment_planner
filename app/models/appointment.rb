class Appointment < ApplicationRecord
  belongs_to :guider, class_name: 'User'

  validates :start_at, presence: true
  validates :end_at, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone, presence: true
  validates :memorable_word, presence: true
  validates :where_did_you_hear_about_pension_wise, presence: true

  validate :not_within_two_business_days
  validate :not_more_than_thirty_business_days_in_future

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
