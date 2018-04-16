require 'csv'

class BatchPrintCsv
  def call(appointments)
    appointments = AppointmentCsvPresenter.wrap(appointments)

    CSV.generate(headers: appointments.first.to_h.keys, write_headers: true) do |output|
      appointments.map(&:to_h).each do |appointment|
        output << appointment.values
      end
    end
  end
end
