module Api
  module V1
    class BookableSlotsController < ActionController::Base
      def index
        render json: BookableSlot.grouped
      end
    end
  end
end
