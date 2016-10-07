class Appointment < ApplicationRecord
  has_one :usable_slot

  validates :start_at, presence: true
  validates :end_at, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone, presence: true
  validates :memorable_word, presence: true

  def assign_random_usable_slot
    self.usable_slot = UsableSlot
                       .exact_match(start_at, end_at)
                       .usable
                       .sample(1)
                       .first
  end
end
