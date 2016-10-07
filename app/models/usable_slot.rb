class UsableSlot < ApplicationRecord
  belongs_to :user

  def self.exact_match(start_at, end_at)
    where(start_at: start_at, end_at: end_at)
  end

  def self.regenerate_for_six_weeks
    User.guiders.each do |user|
      generate_for_guider(user)
    end
  end

  def self.within_date_range(from, to)
    where('usable_slots.start_at > ? AND usable_slots.end_at < ?', from, to)
  end

  def self.usable
    where(appointment_id: nil)
  end

  # rubocop:disable Metrics/MethodLength
  def self.with_guider_count(from, to)
    UsableSlot
      .select('DISTINCT usable_slots.start_at, usable_slots.end_at, count(1) AS guiders')
      .joins(<<-SQL
              LEFT JOIN appointments ON
                appointments.user_id = usable_slots.user_id AND
                appointments.start_at = usable_slots.start_at AND
                appointments.end_at = usable_slots.end_at
              SQL
            )
      .group('usable_slots.start_at, usable_slots.end_at')
      .where('appointments.start_at IS NULL')
      .within_date_range(from, to)
      .map do |us|
      { guiders: us.attributes['guiders'], start: us.start_at, end: us.end_at }
    end
  end

  private_class_method

  def self.generate_for_guider(user)
    (Time.zone.now.to_date..6.weeks.from_now.to_date).each do |day|
      active_schedule = user.schedules.active(day)
      next unless active_schedule

      available_slots = active_schedule
                        .slots
                        .where(day_of_week: day.wday)

      available_slots.each do |available_slot|
        create_usable_slot_from_slot!(user, day, available_slot)
      end
    end
  end

  def self.create_usable_slot_from_slot!(user, day, slot)
    start_at = day.in_time_zone.change(
      hour: slot.start_hour,
      min: slot.start_minute
    )
    end_at = day.in_time_zone.change(
      hour: slot.end_hour,
      min: slot.end_minute
    )
    find_or_create_by!(user: user, start_at: start_at, end_at: end_at)
  end
end
