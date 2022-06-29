class BookableSlotsController < ApplicationController
  def index
    @bookable_slots = bookable_slots

    render json: @bookable_slots
  end

  def available
    render json: BookableSlot.with_guider_count(
      filtered_user,
      Time.zone.parse(params[:start]),
      Time.zone.parse(params[:end]),
      schedule_type: schedule_type,
      scoped: !rescheduling?
    )
  end

  def lloyds
    render json: BookableSlot.with_guider_count(
      filtered_user,
      Time.zone.parse(params[:start]),
      Time.zone.parse(params[:end]),
      lloyds: !rescheduling?
    )
  end

  def scoped_to_me?
    params.key?(:mine)
  end

  private

  def schedule_type
    params[:schedule_type]
  end

  def rescheduling?
    params[:rescheduling] == 'true'
  end

  def filtered_user
    return current_user unless rescheduling? && (current_user.tp? || current_user.tpas_agent?)

    appointment = Appointment.find(params[:id])
    appointment.guider
  rescue ActiveRecord::RecordNotFound
    current_user
  end

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
