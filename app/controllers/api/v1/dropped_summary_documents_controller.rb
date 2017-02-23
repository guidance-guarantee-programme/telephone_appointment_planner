module Api
  module V1
    class DroppedSummaryDocumentsController < Api::V1::ApplicationController
      def create
        DroppedSummaryDocumentActivity.from(appointment)

        head :created
      end

      private

      def appointment
        Models::Appointment.find(params[:appointment_id])
      end
    end
  end
end
