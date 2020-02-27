module Api
  module V1
    class SearchesController < ApplicationController
      before_action :authorise_for_api_users!

      def index
        @results = AppointmentApiSearch.new(params[:query]).call

        render json: @results, each_serializer: AppointmentSearchSerializer
      end
    end
  end
end
