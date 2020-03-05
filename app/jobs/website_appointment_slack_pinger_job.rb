class WebsiteAppointmentSlackPingerJob < ActiveJob::Base
  queue_as :default

  def perform
    return unless hook_uri

    hook = WebHook.new(hook_uri)
    hook.call(payload)
  end

  private

  def hook_uri
    ENV['APPOINTMENTS_SLACK_PINGER_URI']
  end

  def payload
    {
      username: 'dave',
      channel: '#online-bookings',
      text: ':tada: customer telephone booking :tada:',
      icon_emoji: ':mullet:'
    }
  end
end
