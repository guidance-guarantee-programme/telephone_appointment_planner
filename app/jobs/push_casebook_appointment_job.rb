class PushCasebookAppointmentJob < CasebookJob
  def perform(appointment)
    return unless appointment.push_to_casebook?

    Casebook::Push.new(appointment).call

    return unless casebook_rebooked?(appointment)

    Casebook::Cancel.new(appointment.rebooked_from).call
  end

  private

  def casebook_rebooked?(appointment)
    appointment.rebooked_from&.casebook_appointment_id?
  end
end
