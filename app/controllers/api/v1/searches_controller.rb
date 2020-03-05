module Api
  module V1
    class SearchesController < Api::V1::ApplicationController
      def index
        @results = AppointmentApiSearch.new(params[:query]).call

        render json: @results, each_serializer: AppointmentSearchSerializer
      end
    end
  end
end
