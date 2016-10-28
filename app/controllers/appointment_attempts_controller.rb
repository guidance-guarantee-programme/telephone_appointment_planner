class AppointmentAttemptsController < ApplicationController
  before_action :authorise_for_agents!

  def new
    @appointment_attempt = AppointmentAttempt.new
  end

  def create
    @appointment_attempt = AppointmentAttempt.new(appointment_attempt_params)
    if @appointment_attempt.save
      if @appointment_attempt.eligible?
        redirect_to new_appointment_attempt_appointment_path(@appointment_attempt)
      else
        redirect_to ineligible_appointment_attempts_path
      end
    else
      render :new
    end
  end

  def ineligible
  end

  private

  def appointment_attempt_params
    params.require(:appointment_attempt).permit(
      :first_name,
      :last_name,
      :date_of_birth,
      :defined_contribution_pot
    )
  end
end
