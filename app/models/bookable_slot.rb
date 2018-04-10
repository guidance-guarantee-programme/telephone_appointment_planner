# rubocop:disable Metrics/ClassLength
class BookableSlot < ApplicationRecord
  GUIDER_CONFERENCE_DAYS = Date.parse('2018-07-17')..Date.parse('2018-07-18')

  belongs_to :guider, class_name: 'User'

  scope :for_guider, ->(guider) { where(guider: guider) }

  def self.generate_for_six_weeks
    User.guiders.each do |guider|
      generate_for_guider(guider)
    end
  end

  def self.within_date_range(from, to)
    where("#{quoted_table_name}.start_at > ? AND #{quoted_table_name}.end_at < ?", from, to)
  end

  def self.without_guider_conference_days
    where.not(
      "#{quoted_table_name}.start_at::date in (?)",
      GUIDER_CONFERENCE_DAYS
    )
  end

  def self.next_valid_start_date(user = nil)
    return Time.zone.now.advance(hours: 1) if user && user.resource_manager?

    BusinessDays.from_now(1).change(hour: 18, min: 30)
  end

  def self.find_available_slot(start_at)
    bookable
      .where(start_at: start_at)
      .limit(1)
      .order('RANDOM()')
      .first
  end

  def self.bookable(from = nil, to = nil)
    without_appointments(from, to)
      .without_guider_conference_days
      .without_holidays
  end

  def self.grouped # rubocop:disable Metrics/AbcSize
    from = next_valid_start_date
    to   = 8.weeks.from_now.end_of_day

    bookable(from, to)
      .within_date_range(from, to)
      .select("#{quoted_table_name}.start_at::date as start_date")
      .select("#{quoted_table_name}.start_at")
      .order('start_date asc, start_at asc')
      .group_by(&:start_date)
      .transform_values { |value| value.map(&:start_at).uniq }
  end

  def self.without_appointments(from = nil, to = nil) # rubocop:disable Metrics/MethodLength
    joins(<<-SQL
            LEFT JOIN appointments ON
              appointments.guider_id = #{quoted_table_name}.guider_id
              #{reduce_by_range(:appointments, from, to)}
              AND NOT appointments.status IN (
                #{Appointment.statuses['cancelled_by_customer']},
                #{Appointment.statuses['cancelled_by_pension_wise']},
                #{Appointment.statuses['cancelled_by_customer_sms']}
              )
              AND (
                appointments.start_at, appointments.end_at
              ) OVERLAPS (
                #{quoted_table_name}.start_at, #{quoted_table_name}.end_at
              )
            SQL
         )
      .where('appointments.start_at IS NULL')
  end

  def self.without_holidays # rubocop:disable Metrics/MethodLength
    joins(<<-SQL
          LEFT JOIN holidays ON
            -- The holiday is specifically for the user, or it is for everyone
            (holidays.user_id = #{quoted_table_name}.guider_id OR holidays.user_id IS NULL)
            AND (
              holidays.start_at, holidays.end_at
            ) OVERLAPS (
              #{quoted_table_name}.start_at, #{quoted_table_name}.end_at
            )
            SQL
         )
      .where('holidays.start_at IS NULL')
  end

  def self.reduce_by_range(table, from, to)
    return '' unless from && to

    sanitize_sql(["AND (#{table}.start_at > ? AND #{table}.end_at < ?)", from, to])
  end

  def self.starting_after_next_valid_start_date(user)
    where("#{quoted_table_name}.start_at > ?", next_valid_start_date(user))
  end

  def self.with_guider_count(user, from, to)
    select("DISTINCT #{quoted_table_name}.start_at, #{quoted_table_name}.end_at, count(1) AS guiders")
      .bookable
      .starting_after_next_valid_start_date(user)
      .for_organisation(user)
      .group("#{quoted_table_name}.start_at, #{quoted_table_name}.end_at")
      .within_date_range(from, to)
      .map do |us|
        { guiders: us.attributes['guiders'], start: us.start_at, end: us.end_at, selected: false }
      end
  end

  def self.for_organisation(user, scoped: true)
    return where('1 = 1') if scoped && user.tp_agent?

    joins(:guider)
      .where(users: { organisation_content_id: user.organisation_content_id })
  end

  def self.generate_for_guider(guider)
    where(guider: guider).delete_all

    return unless guider.active?

    generation_range.each do |day|
      active_schedule = guider.schedules.active(day)
      next unless active_schedule

      available_slots = active_schedule.slots.where(day_of_week: day.wday)

      available_slots.each do |available_slot|
        create_from_slot!(guider, day, available_slot)
      end
    end
  end

  def self.create_from_slot!(guider, day, slot)
    start_at = day.in_time_zone.change(
      hour: slot.start_hour,
      min: slot.start_minute
    )
    end_at = day.in_time_zone.change(
      hour: slot.end_hour,
      min: slot.end_minute
    )
    create!(guider: guider, start_at: start_at, end_at: end_at)
  end

  def self.generation_range
    Time.zone.now.to_date..8.weeks.from_now.to_date
  end
end
