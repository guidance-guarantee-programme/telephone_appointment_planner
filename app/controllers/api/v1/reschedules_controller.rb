module Api
  module V1
    class ReschedulesController < Api::V1::ApplicationController
      def create
        @reschedule = AppointmentRescheduling.new(create_params)

        if @reschedule.reschedule
          SmsAppointmentConfirmationJob.perform_later(@reschedule.model)
          Notifier.new(@reschedule.model).call

          head :ok
        else
          head :unprocessable_entity
        end
      end

      private

      def create_params
        params.permit(:reference, :date_of_birth, :reason, :start_at)
      end
    end
  end
end
