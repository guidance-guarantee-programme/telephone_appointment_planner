class UsersController < ApplicationController
  before_action :authorise_for_managing_resources!

  def index
    @guiders = User.guiders
  end

  def edit
    @guider = User.find(params[:id])
    @schedules = SchedulePresenter.wrap(
      @guider.schedules.by_from
    )
  end

  private

  def authorise_for_managing_resources!
    authorise_user!(User::RESOURCE_MANAGER_PERMISSION)
  end
end
