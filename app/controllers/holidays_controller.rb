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

  def new
    @guiders = User.guiders
    @groups = Group.all
    @holiday = CreateHolidays.new
    @user_search = nil
  end

  def create
    @guiders = User.guiders
    @groups = Group.all
    @holiday = CreateHolidays.new(create_params)
    @user_search = params[:user_search]

    if @holiday.call
      redirect_to holidays_path, success: 'Holiday has been created!'
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
      .permit(:title, :date_range, :user_ids)
      .merge(user_ids: params[:holiday][:user_ids])
  end

  def authorise_for_managing_resources!
    authorise_user!(User::RESOURCE_MANAGER_PERMISSION)
  end
end
