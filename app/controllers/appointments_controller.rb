class AppointmentsController < ApplicationController
  def new
    @available_slots_json = available_slots_json(Time.zone.now.to_date, 6.weeks.from_now.to_date)
  end

  private

  def available_slots_json(from, to)
    Schedule
      .available_slots_with_guider_count(from, to)
      .to_json
  end
end
