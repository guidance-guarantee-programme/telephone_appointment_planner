class HomeController < ApplicationController
  def index
    path = if current_user.resource_manager?
             allocations_path
           elsif current_user.agent?
             new_appointment_path
           elsif current_user.guider?
             my_appointments_path
           elsif current_user.contact_centre_team_leader?
             new_appointment_report_path
           end

    redirect_to path, status: :moved_permanently
  end
end
