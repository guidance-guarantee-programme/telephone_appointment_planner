class GuidersController < ApplicationController
  def index
    render json: User.guiders.active
  end
end
