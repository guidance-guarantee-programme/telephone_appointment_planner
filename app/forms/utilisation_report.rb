require 'csv'

class UtilisationReport
  include ActiveModel::Model
  include Report

  attr_reader :date_range

  def initialize(params = {})
    @date_range = params[:date_range]
  end

  def generate
    bookable, blocked = bookable_and_blocked
    CSV.generate do |csv|
      csv << [:booked_appointments, :bookable_slots, :blocked_slots]
      csv << [Appointment.where(start_at: range).count, bookable, blocked]
    end
  end

  def file_name
    integer_range = range ? "#{range.begin.to_i}-#{range.end.to_i}" : nil
    "utilisation-report-#{integer_range}.csv"
  end

  private

  def bookable_and_blocked
    bookable = slots_within_range.without_appointments.without_holidays.count
    blocked = slots_within_range.count - bookable
    [bookable, blocked]
  end

  def slots_within_range
    if range.present?
      BookableSlot.within_date_range(range.begin, range.end)
    else
      BookableSlot.all
    end
  end
end
