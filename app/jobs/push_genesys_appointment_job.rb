class PushGenesysAppointmentJob < ApplicationJob
  queue_as :single

  def perform(appointment)
    return unless appointment.push_to_genesys?

    Genesys::Push.new(appointment).call
  end
end
