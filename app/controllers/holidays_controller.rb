class HolidaysController < ApplicationController
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
    @holiday = BatchUpsertHolidays.new
  end

  def create
    Holiday.create!(create_params)
  end

  def batch_create
    @holiday = BatchUpsertHolidays.new(batch_create_params)

    if @holiday.call
      redirect_to(holidays_path, success: 'Holiday has been created')
    else
      render :new
    end
  end

  def edit
    holidays = Holiday.where(id: holiday_ids)

    @holiday = BatchUpsertHolidays.new(
      title: holidays.first.title,
      all_day: holidays.first.all_day,
      previous_holidays: holiday_ids,
      users: holidays.pluck(:user_id),
      start_at: holidays.first.start_at,
      end_at: holidays.first.end_at
    )
  end

  def batch_upsert
    @holiday = BatchUpsertHolidays.new(
      batch_create_params.merge(previous_holidays: holiday_ids)
    )
    if @holiday.call
      redirect_to(holidays_path, success: 'Holiday has been updated')
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

  def create_params
    params
      .require(:holiday)
      .permit(:title, :user_id, :start_at, :end_at)
      .merge(bank_holiday: false)
  end

  def batch_create_params
    params
      .require(:holiday)
      .permit(
        :title,
        :all_day,
        :start_at,
        :end_at
      )
      .merge(users: user_ids)
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
