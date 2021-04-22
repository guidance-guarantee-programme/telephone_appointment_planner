class AdjustmentNotificationsJob < ApplicationJob
  queue_as :default

  def perform(appointment)
    recipients_for(appointment).each do |email|
      AppointmentMailer.adjustment(appointment, email).deliver_later
    end
  end

  private

  def recipients_for(appointment)
    if appointment.tpas_guider?
      Array('supervisors@maps.org.uk')
    elsif appointment.cas_guider?
      CAS_RECIPIENTS
    else
      appointment.resource_managers.pluck(:email)
    end
  end
end
