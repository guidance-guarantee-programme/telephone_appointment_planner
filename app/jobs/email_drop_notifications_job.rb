class EmailDropNotificationsJob < ApplicationJob
  queue_as :default

  def perform(appointment)
    recipients_for(appointment).without(appointment.email).each do |recipient|
      AppointmentMailer.resource_manager_email_dropped(appointment, recipient).deliver_later
    end
  end
end
