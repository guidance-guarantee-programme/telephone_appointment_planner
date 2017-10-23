module Api
  module V1
    class AppointmentsController < Api::V1::ApplicationController
      def create
        @appointment = Api::V1::Appointment.new(appointment_params)

        if @appointment.create
          send_notifications(@appointment)
          head :created, location: @appointment.model
        else
          render json: @appointment.errors, status: :unprocessable_entity
        end
      end

      private

      def send_notifications(appointment)
        WebsiteAppointmentSlackPingerJob.perform_later
        CustomerUpdateJob.perform_later(appointment.model, CustomerUpdateActivity::CONFIRMED_MESSAGE)
      end

      def appointment_params # rubocop:disable Metrics/MethodLength
        params.permit(
          :start_at,
          :first_name,
          :last_name,
          :email,
          :phone,
          :memorable_word,
          :date_of_birth,
          :dc_pot_confirmed,
          :opt_out_of_market_research,
          :where_you_heard
        ).merge(agent: current_user)
      end
    end
  end
end
