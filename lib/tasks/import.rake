require 'open-uri'

namespace :import do
  desc 'Import bookings from booking bug CSV (CSV=url TIMEOUT=60)'
  task booking_bug: :environment do
    csv_url = ENV.fetch('CSV')
    timeout = ENV.fetch('TIMEOUT') { 60 }.to_i

    data = open(csv_url, read_timeout: timeout).read
    CsvImporter.new(data).call
  end
end
