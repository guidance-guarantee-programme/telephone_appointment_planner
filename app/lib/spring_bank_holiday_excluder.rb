class SpringBankHolidayExcluder
  def call
    ActiveRecord::Base.transaction do
      bank_holiday_observing_organisation_ids.each do |organisation_id|
        create_all_day_bank_holidays_for_organisation(organisation_id)
      end

      delete_existing_bank_holidays
    end
  end

  private

  def create_all_day_bank_holidays_for_organisation(organisation_id)
    active_guider_ids_for_organisation(organisation_id).each do |guider_id|
      Holiday.create!(
        user_id: guider_id,
        all_day: true,
        bank_holiday: false,
        title: 'ALL - Easter Bank Holiday',
        start_at: '2019-04-19 00:00:00',
        end_at: '2019-04-22 23:59:59'
      )
    end
  end

  def active_guider_ids_for_organisation(organisation_id)
    User.guiders.active.where(organisation_content_id: organisation_id).pluck(:id)
  end

  def bank_holiday_observing_organisation_ids
    # TPAS are missing as they manage holidays manually
    [
      User::TP_ORGANISATION_ID,
      User::NI_ORGANISATION_ID
    ]
  end

  def delete_existing_bank_holidays
    Holiday.where(
      user_id: nil,
      bank_holiday: true,
      start_at: ['2019-04-19 00:00:00', '2019-04-22 00:00:00']
    ).delete_all
  end
end
