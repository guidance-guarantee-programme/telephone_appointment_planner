class ChangesController < ApplicationController
  before_action :authenticate_user!

  def index
    @appointment = Appointment.find(params[:appointment_id])
    @audits = AuditPresenter.wrap(audits_for(@appointment))
  end

  private

  def audits_for(appointment)
    appointment
      .own_and_associated_audits
      .where(auditable_type: Appointment.name)
      .where.not(action: :create)
      .or(
        appointment
        .own_and_associated_audits
        .where(auditable_type: VulnerabilityProfile.name)
      ).reverse
  end
end
