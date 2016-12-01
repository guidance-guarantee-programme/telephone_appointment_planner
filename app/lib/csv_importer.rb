require 'csv'

class CsvImporter
  def initialize(csv_data)
    @csv_data = csv_data
  end

  def call
    csv_without_headers.each do |row|
      appointment = AppointmentRow.new(row)

      AppointmentImporter.new(appointment).call
      putc '.'
    end
  end

  private

  def csv_without_headers
    @csv ||= CSV.new(csv_data).tap(&:shift)
  end

  attr_reader :csv_data
end
