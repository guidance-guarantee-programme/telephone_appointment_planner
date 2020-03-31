class AppointmentRescheduledNotificationsJob < ApplicationJob
  queue_as :default

  def perform(appointment)
    return if appointment.tpas_guider? || appointment.ni_guider?

    recipients_for(appointment).each do |recipient|
      AppointmentMailer.resource_manager_appointment_rescheduled(
        appointment,
        recipient
      ).deliver_later
    end
  end

  private

  def recipients_for(appointment)
    appointment.resource_managers.pluck(:email)
  end
end
