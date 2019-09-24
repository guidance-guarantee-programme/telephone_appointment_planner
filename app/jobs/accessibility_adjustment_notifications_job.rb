class AccessibilityAdjustmentNotificationsJob < ApplicationJob
  queue_as :default

  def perform(appointment)
    appointment.resource_managers.each do |rm|
      AppointmentMailer.accessibility_adjustment(appointment, rm).deliver_later
    end
  end
end
