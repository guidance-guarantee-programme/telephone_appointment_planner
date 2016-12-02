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
    @guiders = User.guiders.active.includes(:groups)
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

  def deactivate
    toggle_activation
    redirect_to users_path, success: 'Guider has been deactivated'
  end

  def activate
    toggle_activation
    redirect_to users_path, success: 'Guider has been activated'
  end

  private

  def toggle_activation
    user = User.find(params[:user_id])

    user.toggle!(:active)

    GenerateBookableSlotsForUserJob.perform_later user
  end
end
