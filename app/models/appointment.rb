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
      already_assigned = guider.appointments.any? do |appointment|
        appointment.start_at == start_at &&
          appointment.end_at == end_at
      end
      next if already_assigned

      active_schedule = guider
                        .schedules
                        .active(start_at)

      next unless active_schedule.present?

      slot = active_schedule.slots.find_by(
        day_of_week: start_at.wday,
        start_hour: start_at.hour,
        start_minute: start_at.min,
        end_hour: end_at.hour,
        end_minute: end_at.min
      )

      if slot.present?
        self.user = guider
        break
      end
    end
  end
end
