class HolidaysController < ApplicationController
  before_action do
    authorise_user!(User::RESOURCE_MANAGER_PERMISSION)
  end

  def index
    respond_to do |format|
      format.html
      format.json do
        render json: Holiday.merged_for_calendar_view
      end
    end
  end
end
