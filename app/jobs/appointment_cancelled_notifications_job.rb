class AppointmentCancelledNotificationsJob < ApplicationJob
  queue_as :default

  def perform(appointment)
    return if appointment.tpas_guider?

    recipients_for(appointment).each do |recipient|
      AppointmentMailer.resource_manager_appointment_cancelled(
        appointment,
        recipient
      ).deliver_later
    end
  end

  private

  def recipients_for(appointment)
    return CAS_RECIPIENTS if appointment.cas_guider?

    appointment.resource_managers.pluck(:email)
  end
end
