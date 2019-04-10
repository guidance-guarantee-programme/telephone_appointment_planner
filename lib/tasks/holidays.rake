namespace :holidays do
  desc 'Allow CAS to receive bookings during Easter holidays'
  task exclude_spring: :environment do
    SpringBankHolidayExcluder.new.call
  end
end
