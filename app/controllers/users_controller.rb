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

  def sort
    @guiders = User.guiders.includes(:groups)
  end

  def sort_update
    guider_order = params[:order_users][:guider_order]

    ActiveRecord::Base.transaction do
      guider_order.each_with_index do |id, index|
        User.update(id, position: index)
      end
    end

    redirect_to :sort_users, success: 'Guider order has been updated'
  end
end
