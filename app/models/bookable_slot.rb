# rubocop:disable Metrics/ClassLength
class BookableSlot < ApplicationRecord
  acts_as_copy_target

  belongs_to :guider, class_name: 'User'

  scope :for_guider, ->(guider) { where(guider:) }

  def self.generate_for_booking_window
    User.guiders.each do |guider|
      generate_for_guider(guider)
    end
  end

  def self.within_date_range(from, to, organisation_limit: false)
    return limit_by_organisation(from, to) if organisation_limit

    where("#{quoted_table_name}.start_at > ? AND #{quoted_table_name}.end_at < ?", from, to)
  end

  def self.limit_by_organisation(from, to) # rubocop:disable Metrics/MethodLength
    tpas_start_at = BusinessDays.from_now(5).change(hour: 21, min: 0).in_time_zone('London')
    tpas_start_at = from if from > tpas_start_at

    joins(:guider)
      .where(
        '
         (users.organisation_content_id = :tpas_id
           AND bookable_slots.start_at > :tpas_start_at AND bookable_slots.end_at < :end_at)
         OR
         (users.organisation_content_id != :tpas_id
           AND bookable_slots.start_at > :start_at AND bookable_slots.end_at < :end_at)
        ',
        tpas_id: Provider::TPAS.id,
        tpas_start_at:,
        start_at: from,
        end_at: to
      )
  end

  def self.next_valid_start_date(user = nil, schedule_type = User::PENSION_WISE_SCHEDULE_TYPE)
    return Time.zone.now if user&.resource_manager?

    if schedule_type == User::DUE_DILIGENCE_SCHEDULE_TYPE || user&.tpas_guider?
      BusinessDays.from_now(5).change(hour: 21, min: 0).in_time_zone('London')
    else
      BusinessDays.from_now(1).change(hour: 21, min: 0).in_time_zone('London')
    end
  end

  def self.find_available_slot(start_at, agent, schedule_type = User::PENSION_WISE_SCHEDULE_TYPE, scoped: true, external: false) # rubocop:disable Layout/LineLength
    scope = bookable
    scope = scope.limit_by_organisation(start_at.beginning_of_day, start_at.end_of_day) if agent&.pension_wise_api?
    scope = scope.where(start_at:)
    scope = scope.for_organisation(agent, scoped:, external:) if agent && !agent.pension_wise_api?
    scope = for_schedule_type(schedule_type:, scope:)

    scope.limit(1).order('RANDOM()').first
  end

  def self.bookable(from = nil, to = nil)
    without_appointments(from, to)
      .without_holidays
  end

  def self.grouped(organisation_id = nil, schedule_type = User::PENSION_WISE_SCHEDULE_TYPE, day = nil) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
    from, to = date_range(schedule_type, day)
    limit_by_organisation = schedule_type == User::PENSION_WISE_SCHEDULE_TYPE

    scope = bookable(from, to).within_date_range(from, to, organisation_limit: limit_by_organisation)
    scope = scope.joins(:guider).where(users: { organisation_content_id: organisation_id }) if organisation_id
    scope = for_schedule_type(schedule_type:, scope:)

    scope
      .select("#{quoted_table_name}.start_at::date as start_date")
      .select("#{quoted_table_name}.start_at")
      .order('start_date asc, start_at asc')
      .group_by(&:start_date)
      .transform_values { |value| value.map(&:start_at).uniq }
  end

  def self.date_range(schedule_type, day)
    if day
      [Time.zone.parse(day).beginning_of_day, Time.zone.parse(day).end_of_day]
    else
      [next_valid_start_date(nil, schedule_type), BusinessDays.from_now(40).end_of_day]
    end
  end

  def self.for_schedule_type(schedule_type: User::PENSION_WISE_SCHEDULE_TYPE, scope: self)
    scope.where(schedule_type:)
  end

  def self.without_appointments(from = nil, to = nil) # rubocop:disable Metrics/MethodLength
    joins(<<-SQL
            LEFT JOIN appointments ON
              appointments.guider_id = #{quoted_table_name}.guider_id
              #{reduce_by_range(:appointments, from, to)}
              AND NOT appointments.status IN (
                #{Appointment.statuses['cancelled_by_customer']},
                #{Appointment.statuses['cancelled_by_pension_wise']},
                #{Appointment.statuses['cancelled_by_customer_sms']},
                #{Appointment.statuses['cancelled_by_customer_online']}
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

  def self.starting_after_next_valid_start_date(user, schedule_type: User::PENSION_WISE_SCHEDULE_TYPE) # rubocop:disable Metrics/MethodLength
    starting_from = next_valid_start_date(user, schedule_type)
    normal_scope = where("#{quoted_table_name}.start_at > ?", starting_from)

    return normal_scope if schedule_type == User::DUE_DILIGENCE_SCHEDULE_TYPE

    if user.tpas_agent?
      from = BusinessDays.from_now(1).change(hour: 21, min: 0).in_time_zone('London')

      joins(:guider)
        .where(
          '
           (users.organisation_content_id = :tpas_id AND bookable_slots.start_at > :tpas_start_at)
           OR
           (users.organisation_content_id != :tpas_id AND bookable_slots.start_at > :start_at)
          ',
          tpas_id: Provider::TPAS.id,
          tpas_start_at: starting_from,
          start_at: from
        )
    else
      normal_scope
    end
  end

  def self.with_guider_count(user, from, to, lloyds: false, schedule_type: User::PENSION_WISE_SCHEDULE_TYPE, scoped: true, internal: false, external: false) # rubocop:disable Metrics/AbcSize, Layout/LineLength, Metrics/ParameterLists, Metrics/MethodLength
    users = Array(user)
    agent = users.one? ? user : users.first
    user  = users.last

    limit_by_organisation = !user.resource_manager? && !user.tpas_agent?

    select("DISTINCT #{quoted_table_name}.start_at, #{quoted_table_name}.end_at, count(1) AS guiders")
      .bookable
      .starting_after_next_valid_start_date(agent, schedule_type:)
      .for_schedule_type(schedule_type:)
      .for_organisation(user, lloyds:, scoped:, internal:, external:)
      .group("#{quoted_table_name}.start_at, #{quoted_table_name}.end_at")
      .within_date_range(from, to, organisation_limit: limit_by_organisation)
      .map do |us|
        { guiders: us.attributes['guiders'], start: us.start_at, end: us.end_at, selected: false }
      end
  end

  def self.for_organisation(user, scoped: true, lloyds: false, internal: false, external: false) # rubocop:disable Metrics/CyclomaticComplexity, Metrics/MethodLength, Metrics/PerceivedComplexity
    scope = joins(:guider)

    if lloyds
      scope.where(users: { organisation_content_id: Provider.lloyds_providers.map(&:id) })
    elsif internal
      scope.where(users: { organisation_content_id: user.organisation_content_id })
    elsif external
      scope.where.not(users: { organisation_content_id: user.organisation_content_id })
    else
      return where('1 = 1') if scoped && (user.tp_agent? || user.tpas_agent?)

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

    find_or_create_by(guider:, start_at:, end_at:, schedule_type: guider.schedule_type)
  end

  def self.generation_range
    Time.zone.now.to_date..BusinessDays.from_now(40).to_date
  end
end
# rubocop:enable Metrics/ClassLength
