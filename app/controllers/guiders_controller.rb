class GuidersController < ApplicationController
  def index
    render json: User.guiders
  end
end
