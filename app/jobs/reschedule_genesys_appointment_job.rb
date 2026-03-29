class RescheduleGenesysAppointmentJob < ApplicationJob
  queue_as :single

  def perform(appointment)
    return unless appointment.genesys_operation_id?

    Genesys::Reschedule.new(appointment).call
  end
end
