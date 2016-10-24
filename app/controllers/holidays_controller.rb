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

  def new
    @holiday = CreateHolidays.new
  end

  def create
    @holiday = CreateHolidays.new(
      create_params[:title],
      create_params[:date_range],
      user_ids
    )

    if @holiday.call
      redirect_to holidays_path, success: 'Holiday has been created.'
    else
      render :new
    end
  end

  def destroy
    holiday_ids = params[:holiday_ids].split(',')
    Holiday
      .where(id: holiday_ids)
      .destroy_all
  end

  private

  def create_params
    params
      .require(:holiday)
      .permit(:title, :date_range)
  end

  def user_ids
    params[:holiday][:users] || []
  end
end
