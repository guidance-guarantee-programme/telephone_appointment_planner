class ActivitiesController < ApplicationController
  store_previous_page_on :index

  def index
    @activities = current_user.activities.includes(:user, :appointment).page(params[:page])
  end

  def create
    @activity = MessageActivity.create(message_params)
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

  def high_priority
    @activities = Activity
                  .high_priority_for(current_user)
                  .unresolved
                  .where('created_at > ?', 1.month.ago)
                  .order('id DESC')
                  .limit(5)

    render layout: false
  end

  private

  def message_params
    params
      .require(:message_activity)
      .permit(:message)
      .merge(
        user: current_user,
        owner: appointment.guider,
        appointment:
      )
  end

  def appointment
    Appointment.find(params[:appointment_id])
  end
end
