class ReallocatesController < ApplicationController
  before_action :authorise_for_resource_managers!

  def new
    @appointment = load_form
  end

  def create
    @appointment = load_form

    if @appointment.update
      Notifier.new(@appointment.model, current_user).call
      redirect_to root_path, success: 'The appointment was successfully reallocated.'
    else
      render :new
    end
  end

  private

  def reallocation_params
    params.fetch(:reallocate, {}).permit(:guider_id, :rescheduling_route)
  end

  def load_form
    appointment = Appointment
                  .for_user_organisation(current_user)
                  .for_pension_wise
                  .pending
                  .find(params[:appointment_id])

    Reallocate.new(appointment, current_user, reallocation_params)
  end
end
