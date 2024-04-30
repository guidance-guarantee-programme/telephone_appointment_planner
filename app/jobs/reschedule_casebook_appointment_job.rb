class RescheduleCasebookAppointmentJob < CasebookJob
  def perform(appointment)
    return unless appointment.casebook_pushable_guider? && appointment.casebook_appointment_id?

    Casebook::Reschedule.new(appointment).call
  end
end
