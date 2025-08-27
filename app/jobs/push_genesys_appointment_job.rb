class PushGenesysAppointmentJob < ApplicationJob
  def perform(appointment)
    return unless appointment.push_to_genesys?

    Genesys::Push.new(appointment).call
  end
end
