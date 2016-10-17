class AppointmentAttempt < ApplicationRecord
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :date_of_birth, presence: true

  def eligible?
    defined_contribution_pot? && ((date_of_birth + 50.years) < Time.zone.today)
  end
end
