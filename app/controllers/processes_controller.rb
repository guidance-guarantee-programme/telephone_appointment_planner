class ProcessesController < ApplicationController
  def create
    @appointment = Appointment
                   .unscoped
                   .joins(:guider)
                   .where(users: { organisation_content_id: current_user.organisation_content_id })
                   .find(params[:appointment_id])

    @appointment.process!(current_user)

    redirect_back success: 'The appointment was marked as processed.', fallback_location: root_path
  end
end
