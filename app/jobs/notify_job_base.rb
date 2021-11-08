require 'notifications/client'

class NotifyJobBase < ApplicationJob
  queue_as :default

  rescue_from(Notifications::Client::RequestError) do |exception|
    Bugsnag.notify(exception)
  end

  protected

  def api_key(schedule_type)
    ENV["#{schedule_type.upcase}_NOTIFY_API_KEY"]
  end
end
