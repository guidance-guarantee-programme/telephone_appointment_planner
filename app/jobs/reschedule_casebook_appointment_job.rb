class RescheduleCasebookAppointmentJob < ApplicationJob
  discard_on Casebook::ApiError do |_, error|
    Bugsnag.notify(error)
  end

  queue_as :default

  def perform(appointment)
    return unless appointment.casebook_pushable_guider?

    Casebook::Cancel.new(appointment).call if appointment.casebook_appointment_id?

    Casebook::Push.new(appointment).call
  end
end
