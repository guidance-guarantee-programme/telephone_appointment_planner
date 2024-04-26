class CancelCasebookAppointmentJob < CasebookJob
  def perform(appointment)
    return unless appointment.casebook_appointment_id? && appointment.cancelled?

    Casebook::Cancel.new(appointment).call
  end
end
