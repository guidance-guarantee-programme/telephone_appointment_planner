class AppointmentsController < ApplicationController
  before_action :authorise_for_agents!

  def new
    UsableSlot.regenerate_for_six_weeks
    @appointment = Appointment.new
    @available_slots_json = available_slots_json(Time.zone.now.to_date, 6.weeks.from_now.to_date)
  end

  def create
    @appointment = Appointment.new(appointment_params)
    @appointment.assign_to_guider
    if @appointment.save
      redirect_to appointment_path(@appointment), success: 'Appointment has been created!'
    else
      @available_slots_json = available_slots_json(Time.zone.now.to_date, 6.weeks.from_now.to_date)
      render :new
    end
  end

  def show
    @appointment = Appointment.find(params[:id])
  end

  private

  # rubocop:disable Metrics/MethodLength
  def appointment_params
    params.require(:appointment).permit(
      :start_at,
      :end_at,
      :first_name,
      :last_name,
      :email,
      :phone,
      :mobile,
      :year_of_birth,
      :memorable_word,
      :notes,
      :opt_out_of_market_research
    )
  end

  def available_slots_json(from, to)
    UsableSlot
      .with_guider_count(from, to)
      .to_json
  end

  def authorise_for_agents!
    authorise_user!(User::AGENT_PERMISSION)
  end
end
