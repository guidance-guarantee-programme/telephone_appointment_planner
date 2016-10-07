class Appointment < ApplicationRecord
  belongs_to :user

  validates :start_at, presence: true
  validates :end_at, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone, presence: true
  validates :memorable_word, presence: true

  def assign_to_guider
    User.guiders.each do |user|
      next if user.appointments.where(start_at: start_at, end_at: end_at).any?
      usable_slot = user
                    .usable_slots
                    .exact_match(start_at, end_at)
                    .sample(1)
                    .first
      if usable_slot
        self.user = user
        break
      end
    end
  end
end
