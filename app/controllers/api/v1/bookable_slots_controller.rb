module Api
  module V1
    class BookableSlotsController < ActionController::Base
      def index
        render json: BookableSlot.grouped(filtered_provider_ids)
      end

      private

      def filtered_provider_ids
        return unless params[:lloyds]

        Provider.lloyds_providers.map(&:id)
      end
    end
  end
end
