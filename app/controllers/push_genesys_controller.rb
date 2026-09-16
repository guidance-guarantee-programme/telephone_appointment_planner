class PushGenesysController < ApplicationController
  before_action :authorise_for_resource_managers!

  def create
    @appointment = Appointment.find(params[:appointment_id])

    PushGenesysAppointmentJob.perform_later(@appointment)

    redirect_back success: 'The push to Genesys was enqueued.', fallback_location: root_path
  end
end
