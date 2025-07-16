class OnlineReschedulingsController < ApplicationController
  def index
    @search = OnlineReschedulingsSearch.new(search_params)
    @results = @search.results.page(params[:page])
  end

  private

  def search_params
    params
      .fetch(:online_reschedulings_search, {})
      .permit(:q, :date_range, :processed)
      .merge(current_user:)
  end
end
