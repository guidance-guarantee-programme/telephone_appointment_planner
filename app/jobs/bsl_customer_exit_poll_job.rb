class BslCustomerExitPollJob < NotifyJobBase
  BSL_EXIT_POLL_SMS_TEMPLATE_ID = 'ae1ad874-9626-4e8c-afe9-e3867aa43986'.freeze

  queue_as :default

  include SmsFailureRecordable

  def perform(appointment)
    send_sms(appointment) if appointment.mobile?

    AppointmentMailer.bsl_customer_exit_poll(appointment) if appointment.email?

    BslCustomerExitPollActivity.from(appointment)
  end

  private

  def send_sms(appointment)
    client = Notifications::Client.new(api_key(appointment.schedule_type))

    client.send_sms(
      phone_number: appointment.canonical_sms_number,
      template_id: BSL_EXIT_POLL_SMS_TEMPLATE_ID,
      reference: appointment.to_param,
      personalisation: {
        date: "#{appointment.start_at.to_formatted_s(:govuk_date_short)} (#{appointment.timezone})"
      }
    )
  end
end
