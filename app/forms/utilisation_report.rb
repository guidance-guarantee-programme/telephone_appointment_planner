require 'csv'

class UtilisationReport
  include ActiveModel::Model
  include Report

  attr_reader :date_range

  validates :date_range, presence: true

  def initialize(params = {})
    @date_range = params[:date_range]
  end

  def generate
    CSV.generate do |csv|
      csv << %i(date booked_appointments bookable_slots blocked_slots cancelled_appointments late_cancellations)
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
      Appointment.not_cancelled.where(start_at: day_range).count,
      bookable,
      blocked,
      cancellations(day_range).count,
      late_cancellations(day_range).count
    ]
  end

  def bookable_and_blocked(day_range)
    slots = BookableSlot.within_date_range(day_range.begin, day_range.end)
    bookable = slots.without_holidays.count
    blocked = slots.count - bookable
    [bookable, blocked]
  end

  def cancellations(day_range)
    Appointment.cancelled.where(start_at: day_range)
  end

  def late_cancellations(day_range)
    cancellations(day_range).select do |appointment|
      late_cancellation?(appointment)
    end
  end

  def late_cancellation?(appointment)
    appointment.audits.any? do |audit|
      audit.audited_changes.keys.include?('status') &&
        Appointment.cancellation_status?(audit.audited_changes['status'].last) &&
        audit.created_at > BusinessDays.before(appointment.start_at, 2).beginning_of_day
    end
  end
end
