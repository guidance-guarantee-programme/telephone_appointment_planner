class ScheduledReportingSummary
  def call
    ReportingSummary.create!(
      organisation: 'TPAS',
      four_week_availability: four_week_available?,
      first_available_slot_on: first_available_slot_on
    )
  end

  def four_week_available?
    return false unless windowed_bookable_slots.first

    windowed_bookable_slots.first <= four_week_period
  end

  def first_available_slot_on
    windowed_bookable_slots.first
  end

  private

  def four_week_period
    BusinessDays.from_now(20)
  end

  def windowed_bookable_slots
    BookableSlot.grouped.map(&:first)
  end
end
