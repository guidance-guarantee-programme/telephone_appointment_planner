class ScheduledReportingSummary
  def initialize(schedule_type)
    @schedule_type = schedule_type
  end

  def call # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    organisations.each do |organisation|
      ReportingSummary.create!(
        organisation: organisation.name,
        schedule_type:,
        two_week_availability: two_week_available?(organisation.id),
        four_week_availability: four_week_available?(organisation.id),
        first_available_slot_on: first_available_slot_on(organisation.id),
        last_available_slot_on: last_available_slot_on(organisation.id),
        last_slot_on: last_slot_on(organisation.id),
        total_slots_available: total_slots_available(organisation.id),
        total_slots_created: total_slots_created(organisation.id)
      )
    end
  end

  def total_slots_available(organisation_id)
    start_date, end_date = *BookableSlot.date_range(schedule_type, nil)

    fake_user = OpenStruct.new(organisation_content_id: organisation_id)

    BookableSlot
      .for_schedule_type(schedule_type:)
      .for_organisation(fake_user)
      .within_date_range(start_date, end_date)
      .bookable(start_date, end_date)
      .size
  end

  def total_slots_created(organisation_id)
    start_date, end_date = *BookableSlot.date_range(schedule_type, nil)

    fake_user = OpenStruct.new(organisation_content_id: organisation_id)

    BookableSlot
      .for_schedule_type(schedule_type:)
      .for_organisation(fake_user)
      .within_date_range(start_date, end_date)
      .size
  end

  def two_week_available?(organisation_id)
    slot = first_available_slot_on(organisation_id)

    return false unless slot

    slot <= two_week_period
  end

  def four_week_available?(organisation_id)
    slot = first_available_slot_on(organisation_id)

    return false unless slot

    slot <= four_week_period
  end

  def first_available_slot_on(organisation_id)
    windowed_bookable_slots(organisation_id).first
  end

  def last_available_slot_on(organisation_id)
    windowed_bookable_slots(organisation_id).last
  end

  def last_slot_on(organisation_id)
    slot = BookableSlot
           .includes(:guider)
           .where(users: { organisation_content_id: organisation_id })
           .for_schedule_type(schedule_type:)
           .order(start_at: :desc)
           .limit(1)
           .first

    return nil unless slot

    slot.start_at.to_date
  end

  private

  attr_reader :schedule_type

  def organisations
    return Array(Provider::TPAS) if schedule_type == User::DUE_DILIGENCE_SCHEDULE_TYPE

    Provider.all
  end

  def two_week_period
    BusinessDays.from_now(10)
  end

  def four_week_period
    BusinessDays.from_now(20)
  end

  def windowed_bookable_slots(organisation_id)
    BookableSlot
      .grouped(organisation_id, schedule_type)
      .map(&:first)
  end
end
