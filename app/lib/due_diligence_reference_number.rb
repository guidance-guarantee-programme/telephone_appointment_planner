class DueDiligenceReferenceNumber
  MAX_PADDED_DIGITS       = 6
  MAX_SIX_DIGIT_REFERENCE = 999_999

  def initialize(appointment)
    @appointment = appointment
  end

  def call
    reference_digits = SecureRandom.random_number(MAX_SIX_DIGIT_REFERENCE).to_s.rjust(MAX_PADDED_DIGITS, '0')
    reference_date   = appointment.start_at.strftime('%d%m%Y')

    "#{reference_digits}#{reference_date}"
  end

  private

  attr_reader :appointment
end
