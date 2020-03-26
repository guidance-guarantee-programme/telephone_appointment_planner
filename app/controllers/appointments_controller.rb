# rubocop:disable Metrics/ClassLength
class AppointmentsController < ApplicationController
  store_previous_page_on :search

  rescue_from ActiveRecord::RecordNotFound do
    render :missing
  end

  def batch_update
    BatchAppointmentUpdate.new(params[:changes]).call
    head :ok
  end

  def index
    @appointments = appointment_scope.where(start_at: date_range_params)

    render json: @appointments if stale?(@appointments)
  end

  def edit
    @appointment = Appointment.for_organisation(current_user).find(params[:id])
  end

  def reschedule
    @appointment = Appointment.find(params[:appointment_id])
    @appointment.start_at = nil
    @appointment.end_at = nil
  end

  def update_reschedule
    @appointment = Appointment.find(params[:appointment_id])
    @appointment.assign_attributes(update_reschedule_params)
    @appointment.mark_rescheduled!
    @appointment.allocate(via_slot: calendar_scheduling?)

    if @appointment.save
      Notifier.new(@appointment).call
      redirect_to edit_appointment_path(@appointment), success: 'Appointment has been rescheduled'
    else
      render :reschedule
    end
  end

  def update
    @appointment = Appointment.find(params[:id])
    if @appointment.update_attributes(update_params)
      Notifier.new(@appointment).call
      redirect_to edit_appointment_path(@appointment), success: 'Appointment has been modified'
    else
      render :edit
    end
  end

  def new
    @appointment = Appointment.copy_or_new_by(params[:copy_from])

    if @appointment
      render :new
    else
      redirect_back warning: I18n.t('appointments.rebooking'), fallback_location: search_appointments_path
    end
  end

  def preview
    @appointment = Appointment.new(create_params.merge(agent: current_user))
    @appointment.allocate(via_slot: calendar_scheduling?, agent: current_user)

    if @appointment.valid?
      render :preview
    else
      render :new
    end
  end

  def create
    @appointment = Appointment.new(create_params.merge(agent: current_user))
    @appointment.allocate(via_slot: calendar_scheduling?, agent: current_user)

    if creating? && @appointment.save
      send_notifications(@appointment)

      redirect_to(search_appointments_path, success: 'Appointment has been created')
    else
      render :new
    end
  end

  def search
    @search = Search.new(search_params)

    return redirect_on_exact_match(@search.results.first) if @search.results.one?

    @results = @search.results.page(params[:page])
  end

  private

  def send_notifications(appointment)
    AccessibilityAdjustmentNotificationsJob.perform_later(appointment) if appointment.accessibility_requirements?
    CustomerUpdateJob.perform_later(appointment, CustomerUpdateActivity::CONFIRMED_MESSAGE)
    AppointmentCreatedNotificationsJob.perform_later(appointment)
  end

  def postcode_api_key
    ENV.fetch('POSTCODE_API_KEY') { 'iddqd' } # default to test API key
  end
  helper_method :postcode_api_key

  def calendar_scheduling?
    ActiveRecord::Type::Boolean.new.deserialize(params.fetch(:scheduled, true))
  end
  helper_method :calendar_scheduling?

  def redirect_on_exact_match(result)
    redirect_to(edit_appointment_path(result))
  end

  def appointment_scope
    if scoped_to_me?
      current_user.appointments
    else
      Appointment
        .unscoped
        .joins(:guider)
        .where(users: { organisation_content_id: current_user.organisation_content_id })
    end
  end

  def scoped_to_me?
    params.key?(:mine)
  end

  def search_params
    params
      .fetch(:search, {})
      .permit(:q, :date_range)
      .merge(current_user: current_user)
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
      :accessibility_requirements,
      :notes,
      :status,
      :type_of_appointment,
      :where_you_heard,
      :address_line_one,
      :address_line_two,
      :address_line_three,
      :town,
      :county,
      :postcode,
      :gdpr_consent
    ]
  end
  # rubocop:enable Metrics/MethodLength

  def update_params
    params.require(:appointment).permit(updateable_params)
  end

  def munge_start_at
    if calendar_scheduling?
      params[:appointment][:start_at]
    else
      ad_hoc_start_at = params[:appointment][:ad_hoc_start_at]
      ad_hoc_start_at.present? ? ad_hoc_start_at : params[:appointment][:start_at]
    end
  end

  def create_params
    params
      .require(:appointment)
      .permit(updateable_params.concat(%i(ad_hoc_start_at guider_id end_at rebooked_from_id)))
      .merge(start_at: munge_start_at)
  end

  def update_reschedule_params
    params
      .require(:appointment)
      .permit(:end_at, :guider_id)
      .merge(
        start_at: munge_start_at,
        agent: current_user
      )
  end

  def creating?
    params[:edit_appointment].nil?
  end
end
