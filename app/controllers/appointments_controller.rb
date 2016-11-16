# rubocop:disable Metrics/ClassLength
class AppointmentsController < ApplicationController
  before_action :authenticate_user!

  def batch_update
    BatchAppointmentUpdate.new(params[:changes]).call
    head :ok
  end

  def index
    @appointments = appointment_scope.where(start_at: date_range_params)

    render json: @appointments
  end

  def edit
    @appointment = Appointment.find(params[:id])
  end

  def reschedule
    @appointment = Appointment.find(params[:appointment_id])
  end

  def update_reschedule
    @appointment = Appointment.find(params[:appointment_id])
    @appointment.assign_attributes(update_reschedule_params)
    @appointment.assign_to_guider
    if @appointment.save
      Notifier.new(@appointment).call
      redirect_after_successful_update
    else
      render :reschedule
    end
  end

  def update
    @appointment = Appointment.find(params[:id])
    if @appointment.update_attributes(update_params)
      Notifier.new(@appointment).call
      redirect_after_successful_update
    else
      render :edit
    end
  end

  def new
    @appointment = copy_appointment || Appointment.new
  end

  def create
    @appointment = Appointment.new(create_params.merge(agent: current_user))
    @appointment.assign_to_guider
    if @appointment.save
      AppointmentMailer.confirmation(@appointment).deliver_later
      redirect_to(search_appointments_path, success: 'Appointment has been created')
    else
      render :new
    end
  end

  def search
    @search = Search.new(
      search_params[:q],
      search_params[:date_range]
    )
    @results = @search.results.page(params[:page])
  end

  private

  def appointment_scope
    if scoped_to_me?
      current_user.appointments
    elsif current_user.resource_manager?
      Appointment.unscoped
    else
      current_user.appointments
    end
  end

  def scoped_to_me?
    params.key?(:mine)
  end

  def search_params
    params.fetch(:search, {}).permit(:q, :date_range)
  end

  def date_range_params
    starts = params[:start].to_date.beginning_of_day
    ends   = params[:end].to_date.beginning_of_day

    starts..ends
  end

  # rubocop:disable Metrics/MethodLength
  def updateable_params
    [
      :first_name,
      :last_name,
      :email,
      :phone,
      :mobile,
      :date_of_birth,
      :memorable_word,
      :notes,
      :opt_out_of_market_research,
      :status
    ]
  end
  # rubocop:enable Metrics/MethodLength

  def update_params
    params.require(:appointment).permit(updateable_params)
  end

  def create_params
    params.require(:appointment).permit(
      updateable_params.concat([:start_at, :end_at])
    )
  end

  def update_reschedule_params
    params.require(:appointment).permit(:start_at, :end_at)
  end

  def redirect_after_successful_update
    if current_user.agent?
      redirect_to search_appointments_path, success: 'Appointment has been modified'
    else
      redirect_to calendar_path, success: 'Appointment has been modified'
    end
  end

  def copy_appointment
    return nil unless params[:copy_from].present?
    appointment = Appointment.find(params[:copy_from]).dup
    appointment.start_at = nil
    appointment.end_at = nil
    appointment
  end
end
