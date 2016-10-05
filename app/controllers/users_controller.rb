class UsersController < ApplicationController
  before_action :authorise_for_managing_resources!

  def index
    @guiders = User.guiders
    @groups = Group.all
  end

  def edit
    @guider = User.find(params[:id])
    @schedules = SchedulePresenter.wrap(
      @guider.schedules
        .with_end_at
        .by_start_at
    )
  end

  private

  def authorise_for_managing_resources!
    authorise_user!(User::RESOURCE_MANAGER_PERMISSION)
  end
end
