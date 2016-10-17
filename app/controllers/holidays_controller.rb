class HolidaysController < ApplicationController
  before_action :authorise_for_managing_resources!

  def index
    respond_to do |format|
      format.html
      format.json do
        render json: Holiday.merged_for_calendar_view
      end
    end
  end

  private

  def authorise_for_managing_resources!
    authorise_user!(User::RESOURCE_MANAGER_PERMISSION)
  end
end
