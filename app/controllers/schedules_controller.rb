class SchedulesController < ApplicationController
  before_action :authorise_for_managing_resources!
  before_action :load_current_guider

  def new
    @schedule = @guider.schedules.build(
      start_at: 6.weeks.from_now
    )
    @schedule_json = schedule_json
  end

  def edit
    @schedule = @guider.schedules.find(params[:id])
    @schedule_json = schedule_json
  end

  def destroy
    @schedule = @guider.schedules.find(params[:id])
    @schedule.destroy
    redirect_to edit_user_path(@guider), success: 'Schedule has been deleted'
  end

  def update
    @schedule = @guider.schedules.find(params[:id])
    ActiveRecord::Base.transaction do
      @schedule.slots.destroy_all
      if @schedule.update(schedule_parameters)
        redirect_to edit_user_path(@guider), success: 'Schedule has been updated'
      else
        @schedule_json = schedule_json
        render :edit
      end
    end
  end

  def create
    @schedule = @guider.schedules.build(schedule_parameters)
    if @schedule.save
      redirect_to edit_user_path(@guider), success: 'Schedule has been created'
    else
      @schedule_json = schedule_json
      render :new
    end
  end

  private

  def load_current_guider
    @guider = User.find(params[:user_id])
  end

  def schedule_json
    @schedule.slots.map do |slot|
      {
        day: slot.day,
        start_at: slot.start_at,
        end_at: slot.end_at
      }
    end.to_json
  end

  def schedule_parameters
    pr = params.require(:schedule).permit(
      :start_at,
      :slots
    )
    pr[:slots_attributes] = JSON.parse(pr.delete(:slots))
    pr
  end

  def authorise_for_managing_resources!
    authorise_user!(User::RESOURCE_MANAGER_PERMISSION)
  end
end
