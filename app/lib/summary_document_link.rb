class SummaryDocumentLink
  class << self
    attr_accessor :url

    def generate(appointment)
      "#{url}/appointment_summaries/new?#{query(appointment)}"
    end

    def query(appointment) # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      date_of_appointment = appointment.start_at.to_date
      {
        first_name: appointment.first_name,
        last_name: appointment.last_name,
        date_of_appointment: date_of_appointment.to_s,
        guider_name: appointment.guider.name.split.first,
        reference_number: appointment.id,
        number_of_previous_appointments: 0,
        email: appointment.email,
        appointment_type: appointment.type_of_appointment == '50-54' ? '50_54' : appointment.type_of_appointment
      }.to_query(:appointment_summary)
    end
  end
end
