class AdjustmentNotificationsJob < ApplicationJob
  queue_as :default

  def perform(appointment)
    recipients_for(appointment).each do |email|
      AppointmentMailer.adjustment(appointment, email).deliver_later
    end
  end
end
