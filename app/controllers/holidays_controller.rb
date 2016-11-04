class HolidaysController < ApplicationController
  before_action :authorise_for_resource_managers!

  def merged
    render json: Holiday.merged_for_calendar_view
  end

  def index
    respond_to do |format|
      format.html
      format.json do
        starts = params[:start].to_date.beginning_of_day
        ends   = params[:end].to_date.beginning_of_day
        render json: Holiday.overlapping_or_inside(starts, ends)
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

  def edit
    holidays = Holiday.where(id: params[:id]).includes(:user)
    @users = holidays.map(&:user)
    @title = holidays.first.title
  end

  def destroy
    holiday_ids = params[:holiday_ids].split(',')
    Holiday
      .where(id: holiday_ids)
      .destroy_all
    redirect_to holidays_path, success: 'Holiday has been deleted'
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
