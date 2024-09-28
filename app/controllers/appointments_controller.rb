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

    render json: @appointments
  end

  def edit
    @appointment = Appointment.for_organisation(current_user).find(params[:id])
  end

  def reschedule
    @appointment = Appointment.find(params[:appointment_id])

    unless @appointment.can_be_rescheduled_by?(current_user)
      return redirect_to search_appointments_path,
                         warning: 'You cannot reschedule this appointment.'
    end

    @appointment.start_at = nil
    @appointment.end_at = nil
  end

  def update_reschedule # rubocop:disable Metrics/MethodLength
    @appointment = Appointment.find(params[:appointment_id])
    @prior_guider = @appointment.guider
    @appointment.assign_attributes(update_reschedule_params)
    @appointment.mark_rescheduled!
    @appointment.allocate(via_slot: calendar_scheduling?, agent: @prior_guider, scoped: false)

    if @appointment.save
      Notifier.new(@appointment, current_user).call
      redirect_to edit_appointment_path(@appointment), success: 'Appointment has been rescheduled'
    else
      render :reschedule
    end
  end

  def update
    @appointment = Appointment.find(params[:id])
    @appointment.current_user = current_user
    if @appointment.update(update_params)
      Notifier.new(@appointment, current_user).call
      redirect_to edit_appointment_path(@appointment), success: 'Appointment has been modified'
    else
      flash[:danger] = 'The appointment has not been updated. Please correct the errors to continue.'
      render :edit
    end
  end

  def new
    @appointment = Appointment.copy_or_new_by(params[:copy_from])

    if @appointment
      # TODO: This should be inferred better
      @appointment.schedule_type = schedule_type

      render :new
    else
      redirect_back warning: I18n.t('appointments.rebooking'), fallback_location: search_appointments_path
    end
  end

  def preview # rubocop:disable Metrics/MethodLength
    @appointment = Appointment.new(create_params.merge(agent: current_user))
    @appointment.allocate(
      via_slot: calendar_scheduling?,
      agent: current_user,
      scoped: !@appointment.internal_availability?,
      rebooking: rebooking?
    )

    if @appointment.valid?
      render :preview
    else
      render :new
    end
  end

  def create # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    @appointment = Appointment.new(create_params.merge(agent: current_user))
    @appointment.allocate(
      via_slot: calendar_scheduling?,
      agent: current_user,
      scoped: !@appointment.internal_availability?,
      rebooking: rebooking?
    )
    @appointment.copy_attachments!

    if creating? && @appointment.save
      send_notifications(@appointment)

      redirect_to(
        search_appointments_path,
        success: I18n.t(
          'appointments.success',
          reference: @appointment.id,
          date: @appointment.start_at.to_s(:govuk_date_short)
        )
      )
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
    SmsAppointmentConfirmationJob.perform_later(appointment) if appointment.mobile?
    AdjustmentNotificationsJob.perform_later(appointment) if appointment.adjustments?
    AppointmentMailer.potential_duplicates(appointment).deliver_later if appointment.potential_duplicates?
    PushCasebookAppointmentJob.perform_later(appointment)
    CustomerUpdateJob.perform_later(appointment, CustomerUpdateActivity::CONFIRMED_MESSAGE)
    PrintedConfirmationJob.perform_later(appointment)
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

  def schedule_type
    @schedule_type = params.fetch(:schedule_type) { User::PENSION_WISE_SCHEDULE_TYPE }
  end
  helper_method :schedule_type

  def due_diligence_schedule_type?
    schedule_type == User::DUE_DILIGENCE_SCHEDULE_TYPE
  end
  helper_method :due_diligence_schedule_type?

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
      .permit(:q, :date_range, :processed, :appointment_type)
      .merge(current_user:)
  end

  def date_range_params
    starts = params[:start].to_date.beginning_of_day
    ends   = params[:end].to_date.beginning_of_day

    starts..ends
  end

  # rubocop:disable Metrics/MethodLength
  def updateable_params
    %i[
      first_name
      last_name
      email
      country_code
      phone
      mobile
      date_of_birth
      memorable_word
      accessibility_requirements
      notes
      status
      secondary_status
      type_of_appointment
      where_you_heard
      address_line_one
      address_line_two
      address_line_three
      town
      county
      postcode
      gdpr_consent
      smarter_signposted
      bsl_video
      third_party_booking
      data_subject_name
      data_subject_age
      data_subject_date_of_birth
      data_subject_consent_obtained
      email_consent_form_required
      printed_consent_form_required
      power_of_attorney
      consent_address_line_one
      consent_address_line_two
      consent_address_line_three
      consent_town
      consent_county
      consent_postcode
      power_of_attorney_evidence
      data_subject_consent_evidence
      email_consent
      lloyds_signposted
      schedule_type
      referrer
      small_pots
      nudged
      internal_availability
      welsh
      cancelled_via
    ]
  end
  # rubocop:enable Metrics/MethodLength

  def update_params
    params.require(:appointment).permit(updateable_params).merge(current_user:)
  end

  def munge_start_at
    if calendar_scheduling?
      params[:appointment][:start_at]
    else
      ad_hoc_start_at = params[:appointment][:ad_hoc_start_at]
      ad_hoc_start_at.presence || params[:appointment][:start_at]
    end
  end

  def create_params
    params
      .require(:appointment)
      .permit(updateable_params.concat(%i[ad_hoc_start_at guider_id end_at rebooked_from_id]))
      .merge(start_at: munge_start_at)
  end

  def update_reschedule_params
    params
      .require(:appointment)
      .permit(:end_at, :guider_id, :rescheduling_reason, :rescheduling_route)
      .merge(
        start_at: munge_start_at,
        agent: current_user
      )
  end

  def creating?
    params[:edit_appointment].nil?
  end

  def rebooking?
    params[:copy_from].present? || @appointment&.rebooked_from_id.present?
  end
  helper_method :rebooking?
end
# rubocop:enable Metrics/ClassLength
