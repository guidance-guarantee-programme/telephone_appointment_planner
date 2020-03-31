class AppointmentCreatedNotificationsJob < ApplicationJob
  queue_as :default

  def perform(appointment)
    return if ignore?(appointment)

    recipients_for(appointment).each do |recipient|
      AppointmentMailer.resource_manager_appointment_created(
        appointment,
        recipient
      ).deliver_later
    end
  end

  private

  def ignore?(appointment)
    appointment.tpas_guider? || appointment.cas_guider? || appointment.ni_guider?
  end

  def recipients_for(appointment)
    appointment.resource_managers.pluck(:email)
  end
end
