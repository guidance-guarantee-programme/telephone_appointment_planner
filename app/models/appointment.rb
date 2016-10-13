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
           .where(start_at: start_at, end_at: end_at)
           .sample(1)
           .first
    self.guider = slot.guider if slot
  end

  private

  def not_within_two_business_days
    return unless start_at

    days_until = Time.zone.now.to_date.business_days_until(start_at)
    errors.add(:start_at, 'must be more than two business days from now') if days_until <= 2
  end

  def not_more_than_thirty_business_days_in_future
    return unless start_at

    days_until = Time.zone.now.to_date.business_days_until(start_at)
    errors.add(:start_at, 'must be less than thirty business days from now') if days_until >= 30
  end
end
