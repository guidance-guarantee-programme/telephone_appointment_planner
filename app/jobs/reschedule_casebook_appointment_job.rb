class RescheduleCasebookAppointmentJob < CasebookJob
  def perform(appointment)
    return unless appointment.casebook_pushable_guider?

    Casebook::Reschedule.new(appointment).call
  end
end
