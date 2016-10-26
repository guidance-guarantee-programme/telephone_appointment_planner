# rubocop:disable ClassLength
class AppointmentsController < ApplicationController
  before_action :authorise_for_agents!, except: %i(index edit update)
  before_action :authorise_for_guiders!, only: %i(index edit update)

  def index
    @appointments = current_user.appointments.where(start_at: date_range_params)

    render json: @appointments
  end

  def edit
    @appointment = current_user.appointments.find(params[:id])
  end

  def update
    @appointment = current_user.appointments.find(params[:id])

    if @appointment.update(edit_params)
      send_notification
      redirect_to calendar_path
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

  private

  def send_notification
    return unless ENV['PUSHER_KEY'] && ENV['PUSHER_SECRET']

    pusher_client = Pusher::Client.new(
      app_id: ENV['PUSHER_APP_ID'],
      key: ENV['PUSHER_KEY'],
      secret: ENV['PUSHER_SECRET'],
      cluster: 'eu',
      encrypted: true
    )

    pusher_client.trigger(
      'telephone_appointment_planner',
      "appointment_update_guider_#{@appointment.guider_id}",
      [
        {
          event_id: @appointment.id,
          updated: {
            customer_name: [@appointment.first_name, ' ', @appointment.last_name].join,
            start: @appointment.start_at
          }
        }
      ]
    )
  end

  def date_range_params
    starts = params[:start].to_date.beginning_of_day
    ends   = params[:end].to_date.beginning_of_day

    starts..ends
  end

  def edit_params
    appointment_params.except(:start_at, :end_at)
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
end
