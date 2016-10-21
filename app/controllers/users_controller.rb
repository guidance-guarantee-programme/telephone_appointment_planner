class UsersController < ApplicationController
  before_action do
    authorise_user!(User::RESOURCE_MANAGER_PERMISSION)
  end

  def index
    @guiders = User.includes(:groups).guiders
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
end
