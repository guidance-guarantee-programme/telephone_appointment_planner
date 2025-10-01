class RescheduleCasebookAppointmentJob < CasebookJob
  def perform(appointment)
    return if ignore?(appointment)

    if unpushed_new_casebook_appointment?(appointment)
      Casebook::Push.new(appointment).call
    elsif pushed_casebook_appointment_reallocated_to_non_casebook_guider?(appointment)
      Casebook::Cancel.new(appointment).call
    else
      Casebook::Cancel.new(appointment).call
      Casebook::Reschedule.new(appointment).call
    end
  end

  private

  def unpushed_new_casebook_appointment?(appointment)
    !appointment.casebook_appointment_id? && appointment.casebook_pushable_guider?
  end

  def pushed_casebook_appointment_reallocated_to_non_casebook_guider?(appointment)
    appointment.casebook_appointment_id? && !appointment.casebook_pushable_guider?
  end

  def ignore?(appointment)
    !appointment.casebook_pushable_guider? && !appointment.casebook_appointment_id?
  end
end
