class ChangesController < ApplicationController
  before_action :authenticate_user!

  def index
    @appointment = Appointment.find(params[:appointment_id])
  end
end
