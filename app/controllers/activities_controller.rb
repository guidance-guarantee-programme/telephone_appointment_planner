class ActivitiesController < ApplicationController
  store_previous_page_on :index

  def index
    @activities = current_user.activities.includes(:user, :appointment)
  end

  def create
    @activity = MessageActivity.create(message_params)
    PusherActivityCreatedJob.perform_later(appointment.guider_id, @activity.id)
    respond_to do |format|
      format.js { render @activity }
    end
  end

  def resolve
    @activity = Activity.find(params[:id])
    @activity.resolve!(current_user)

    respond_to do |format|
      format.js { head :ok }
      format.html { redirect_back(fallback_location: edit_appointment_path(@activity.appointment)) }
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

  def appointment
    Appointment.find(params[:appointment_id])
  end
end
