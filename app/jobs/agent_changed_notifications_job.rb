class AgentChangedNotificationsJob < ApplicationJob
  queue_as :default

  def perform(appointment)
    recipients_for(appointment).each do |recipient|
      AppointmentMailer.resource_manager_appointment_changed(appointment, recipient).deliver_later
    end
  end
end
