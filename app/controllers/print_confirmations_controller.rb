class PrintConfirmationsController < ApplicationController
  def create
    @appointment = Appointment.for_organisation(current_user).find(params[:appointment_id])
    @appointment.resend_print_confirmation

    redirect_back success: 'The appointment confirmation letter was resent to the customer.',
                  fallback_location: root_path
  end
end
