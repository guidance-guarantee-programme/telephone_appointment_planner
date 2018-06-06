class ScheduledReportingSummary
  ORGANISATIONS = {
    User::TPAS_ORGANISATION_ID => 'TPAS',
    User::TP_ORGANISATION_ID   => 'TP',
    User::CAS_ORGANISATION_ID  => 'CAS'
  }.freeze

  def call
    ORGANISATIONS.each do |id, name|
      ReportingSummary.create!(
        organisation: name,
        four_week_availability: four_week_available?(id),
        first_available_slot_on: first_available_slot_on(id)
      )
    end
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

  def four_week_period
    BusinessDays.from_now(20)
  end

  def windowed_bookable_slots(organisation_id)
    BookableSlot.grouped(organisation_id).map(&:first)
  end
end
