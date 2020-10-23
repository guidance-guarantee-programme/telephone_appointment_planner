class ConsentsController < ApplicationController
  layout 'pdf'

  skip_before_action :authenticate_user!

  rescue_from ActiveRecord::RecordNotFound do
    head :not_found
  end

  def create; end

  def show
    @appointment = Appointment.find(params[:appointment_id])

    raise ActiveRecord::RecordNotFound unless @appointment.generated_consent_form.attached?

    redirect_to rails_blob_url(@appointment.generated_consent_form, disposition: :attachment)
  end
end
