class SummaryDocumentLink
  class << self
    attr_accessor :url

    def generate(appointment)
      "#{url}/appointment_summaries/new?#{query(appointment)}"
    end

    def query(appointment) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      date_of_appointment = appointment.start_at.to_date
      {
        first_name: appointment.first_name,
        last_name: appointment.last_name,
        date_of_appointment: date_of_appointment.to_s,
        guider_name: appointment.guider.name.split.first,
        reference_number: appointment.id,
        number_of_previous_appointments: 0,
        email: appointment.email,
        appointment_type: appointment.type_of_appointment == '50-54' ? '50_54' : appointment.type_of_appointment,
        address_line_1: appointment.address_line_one,
        address_line_2: appointment.address_line_two,
        address_line_3: appointment.address_line_three,
        town: appointment.town,
        county: appointment.county,
        postcode: appointment.postcode,
        country: 'United Kingdom',
        telephone_appointment: true,
        schedule_type: appointment.schedule_type,
        unique_reference_number: appointment.unique_reference_number,
        welsh: appointment.welsh?
      }.to_query(:appointment_summary)
    end
  end
end
