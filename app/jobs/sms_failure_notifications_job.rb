class SmsFailureNotificationsJob < ApplicationJob
  queue_as :default

  def perform(appointment)
    recipients_for(appointment).each do |recipient|
      AppointmentMailer.resource_manager_sms_failure(appointment, recipient).deliver_later
    end
  end
end
