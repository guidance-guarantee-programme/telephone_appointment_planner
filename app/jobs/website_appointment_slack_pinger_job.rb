class WebsiteAppointmentSlackPingerJob < ActiveJob::Base
  queue_as :default

  def perform(appointment)
    return unless hook_uri

    hook = WebHook.new(hook_uri)
    hook.call(payload(appointment))
  end

  private

  def hook_uri
    ENV['APPOINTMENTS_SLACK_PINGER_URI']
  end

  def payload(appointment)
    pension_provider = PensionProvider[appointment.pension_provider]

    {
      username: 'dave',
      channel: '#online-bookings',
      text: ":tada: customer telephone booking #{pension_provider} :tada:",
      icon_emoji: ':mullet:'
    }
  end
end
