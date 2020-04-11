class GuidersController < ApplicationController
  def index
    @guiders = current_user.colleagues.guiders.active

    render json: @guiders
  end
end
