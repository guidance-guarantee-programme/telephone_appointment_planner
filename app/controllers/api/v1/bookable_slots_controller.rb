module Api
  module V1
    class BookableSlotsController < ActionController::Base
      class InvalidScheduleType < StandardError; end

      rescue_from InvalidScheduleType do
        head :unprocessable_entity
      end

      def index
        @slots = BookableSlot.grouped(filtered_provider_ids, schedule_type, day)

        Rails.logger.info("Empty times returned for #{day}") if day.present? && @slots.empty?

        render json: @slots
      end

      private

      def day
        params[:day]
      end

      def schedule_type
        @schedule_type = params.fetch(:schedule_type) { User::PENSION_WISE_SCHEDULE_TYPE }

        return @schedule_type if User::ALL_SCHEDULE_TYPES.include?(@schedule_type)

        raise InvalidScheduleType
      end

      def filtered_provider_ids
        return unless params[:lloyds]

        Provider.lloyds_providers.map(&:id)
      end
    end
  end
end
