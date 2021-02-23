class DuplicatesController < ApplicationController
  def index
    @appointment = Appointment.for_organisation(current_user).find(params[:appointment_id])
  end
end
