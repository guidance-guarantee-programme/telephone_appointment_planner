module Api
  module V1
    class AppointmentsController < ActionController::Base
      include GDS::SSO::ControllerMethods

      before_action { authorise_user!(User::PENSION_WISE_API_PERMISSION) }

      def create
        @appointment = Appointment.new(appointment_params)

        if @appointment.create
          AppointmentMailer.confirmation(@appointment.model).deliver_later
          head :created
        else
          render json: @appointment.errors, status: :unprocessable_entity
        end
      end

      private

      def appointment_params # rubocop:disable Metrics/MethodLength
        params.require(:appointment).permit(
          :start_at,
          :first_name,
          :last_name,
          :email,
          :phone,
          :memorable_word,
          :date_of_birth,
          :dc_pot_confirmed,
          :opt_out_of_market_research
        ).merge(agent: current_user)
      end
    end
  end
end
