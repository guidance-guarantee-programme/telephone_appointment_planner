class ReallocatesController < ApplicationController
  before_action :authorise_for_resource_managers!

  def new
    @appointment = load_appointment
  end

  def create
    @appointment = load_appointment

    if @appointment.update(reallocation_params)
      Notifier.new(@appointment, current_user).call
      redirect_to root_path, success: 'The appointment was successfully reallocated.'
    else
      render :new
    end
  end

  private

  def reallocation_params
    params.require(:appointment).permit(:guider_id)
  end

  def load_appointment
    Appointment
      .for_user_organisation(current_user)
      .for_pension_wise
      .pending
      .find(params[:appointment_id])
  end
end
