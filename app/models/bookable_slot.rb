# rubocop:disable Metrics/ClassLength
class BookableSlot < ApplicationRecord
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

  def self.next_valid_start_date(user = nil, schedule_type = User::PENSION_WISE_SCHEDULE_TYPE)
    return Time.zone.now if user&.resource_manager?

    if schedule_type == User::DUE_DILIGENCE_SCHEDULE_TYPE
      next_valid_due_diligence_start_date
    else
      BusinessDays.from_now(1).change(hour: 21, min: 0).in_time_zone('London')
    end
  end

  def self.next_valid_due_diligence_start_date # rubocop:disable AbcSize
    case Date.current
    when '2021-11-30'.to_date..'2021-12-02'.to_date
      Date.tomorrow.to_time.change(hour: 7).in_time_zone('London')
    when '2021-12-03'.to_date..'2021-12-05'.to_date
      Time.zone.parse('2021-12-06 07:00').in_time_zone('London')
    else
      BusinessDays.from_now(5).change(hour: 21, min: 0).in_time_zone('London')
    end
  end

  def self.find_available_slot(start_at, agent, schedule_type = User::PENSION_WISE_SCHEDULE_TYPE)
    scope = bookable.where(start_at: start_at)
    scope = scope.for_organisation(agent) if agent
    scope = for_schedule_type(schedule_type: schedule_type, scope: scope)

    scope.limit(1).order('RANDOM()').first
  end

  def self.bookable(from = nil, to = nil)
    without_appointments(from, to)
      .without_holidays
  end

  def self.grouped(organisation_id = nil, schedule_type = User::PENSION_WISE_SCHEDULE_TYPE) # rubocop:disable AbcSize, MethodLength, LineLength
    from = next_valid_start_date(nil, schedule_type)
    to   = BusinessDays.from_now(40).end_of_day

    scope = bookable(from, to).within_date_range(from, to)
    scope = scope.joins(:guider).where(users: { organisation_content_id: organisation_id }) if organisation_id
    scope = for_schedule_type(schedule_type: schedule_type, scope: scope)

    scope
      .select("#{quoted_table_name}.start_at::date as start_date")
      .select("#{quoted_table_name}.start_at")
      .order('start_date asc, start_at asc')
      .group_by(&:start_date)
      .transform_values { |value| value.map(&:start_at).uniq }
  end

  def self.for_schedule_type(schedule_type: User::PENSION_WISE_SCHEDULE_TYPE, scope: self)
    scope.where(schedule_type: schedule_type)
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
              AND appointments.schedule_type = #{quoted_table_name}.schedule_type
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

  def self.with_guider_count(user, from, to, lloyds: false, schedule_type: User::PENSION_WISE_SCHEDULE_TYPE) # rubocop:disable AbcSize, LineLength
    select("DISTINCT #{quoted_table_name}.start_at, #{quoted_table_name}.end_at, count(1) AS guiders")
      .bookable
      .starting_after_next_valid_start_date(user)
      .for_schedule_type(schedule_type: schedule_type)
      .for_organisation(user, lloyds: lloyds)
      .group("#{quoted_table_name}.start_at, #{quoted_table_name}.end_at")
      .within_date_range(from, to)
      .map do |us|
        { guiders: us.attributes['guiders'], start: us.start_at, end: us.end_at, selected: false }
      end
  end

  def self.for_organisation(user, scoped: true, lloyds: false)
    scope = joins(:guider)

    if lloyds
      scope.where(users: { organisation_content_id: Provider.lloyds_providers.map(&:id) })
    else
      return where('1 = 1') if scoped && user.tp_agent?

      scope.where(users: { organisation_content_id: user.organisation_content_id })
    end
  end

  def self.generate_for_guider(guider)
    guider.delete_future_slots!

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
    start_at = day.in_time_zone.change(hour: slot.start_hour, min: slot.start_minute)
    end_at   = day.in_time_zone.change(hour: slot.end_hour, min: slot.end_minute)

    find_or_create_by(guider: guider, start_at: start_at, end_at: end_at, schedule_type: guider.schedule_type)
  end

  def self.generation_range
    Time.zone.now.to_date..8.weeks.from_now.to_date
  end
end
