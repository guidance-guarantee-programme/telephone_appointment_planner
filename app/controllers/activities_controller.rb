class ActivitiesController < ApplicationController
  def index
    @activities = appointment.activities.since(since)

    if @activities.present?
      render partial: @activities
    else
      head :not_modified
    end
  end

  def create
    @appointment = Appointment.find(params[:appointment_id])
    @activity = MessageActivity.create(message_params)

    respond_to do |format|
      format.js { render @activity }
    end
  end

  private

  def message_params
    params
      .require(:message_activity)
      .permit(:message)
      .merge(
        user: current_user,
        owner: appointment.guider,
        appointment: appointment
      )
  end

  def since
    timestamp = params[:timestamp].to_i / 1000
    Time.zone.at(timestamp)
  end

  def appointment
    Appointment.find(params[:appointment_id])
  end
end
