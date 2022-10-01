class PrintedConfirmationPresenter
  def initialize(appointment)
    @appointment = appointment
  end

  def to_h # rubocop:disable AbcSize, MethodLength
    {
      reference: appointment.to_param,
      date: date,
      time: time,
      phone: appointment.phone,
      memorable_word: appointment.memorable_word(obscure: true),
      address_line_1: fullname,
      address_line_2: appointment.address_line_one,
      address_line_3: appointment.address_line_two,
      address_line_4: appointment.address_line_three,
      address_line_5: appointment.town,
      address_line_6: appointment.county,
      address_line_7: appointment.postcode
    }
  end

  private

  def fullname
    "#{appointment.first_name} #{appointment.last_name}"
  end

  def date
    appointment.start_at.to_date.to_s(:govuk_date)
  end

  def time
    "#{appointment.start_at.to_time.to_s(:govuk_time)} #{appointment.timezone}" # rubocop:disable Rails/Date
  end

  attr_reader :appointment
end
