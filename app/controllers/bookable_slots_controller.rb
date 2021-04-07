class BookableSlotsController < ApplicationController
  def index
    @bookable_slots = bookable_slots

    render json: @bookable_slots
  end

  def available
    render json: BookableSlot.with_guider_count(
      current_user,
      Time.zone.parse(params[:start]),
      Time.zone.parse(params[:end])
    )
  end

  def lloyds
    render json: BookableSlot.with_guider_count(
      current_user,
      Time.zone.parse(params[:start]),
      Time.zone.parse(params[:end]),
      lloyds: true
    )
  end

  def scoped_to_me?
    params.key?(:mine)
  end

  private

  def bookable_slots
    slots = BookableSlot
            .within_date_range(start_at, end_at)

    if scoped_to_me?
      slots.without_holidays.for_guider(current_user)
    else
      slots.for_organisation(current_user, scoped: false)
    end
  end

  def start_at
    params[:start].to_date.beginning_of_day
  end

  def end_at
    params[:end].to_date.beginning_of_day
  end
end
