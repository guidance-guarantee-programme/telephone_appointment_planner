class GuidersController < ApplicationController
  def index
    @guiders = User.guiders.active

    render json: @guiders if stale?(@guiders)
  end
end
