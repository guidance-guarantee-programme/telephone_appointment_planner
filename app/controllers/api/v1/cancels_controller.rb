module Api
  module V1
    class CancelsController < Api::V1::ApplicationController
      def create
        @appointment = Api::V1::AppointmentCancellation.new(cancellation_params)

        if @appointment.cancel
          send_notifications(@appointment.model)
          head :created
        else
          head :unprocessable_entity
        end
      end

      private

      def send_notifications(appointment)
        Notifier.new(appointment).call
      end

      def cancellation_params
        params.permit(:appointment_id, :date_of_birth, :secondary_status, :other_reason)
      end
    end
  end
end
