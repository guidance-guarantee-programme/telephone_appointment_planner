class SlackPingerJob < ActiveJob::Base
  queue_as :default

  def perform
    return unless hook_uri

    number_of_appointments = Appointment.where(
      created_at: 1.hour.ago.beginning_of_hour..1.hour.ago.end_of_hour
    ).count

    return unless number_of_appointments.positive?

    hook = WebHook.new(hook_uri)
    hook.call(payload(number_of_appointments))
  end

  private

  def hook_uri
    ENV['APPOINTMENTS_SLACK_PINGER_URI']
  end

  def payload(number_of_appointments)
    {
      username: 'pat',
      channel: '#online-bookings',
      text: ":tada: #{number_of_appointments} in the last hour :tada:",
      icon_emoji: ':pat:'
    }
  end
end
