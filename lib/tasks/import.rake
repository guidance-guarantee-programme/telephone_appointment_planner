require 'open-uri'
require 'csv'

namespace :import do
  desc 'Import bookings from planner CSV (CSV=url TIMEOUT=60)'
  task planner: :environment do
    csv_url = ENV.fetch('CSV')
    timeout = ENV.fetch('TIMEOUT') { 60 }

    data = open(csv_url, read_timeout: timeout).read

    CSV.new(data).each do |row|
      attributes = row_to_appointment_attributes(row)

      Appointment.without_auditing do
        next if Appointment.exists?(attributes)

        Appointment.new(attributes).save(validate: false)
        putc '.'
      end
    end

    puts 'done!'
  end

  def row_to_appointment_attributes(row) # rubocop:disable MethodLength, AbcSize
    {
      first_name: row[0].split.first,
      last_name: row[0].split.last,
      email: row[1].to_s,
      phone: row[2].to_s,
      guider_id: guider_map(row[3]),
      start_at: row[4].to_time,
      end_at: row[4].to_time.advance(minutes: 70),
      status: status_map(row[5].to_i),
      memorable_word: row[7],
      date_of_birth: row[8],
      dc_pot_confirmed: row[9] == 'true',
      accessibility_requirements: row[10] == 'true',
      notes: row[11].to_s,
      processed_at: row[12],
      where_you_heard: row[13],
      gdpr_consent: row[14].to_s,
      address_line_one: row[15].to_s,
      address_line_two: row[16].to_s,
      address_line_three: row[17].to_s,
      town: row[18].to_s,
      county: row[19].to_s,
      postcode: row[20].to_s,
      agent_id: 75 # PW Importer
    }
  end

  def guider_map(guider_id) # rubocop:disable MethodLength
    {
      '137' => '359',
      '261' => '361',
      '135' => '363',
      '338' => '362',
      '136' => '365',
      '298' => '364',
      '337' => '492',
      '27'  => '388',
      '168' => '360'
    }.fetch(guider_id)
  end

  def status_map(status)
    case status
    when 0..2
      status
    when 3..7
      status + 1
    else
      3 # incomplete
    end
  end
end
