class ApplicationJob < ActiveJob::Base
  CAS_RECIPIENTS = Array('CAS_PWBooking@cas.org.uk').freeze
  OPS_SUPERVISOR = 'supervisors@maps.org.uk'.freeze

  protected

  def recipients_for(appointment)
    if appointment.tpas_guider?
      Array(OPS_SUPERVISOR)
    elsif appointment.cas_guider?
      CAS_RECIPIENTS
    else
      appointment.resource_managers.pluck(:email)
    end
  end
end
