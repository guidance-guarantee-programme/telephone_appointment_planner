class UsersController < ApplicationController
  before_action :authorise_for_resource_managers!
  before_action :authorise_for_administrators!, only: :update

  def index
    @guiders = current_user.colleagues.guiders.includes(:groups)
    @groups = Group.for_user(current_user)
  end

  def edit
    @guider = current_user.colleagues.find(params[:id])
    @schedules = SchedulePresenter.wrap(
      @guider.schedules
        .with_end_at
        .by_start_at
    )
  end

  def update
    current_user.update(organisation_params)

    redirect_back fallback_location: root_path
  end

  def sort
    @guiders = current_user.colleagues.guiders.active.includes(:groups)
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

  def organisation_params
    params.require(:user).permit(:organisation_content_id)
  end

  def toggle_activation
    user = current_user.colleagues.find(params[:user_id])
    user.toggle!(:active)

    GenerateBookableSlotsForUserJob.perform_later user
  end
end
