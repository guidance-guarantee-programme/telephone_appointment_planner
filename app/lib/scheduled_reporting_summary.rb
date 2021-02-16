class ScheduledReportingSummary
  def call
    Provider.all.each do |organisation|
      ReportingSummary.create!(
        organisation: organisation.name,
        two_week_availability: two_week_available?(organisation.id),
        four_week_availability: four_week_available?(organisation.id),
        first_available_slot_on: first_available_slot_on(organisation.id)
      )
    end
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

  private

  def two_week_period
    BusinessDays.from_now(10)
  end

  def four_week_period
    BusinessDays.from_now(20)
  end

  def windowed_bookable_slots(organisation_id)
    BookableSlot.grouped(organisation_id).map(&:first)
  end
end
