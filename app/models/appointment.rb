class Appointment < ApplicationRecord
  belongs_to :user

  validates :start_at, presence: true
  validates :end_at, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone, presence: true
  validates :memorable_word, presence: true

  def assign_to_guider
    slot = UsableSlot
           .without_appointments
           .where(start_at: start_at, end_at: end_at)
           .sample(1)
           .first
    self.user = slot.user if slot
  end
end
