class HolidaysController < ApplicationController
  before_action :authorise_for_managing_resources!

  def index
  end

  private

  def authorise_for_managing_resources!
    authorise_user!(User::RESOURCE_MANAGER_PERMISSION)
  end
end
