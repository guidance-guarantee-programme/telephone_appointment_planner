require 'open-uri'
require 'csv'

namespace :import do
  desc 'Import bookings from booking bug CSV (CSV=url TIMEOUT=60)'
  task booking_bug: :environment do
    csv_url = ENV.fetch('CSV')
    timeout = ENV.fetch('TIMEOUT') { 60 }.to_i

    data = open(csv_url, read_timeout: timeout).read
    CsvImporter.new(data).call
  end

  desc 'Fix IDs for incorrectly imported records (CSV=url TIMEOUT=60)'
  task fix_ids: :environment do
    csv_url = ENV.fetch('CSV')
    timeout = ENV.fetch('TIMEOUT') { 60 }.to_i

    data = open(csv_url, read_timeout: timeout).read

    CSV.new(data).each do |row|
      member_id = row[0]
      reference = row[1]

      next unless Appointment.exists?(member_id)

      ActiveRecord::Base.transaction do
        Appointment.find(member_id).update_attribute(:id, reference)
        Activity.where(appointment_id: member_id).update_all(appointment_id: reference)
        Audited::Audit.where(auditable_id: member_id).update_all(auditable_id: reference)
      end

      putc '.'
    end
  end
end
