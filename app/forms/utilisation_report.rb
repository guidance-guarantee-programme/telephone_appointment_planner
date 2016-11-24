require 'csv'

class UtilisationReport
  include ActiveModel::Model
  include Report

  attr_reader :date_range

  def initialize(params = {})
    @date_range = params[:date_range]
  end

  def generate
    CSV.generate do |csv|
      csv << [:booked_appointments, :bookable_slots, :blocked_slots]
      range.each do |day|
        csv << generate_for_day(day)
      end
    end
  end

  def file_name
    "utilisation-report-#{range_title}.csv"
  end

  private

  def generate_for_day(day)
    day_range = (day.beginning_of_day..day.end_of_day)
    bookable, blocked = bookable_and_blocked(day_range)
    [
      day,
      Appointment.where(start_at: day_range).count,
      bookable,
      blocked
    ]
  end

  def bookable_and_blocked(day_range)
    slots = BookableSlot.within_date_range(day_range.begin, day_range.end)
    bookable = slots.without_appointments.without_holidays.count
    blocked = slots.count - bookable
    [bookable, blocked]
  end
end
