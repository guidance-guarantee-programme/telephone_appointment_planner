module Api
  module V1
    class SummaryDocumentsController < Api::V1::ApplicationController
      def create
        activity = SummaryDocumentActivity.new(summary_document_activity_params)
        if activity.save
          PusherActivityCreatedJob.perform_later(nil, activity.id)
          head :created
        else
          render json: activity.errors, status: :unprocessable_entity
        end
      end

      private

      def summary_document_activity_params
        {
          appointment_id: params[:appointment_id],
          owner: User.find_by(uid: params[:owner_uid]),
          message: params[:delivery_method]
        }
      end
    end
  end
end
