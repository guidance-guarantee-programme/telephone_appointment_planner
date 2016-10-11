class SchedulesController < ApplicationController
  before_action :authorise_for_managing_resources!
  before_action :load_current_guider
  before_action :load_current_schedule, only: [:edit, :update]

  def new
    @schedule = @guider.schedules.build
    @slots_as_json = slots_as_json
  end

  def edit
    @schedule = SchedulePresenter.new(@guider.schedules.find(params[:id]))
    @slots_as_json = slots_as_json
  end

  def destroy
    @schedule = @guider.schedules.find(params[:id])
    @schedule.destroy
    redirect_to edit_user_path(@guider), success: 'Schedule has been deleted'
  end

  def update
    ActiveRecord::Base.transaction do
      @schedule.slots.destroy_all
      if @schedule.update(schedule_parameters)
        GenerateBookableSlotsForUserJob.perform_later @guider
        redirect_to edit_user_path(@guider), success: 'Schedule has been updated'
      else
        @slots_as_json = slots_as_json
        render :edit
      end
    end
  end

  def create
    @schedule = @guider.schedules.build(schedule_parameters)
    if @schedule.save
      GenerateBookableSlotsForUserJob.perform_later @guider
      redirect_to edit_user_path(@guider), success: 'Schedule has been created'
    else
      @slots_as_json = slots_as_json
      render :new
    end
  end

  private

  def load_current_guider
    @guider = User.find(params[:user_id])
  end

  def load_current_schedule
    @schedule = SchedulePresenter.new(@guider.schedules.find(params[:id]))
  end

  def slots_as_json
    ActiveModelSerializers::SerializableResource.new(@schedule.slots).to_json
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
