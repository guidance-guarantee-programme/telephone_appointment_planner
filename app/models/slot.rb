class Slot < ApplicationRecord
  belongs_to :schedule

  def valid_for(other_start_at, other_end_at)
    correct_day_of_week = other_start_at.wday == Date::DAYNAMES.index(day)
    correct_time =
      start_at == other_start_at.strftime('%H:%M') &&
      end_at == other_end_at.strftime('%H:%M')
    correct_day_of_week && correct_time
  end
end
