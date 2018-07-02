require 'notifications/client'

class SmsAppointmentReminderJob < SmsJobBase
  TEMPLATE_ID = '14d350d2-f962-4daa-b3b8-e6c3696864c0'.freeze

  def perform(appointment)
    return unless api_key

    send_sms_reminder(appointment)
    create_activity(appointment)
  end

  private

  def send_sms_reminder(appointment)
    sms_client.send_sms(
      phone_number: appointment.canonical_sms_number,
      template_id: TEMPLATE_ID,
      reference: appointment.to_param,
      personalisation: {
        date: "#{appointment.start_at.to_s(:govuk_date_short)} (#{appointment.timezone})"
      }
    )
  end

  def create_activity(appointment)
    SmsReminderActivity.create!(
      appointment: appointment,
      owner: appointment.guider
    )
  end
end
