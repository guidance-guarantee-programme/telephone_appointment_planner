class Appointment < ApplicationRecord
  belongs_to :user

  validates :user, presence: true
  validates :start_at, presence: true
  validates :end_at, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :phone, presence: true
  validates :memorable_word, presence: true

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def assign_random_guider
    User.guiders.shuffle.each do |guider|
      day = start_at
      already_assigned = guider.appointments.any? do |appointment|
        appointment.start_at == start_at &&
          appointment.end_at == end_at
      end
      next if already_assigned

      active_schedule = guider
                        .schedules
                        .order(:start_at)
                        .where('schedules.start_at < ?', day)
                        .last

      next unless active_schedule.present?

      available = active_schedule.slots.any? do |slot|
        slot.valid_for_appointment(self)
      end

      if available
        self.user = guider
        break
      end
    end
  end
end
