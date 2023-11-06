class AppointmentCsvPresenter
  def initialize(appointment)
    @appointment = appointment
  end

  def to_h # rubocop:disable Metrics/AbcSize
    {
      'Date'               => Time.zone.today.to_s(:govuk_date),
      'Reference'          => appointment.id,
      'Appointment date'   => date,
      'Appointment time'   => time,
      'First name'         => appointment.first_name,
      'Last name'          => appointment.last_name,
      'Address line one'   => appointment.address_line_one,
      'Address line two'   => appointment.address_line_two,
      'Address line three' => appointment.address_line_three,
      'Town'               => appointment.town,
      'County'             => appointment.county,
      'Postcode'           => appointment.postcode,
      'Letter type'        => letter_type,
      'Phone'              => appointment.phone,
      'Memorable word'     => appointment.memorable_word(obscure: true)
    }
  end

  def self.wrap(appointments)
    Array(appointments).map { |appointment| new(appointment) }
  end

  private

  def date
    appointment.start_at.to_date.to_s(:govuk_date)
  end

  def time
    "#{appointment.start_at.to_time.to_s(:govuk_time)} #{appointment.timezone}"
  end

  def letter_type
    appointment.rescheduled_at ? 'Rescheduled' : 'Booking'
  end

  attr_reader :appointment
end
