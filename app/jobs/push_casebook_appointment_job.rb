class PushCasebookAppointmentJob < CasebookJob
  def perform(appointment)
    return unless appointment.push_to_casebook?

    Casebook::Push.new(appointment).call
  end
end
