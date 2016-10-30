# rubocop:disable Metrics/ClassLength
class AppointmentsController < ApplicationController
  before_action :authenticate_user!

  def batch_update
    BatchAppointmentUpdate.new(params[:changes]).call

    redirect_to resource_calendar_path
  end

  def index
    scope = if current_user.resource_manager?
              Appointment.unscoped
            elsif current_user.guider?
              current_user.appointments
            end

    @appointments = scope.where(start_at: date_range_params)

    render json: @appointments, include_links: include_links?
  end

  def edit
    @appointment = Appointment.find(params[:id])
  end

  def reschedule
    @appointment = Appointment.find(params[:appointment_id])
  end

  def update
    @appointment = Appointment.find(params[:id])
    @appointment.assign_attributes(appointment_params)
    @appointment.assign_to_guider if appointment_params[:start_at] && appointment_params[:end_at]
    if @appointment.save
      redirect_after_successful_update
    else
      render :edit
    end
  end

  def new
    @appointment_attempt = AppointmentAttempt.find(params[:appointment_attempt_id])
    @appointment = Appointment.new(
      first_name: @appointment_attempt.first_name,
      last_name: @appointment_attempt.last_name,
      date_of_birth: @appointment_attempt.date_of_birth
    )
  end

  # rubocop:disable Metrics/MethodLength
  def create
    @appointment = Appointment.new(appointment_params)
    @appointment_attempt = AppointmentAttempt.find(params[:appointment_attempt_id])
    @appointment.assign_to_guider
    if @appointment.save
      redirect_to(
        appointment_attempt_appointment_path(@appointment_attempt, @appointment),
        success: 'Appointment has been created!'
      )
    else
      render :new
    end
  end

  def show
    @appointment = Appointment.find(params[:id])
  end

  def search
    @search = Search.new(
      search_params[:q],
      search_params[:date_range]
    )
    @results = @search.results.page(params[:page])
  end

  private

  def search_params
    params.fetch(:search, {}).permit(:q, :date_range)
  end

  def include_links?
    params.fetch(:include_links, 'true') == 'true'
  end

  def date_range_params
    starts = params[:start].to_date.beginning_of_day
    ends   = params[:end].to_date.beginning_of_day

    starts..ends
  end

  def appointment_params
    params.require(:appointment).permit(
      :start_at,
      :end_at,
      :first_name,
      :last_name,
      :email,
      :phone,
      :mobile,
      :date_of_birth,
      :memorable_word,
      :notes,
      :opt_out_of_market_research,
      :where_did_you_hear_about_pension_wise,
      :who_is_your_pension_provider,
      :status
    )
  end

  def redirect_after_successful_update
    if current_user.agent?
      redirect_to search_appointments_path, success: 'Appointment has been rescheduled'
    else
      redirect_to calendar_path, success: 'Appointment has been rescheduled'
    end
  end
end
