class AppointmentRescheduledAwayNotificationsJob < ApplicationJob
  def perform(appointment)
    return if appointment.previous_guider.tpas?

    recipients_for(appointment.previous_guider).each do |recipient|
      AppointmentMailer.resource_manager_appointment_rescheduled_away(
        appointment,
        recipient
      ).deliver_later
    end
  end

  private

  def recipients_for(guider)
    return CAS_RECIPIENTS if guider.cas?

    guider.resource_managers.pluck(:email)
  end
end
