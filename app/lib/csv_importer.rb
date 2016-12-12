require 'csv'

class CsvImporter
  def initialize(csv_data, output = STDOUT)
    @csv_data = csv_data
    @output   = output
  end

  def call
    csv_without_headers.each do |row|
      appointment = AppointmentRow.new(row)
      AppointmentImporter.new(appointment).call
      output.putc '.'
    end
  end

  private

  def csv_without_headers
    @csv ||= CSV.new(csv_data).tap(&:shift)
  end

  attr_reader :csv_data
  attr_reader :output
end
