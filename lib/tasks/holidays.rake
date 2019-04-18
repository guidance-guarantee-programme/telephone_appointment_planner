namespace :holidays do
  desc 'Allow CAS to receive bookings during given holidays'
  task exclude: :environment do
    BankHolidayExcluder.new.call
  end
end
