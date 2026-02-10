class CancelGenesysAppointmentJob < ApplicationJob
  def perform(appointment)
    return unless appointment.cancel_to_genesys?

    Genesys::Push.new(appointment).call
  end
end
