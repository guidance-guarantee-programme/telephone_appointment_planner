class AppointmentsController < ApplicationController
  before_action :authorise_for_agents!, except: %i(index edit update)
  before_action :authorise_for_guiders!, only: :index
  before_action :authenticate_user!, only: %i(edit update)

  def index
    @appointments = current_user.appointments.where(start_at: date_range_params)

    render json: @appointments
  end

  def edit
    @appointment = Appointment.find(params[:id])
  end

  def reschedule
    @appointment = Appointment.find(params[:appointment_id])
    load_available_slots
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
    load_available_slots
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
      load_available_slots
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

  def load_available_slots
    @available_slots_json = BookableSlot
                            .with_guider_count(Time.zone.now.to_date, 6.weeks.from_now.to_date)
                            .to_json
  end

  def authorise_for_agents!
    authorise_user!(User::AGENT_PERMISSION)
  end

  def authorise_for_guiders!
    authorise_user!(User::GUIDER_PERMISSION)
  end

  def redirect_after_successful_update
    if current_user.agent?
      redirect_to search_appointments_path, success: 'Appointment has been rescheduled'
    else
      redirect_to calendar_path, success: 'Appointment has been rescheduled'
    end
  end
end
