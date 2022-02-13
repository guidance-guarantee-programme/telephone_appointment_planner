class EmailDropNotificationsJob < ApplicationJob
  queue_as :default

  def perform(appointment)
    recipients_for(appointment).each do |recipient|
      AppointmentMailer.resource_manager_email_dropped(appointment, recipient).deliver_later
    end
  end

  private

  def recipients_for(appointment)
    appointment.resource_managers.pluck(:email).without(appointment.email)
  end
end
