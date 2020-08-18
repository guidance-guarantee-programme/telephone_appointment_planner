class RescheduleCasebookAppointmentJob < CasebookJob
  def perform(appointment)
    return unless appointment.casebook_pushable_guider?

    Casebook::Cancel.new(appointment).call if appointment.casebook_appointment_id?

    Casebook::Push.new(appointment).call
  end
end
