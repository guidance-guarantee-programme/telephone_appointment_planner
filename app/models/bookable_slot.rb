class BookableSlot < ApplicationRecord
  belongs_to :guider, class_name: 'User'

  def self.generate_for_six_weeks
    User.guiders.each do |guider|
      generate_for_guider(guider)
    end
  end

  def self.within_date_range(from, to)
    where("#{quoted_table_name}.start_at > ? AND #{quoted_table_name}.end_at < ?", from, to)
  end

  def self.next_valid_start_date
    BusinessDays.from_now(3)
  end

  def self.without_appointments
    joins(<<-SQL
            LEFT JOIN appointments ON
              appointments.guider_id = #{quoted_table_name}.guider_id AND
              appointments.start_at = #{quoted_table_name}.start_at AND
              appointments.end_at = #{quoted_table_name}.end_at
            SQL
         )
      .where('appointments.start_at IS NULL')
  end

  def self.starting_after_two_business_days
    where("#{quoted_table_name}.start_at > ?", next_valid_start_date)
  end

  def self.with_guider_count(from, to)
    select("DISTINCT #{quoted_table_name}.start_at, #{quoted_table_name}.end_at, count(1) AS guiders")
      .without_appointments
      .starting_after_two_business_days
      .group("#{quoted_table_name}.start_at, #{quoted_table_name}.end_at")
      .within_date_range(from, to)
      .map do |us|
        { guiders: us.attributes['guiders'], start: us.start_at, end: us.end_at }
      end
  end

  def self.generate_for_guider(guider)
    (Time.zone.now.to_date..6.weeks.from_now.to_date).each do |day|
      active_schedule = guider.schedules.active(day)
      next unless active_schedule

      available_slots = active_schedule
                        .slots
                        .where(day_of_week: day.wday)

      available_slots.each do |available_slot|
        create_from_slot!(guider, day, available_slot)
      end
    end
  end

  def self.create_from_slot!(guider, day, slot)
    start_at = day.in_time_zone.change(
      hour: slot.start_hour,
      min: slot.start_minute
    )
    end_at = day.in_time_zone.change(
      hour: slot.end_hour,
      min: slot.end_minute
    )
    find_or_create_by!(guider: guider, start_at: start_at, end_at: end_at)
  end
end
