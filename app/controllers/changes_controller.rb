class ChangesController < ApplicationController
  before_action :authenticate_user!

  def index
    @appointment = Appointment.find(params[:appointment_id])
    @audits = AuditPresenter.wrap(@appointment.audits.where.not(action: :create).reverse)
  end
end
