class SummaryDocumentLink
  class << self
    attr_accessor :url

    def generate(appointment)
      "#{url}/appointment_summaries/new?#{query(appointment)}"
    end

    def query(appointment) # rubocop:disable Metrics/MethodLength
      date_of_appointment = appointment.start_at.to_date
      {
        first_name: appointment.first_name,
        last_name: appointment.last_name,
        date_of_appointment: date_of_appointment.to_s,
        guider_name: appointment.guider.name,
        reference_number: appointment.id,
        number_of_previous_appointments: 0,
        email: appointment.email,
        appointment_type: (date_of_appointment - 55.years) > appointment.date_of_birth ? 'standard' : '50-54'
      }.to_query(:appointment_summary)
    end
  end
end
