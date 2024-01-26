class SmsAppointmentReminderJob < NotifyJobBase
  STANDARD_TEMPLATE_ID = '14d350d2-f962-4daa-b3b8-e6c3696864c0'.freeze
  BSL_TEMPLATE_ID      = '6bedd37b-c75c-44f5-bed3-3ec5eb5bb564'.freeze
  DUE_DILIGENCE_TEMPLATE_ID = 'c3157b23-c727-495e-b366-268536f848cc'.freeze

  def perform(appointment)
    return unless api_key(appointment.schedule_type)

    create_activity(appointment) if send_sms_reminder(appointment)
  end

  private

  def send_sms_reminder(appointment) # rubocop:disable Metrics/MethodLength
    client = Notifications::Client.new(api_key(appointment.schedule_type))

    client.send_sms(
      phone_number: appointment.canonical_sms_number,
      template_id: template_for(appointment),
      reference: appointment.to_param,
      personalisation: {
        date: "#{appointment.start_at.to_s(:govuk_date_short)} (#{appointment.timezone})"
      }
    )
  rescue Notifications::Client::BadRequestError
    SmsReminderFailureActivity.from(appointment)

    false
  end

  def template_for(appointment)
    if appointment.bsl_video?
      BSL_TEMPLATE_ID
    elsif appointment.due_diligence?
      DUE_DILIGENCE_TEMPLATE_ID
    else
      STANDARD_TEMPLATE_ID
    end
  end

  def create_activity(appointment)
    SmsReminderActivity.create!(
      appointment:,
      owner: appointment.guider
    )
  end
end
