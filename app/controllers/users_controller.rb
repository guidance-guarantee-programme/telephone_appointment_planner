class UsersController < ApplicationController
  before_action :authorise_for_managing_resources!

  def index
    @guiders = User.guiders
  end

  def edit
    @guider = User.find(params[:id])
    @slot_ranges = SlotRangePresenter.wrap(@guider.slot_ranges)
  end

  private

  def authorise_for_managing_resources!
    authorise_user!(User::RESOURCE_MANAGER_PERMISSION)
  end
end
