class GuidersController < ApplicationController
  def index
    @guiders = current_user
               .colleagues
               .guiders
               .active
               .or(User.recently_suspended_guiders(current_user))

    render json: @guiders
  end
end
