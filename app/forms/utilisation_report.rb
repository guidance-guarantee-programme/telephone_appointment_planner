require 'csv'

class UtilisationReport
  include ActiveModel::Model
  include Report

  attr_accessor :date_range
  attr_accessor :current_user

  attr_writer :schedule_type

  validates :date_range, presence: true
  validates :schedule_type, presence: true, if: -> { current_user.tpas? }

  def generate
    CSV.generate do |csv|
      csv << %i(date booked_appointments bookable_slots blocked_slots cancelled_appointments)
      range.each do |day|
        csv << generate_for_day(day)
      end
    end
  end

  def file_name
    "utilisation-report-#{range_title}.csv"
  end

  def schedule_type
    return User::PENSION_WISE_SCHEDULE_TYPE unless current_user.tpas?

    @schedule_type
  end

  private

  def role_scoped(scope)
    return scope if current_user.contact_centre_team_leader?

    scope
      .includes(:guider)
      .where(users: { organisation_content_id: current_user.organisation_content_id })
  end

  def generate_for_day(day)
    day_range = (day.beginning_of_day..day.end_of_day)
    scope = Appointment.where(start_at: day_range, schedule_type: schedule_type)
    bookable, blocked = bookable_and_blocked(day_range)

    [
      day,
      role_scoped(scope).not_cancelled.count,
      bookable,
      blocked,
      role_scoped(scope).cancelled.count
    ]
  end

  def bookable_and_blocked(day_range)
    scope = role_scoped(
      BookableSlot
      .within_date_range(day_range.begin, day_range.end)
      .where(schedule_type: schedule_type)
    )

    bookable = scope.without_holidays.count
    blocked  = scope.count - bookable
    [bookable, blocked]
  end
end
