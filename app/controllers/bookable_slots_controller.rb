class BookableSlotsController < ApplicationController
  def available
    render json: BookableSlot
      .with_guider_count(Time.zone.now.to_date, 6.weeks.from_now.to_date)
      .to_json
  end
end
