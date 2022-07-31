class ReissuesController < ApplicationController
  layout false

  before_action :load_form

  def create
    render :new unless @form.reissue
  end

  private

  def load_form
    @form = ReissueSummary.new(form_params)
  end

  def form_params
    params
      .fetch(:reissue_summary, {})
      .permit(:email)
      .merge(
        appointment: appointment,
        current_user: current_user
      )
  end

  def appointment
    Appointment.for_organisation(current_user).find(params[:appointment_id])
  end
end
