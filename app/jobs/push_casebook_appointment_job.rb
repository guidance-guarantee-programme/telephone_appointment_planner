class PushCasebookAppointmentJob < ActiveJob::Base
  discard_on Casebook::ApiError do |_, error|
    Bugsnag.notify(error)
  end

  queue_as :default

  def perform(appointment)
    return unless appointment.push_to_casebook?

    Casebook::Push.new(appointment).call
  end
end
