class AppointmentsController < ApplicationController
  before_action :authorise_for_contact_centre_agents!

  def new
    @available_slots_json = available_slots_json(Time.zone.now.to_date, 6.weeks.from_now.to_date)
  end

  private

  def available_slots_json(from, to)
    Schedule
      .available_slots_with_guider_count(from, to)
      .to_json
  end

  def authorise_for_contact_centre_agents!
    authorise_user!(User::CONTACT_CENTRE_AGENT_PERMISSION)
  end
end
