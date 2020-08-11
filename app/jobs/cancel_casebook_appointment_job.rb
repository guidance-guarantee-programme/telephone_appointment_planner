class CancelCasebookAppointmentJob < ApplicationJob
  queue_as :default

  discard_on Casebook::ApiError do |_, error|
    Bugsnag.notify(error)
  end

  def perform(appointment)
    return unless appointment.casebook_appointment_id? && appointment.cancelled?

    Casebook::Cancel.new(appointment).call
  end
end
