class BookableSlot < ApplicationRecord
  belongs_to :guider, class_name: 'User'

  scope :for_guider, ->(guider) { where(guider: guider) }

  def self.generate_for_six_weeks
    User.guiders.each do |guider|
      generate_for_guider(guider)
    end
  end

  def self.within_date_range(from, to)
    where("#{quoted_table_name}.start_at > ? AND #{quoted_table_name}.end_at < ?", from, to)
  end

  def self.next_valid_start_date(user)
    return Time.zone.now if user.resource_manager?
    BusinessDays.from_now(2)
  end

  def self.find_available_slot(start_at, end_at)
    bookable
      .where(start_at: start_at, end_at: end_at)
      .limit(1)
      .order('RANDOM()')
      .first
  end

  def self.bookable
    without_appointments
      .without_holidays
  end

  def self.without_appointments
    joins(<<-SQL
            LEFT JOIN appointments ON
              appointments.guider_id = #{quoted_table_name}.guider_id AND
              appointments.start_at = #{quoted_table_name}.start_at AND
              appointments.end_at = #{quoted_table_name}.end_at AND NOT
              appointments.status IN (
                #{Appointment.statuses['cancelled_by_customer']},
                #{Appointment.statuses['cancelled_by_pension_wise']}
              )
            SQL
         )
      .where('appointments.start_at IS NULL')
  end

  # rubocop:disable Metrics/MethodLength
  def self.without_holidays
    joins(<<-SQL
          LEFT JOIN holidays ON
            -- The holiday is specifically for the user, or it is for everyone
            (holidays.user_id = #{quoted_table_name}.guider_id OR holidays.user_id IS NULL) AND
            (
              (holidays.start_at <= #{quoted_table_name}.start_at AND holidays.end_at >= #{quoted_table_name}.end_at)
              OR
              (holidays.start_at >= #{quoted_table_name}.start_at AND holidays.start_at < #{quoted_table_name}.end_at)
              OR
              (holidays.end_at > #{quoted_table_name}.start_at AND holidays.end_at <= #{quoted_table_name}.end_at)
            )
            SQL
         )
      .where('holidays.start_at IS NULL')
  end
  # rubocop:enable Metrics/MethodLength

  def self.starting_after_next_valid_start_date(user)
    where("#{quoted_table_name}.start_at > ?", next_valid_start_date(user))
  end

  def self.with_guider_count(user, from, to)
    select("DISTINCT #{quoted_table_name}.start_at, #{quoted_table_name}.end_at, count(1) AS guiders")
      .bookable
      .starting_after_next_valid_start_date(user)
      .group("#{quoted_table_name}.start_at, #{quoted_table_name}.end_at")
      .within_date_range(from, to)
      .map do |us|
        { guiders: us.attributes['guiders'], start: us.start_at, end: us.end_at, selected: false }
      end
  end

  def self.generate_for_guider(guider)
    where(guider: guider).delete_all

    return unless guider.active?

    generation_range.each do |day|
      active_schedule = guider.schedules.active(day)
      next unless active_schedule

      available_slots = active_schedule.slots.where(day_of_week: day.wday)

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
    create!(guider: guider, start_at: start_at, end_at: end_at)
  end

  def self.generation_range
    Time.zone.now.to_date..6.weeks.from_now.to_date
  end
end
