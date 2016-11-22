class HolidaysController < ApplicationController
  include DateRangePickerHelper
  before_action :authorise_for_resource_managers!

  def merged
    render json: Holiday.merged_for_calendar_view
  end

  def index
    respond_to do |format|
      format.html
      format.json do
        holidays = Holiday.overlapping_or_inside(starts, ends)
        holidays = holidays.scoped_for_user_including_bank_holidays(current_user) if scoped_to_me?
        render json: holidays
      end
    end
  end

  def new
    @holiday = CreateHolidays.new
  end

  def create
    Holiday.create!(create_params)
  end

  def batch_create
    @holiday = CreateHolidays.new(
      batch_create_params[:title],
      batch_create_params[:date_range],
      user_ids
    )

    if @holiday.call
      redirect_to holidays_path, success: 'Holiday has been created'
    else
      render :new
    end
  end

  def edit
    holidays = Holiday.where(id: holiday_ids).includes(:user)
    @holiday = UpdateHolidays.new(
      holiday_ids,
      holidays.first.title,
      build_date_range_picker_range(holidays.first.start_at, holidays.first.end_at),
      holidays.map(&:user).map(&:id)
    )
  end

  def update
    @holiday = UpdateHolidays.new(holiday_ids, update_params[:title], update_params[:date_range], user_ids)
    if @holiday.call
      redirect_to holidays_path, success: 'Holiday has been updated'
    else
      render :edit
    end
  end

  def destroy
    holiday_ids = params[:holiday_ids].split(',')
    Holiday
      .where(id: holiday_ids)
      .destroy_all
    redirect_to holidays_path, success: 'Holiday has been deleted'
  end

  private

  def holiday_ids
    params[:id].split(',')
  end

  def update_params
    params
      .require(:holiday)
      .permit(:title, :date_range)
  end

  def create_params
    params
      .require(:holiday)
      .permit(:title, :user_id, :start_at, :end_at)
      .merge(bank_holiday: false)
  end

  def batch_create_params
    params
      .require(:holiday)
      .permit(:title, :date_range)
  end

  def user_ids
    params[:holiday][:users] || []
  end

  def starts
    params[:start].to_date.beginning_of_day
  end

  def ends
    params[:end].to_date.beginning_of_day
  end

  def scoped_to_me?
    params.key?(:mine)
  end
end
