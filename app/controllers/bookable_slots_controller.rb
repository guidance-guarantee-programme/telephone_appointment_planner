class BookableSlotsController < ApplicationController
  def index
    slots = BookableSlot
            .without_holidays
            .within_date_range(start_at, end_at)
    slots = slots.for_guider(current_user) if scoped_to_me?
    render json: slots
  end

  def available
    render json: BookableSlot
      .with_guider_count(
        Time.zone.parse(params[:start]),
        Time.zone.parse(params[:end])
      )
  end

  def scoped_to_me?
    params.key?(:mine)
  end

  private

  def start_at
    params[:start].to_date.beginning_of_day
  end

  def end_at
    params[:end].to_date.beginning_of_day
  end
end
