namespace :holidays do
  desc 'Allow CAS to receive bookings during given holidays'
  task exclude: :environment do
    BankHolidayExcluder.new.call
  end

  task block_cas_guiders_saturdays: :environment do
    all_saturdays = (Date.parse('2025-01-01 00:00')..Date.parse('2025-12-31 23:59')).select(&:saturday?)
    cas_guiders   = User.where(organisation_content_id: Provider::CAS.id).guiders

    all_saturdays.each do |saturday|
      cas_guiders.each do |guider|
        Holiday.find_or_create_by!(
          user_id: guider.id,
          all_day: true,
          bank_holiday: false,
          title: 'ALL - Saturday Exclusion',
          start_at: saturday.beginning_of_day,
          end_at: saturday.end_of_day
        )
      end
    end
  end
end
