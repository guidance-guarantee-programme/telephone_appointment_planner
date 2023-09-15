class BankHolidayExcluder
  def call
    ActiveRecord::Base.transaction do
      bank_holiday_observing_organisation_ids.each do |organisation_id|
        create_all_day_bank_holidays_for_organisation(organisation_id)
      end

      delete_existing_bank_holidays
    end
  end

  private

  def permitted_date_pairs
    [
      ['2023-04-07 00:00:00', '2023-04-07 23:59:59'],
      ['2023-04-10 00:00:00', '2023-04-10 23:59:59'],
      ['2023-05-01 00:00:00', '2023-05-01 23:59:59'],
      ['2023-05-08 00:00:00', '2023-05-08 23:59:59'],
      ['2023-05-29 00:00:00', '2023-05-29 23:59:59'],
      ['2023-08-28 00:00:00', '2023-08-28 23:59:59']
    ]
  end

  def create_all_day_bank_holidays_for_organisation(organisation_id)
    active_guider_ids_for_organisation(organisation_id).each do |guider_id|
      permitted_date_pairs.each do |date_pair|
        Holiday.create!(
          user_id: guider_id,
          all_day: true,
          bank_holiday: false,
          title: 'ALL - Bank Holiday',
          start_at: date_pair.first,
          end_at: date_pair.last
        )
      end
    end
  end

  def active_guider_ids_for_organisation(organisation_id)
    User.guiders.active.where(organisation_content_id: organisation_id).pluck(:id)
  end

  def bank_holiday_observing_organisation_ids
    Provider.bank_holiday_observing_organisation_ids
  end

  def delete_existing_bank_holidays
    Holiday.where(
      user_id: nil,
      bank_holiday: true,
      start_at: permitted_date_pairs.map(&:first)
    ).delete_all
  end
end
