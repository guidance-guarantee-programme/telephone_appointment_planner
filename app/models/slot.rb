class Slot < ApplicationRecord
  belongs_to :schedule

  def valid_for_appointment(appointment)
    correct_day_of_week = appointment.start_at.wday == day_of_week
    correct_time =
      hour_and_minutes_equal_to_start(appointment.start_at) &&
      hour_and_minutes_equal_to_end(appointment.end_at)
    correct_day_of_week && correct_time
  end

  private

  def hour_and_minutes_equal_to_start(date)
    date.hour == start_hour && date.min == start_minute
  end

  def hour_and_minutes_equal_to_end(date)
    date.hour == end_hour && date.min == end_minute
  end
end
