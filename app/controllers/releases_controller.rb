class ReleasesController < ApplicationController
  def index
    @releases = Release.order(released_on: :desc).page(params[:page])
  end
end
