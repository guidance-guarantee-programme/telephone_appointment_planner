class RescheduleGenesysAppointmentJob < ApplicationJob
  def perform(appointment)
    return if ignore?(appointment)

    if unpushed_appointment_reallocated_to_genesys_guider?(appointment)
      Genesys::Push.new(appointment).call
    elsif pushed_appointment_reallocated_to_non_genesys_guider?(appointment)
      Genesys::Push.new(appointment).call
    else
      Genesys::Reschedule.new(appointment).call
    end
  end

  def ignore?(appointment)
    !appointment.genesys_operation_id? && !appointment.genesys_pushable_guider?
  end

  def unpushed_appointment_reallocated_to_genesys_guider?(appointment)
    appointment.genesys_pushable_guider? && !appointment.genesys_operation_id?
  end

  def pushed_appointment_reallocated_to_non_genesys_guider?(appointment)
    appointment.genesys_operation_id? && !appointment.genesys_pushable_guider?
  end
end
