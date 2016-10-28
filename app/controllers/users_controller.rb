class UsersController < ApplicationController
  before_action :authorise_for_resource_managers!

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
