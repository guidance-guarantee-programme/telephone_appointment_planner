class SmsCancellation
  include ActiveModel::Model

  attr_accessor :source_number
  attr_accessor :message

  validates :source_number, presence: true
  validates :message, presence: true, format: { with: /\Acancel/i }

  def call
    return unless valid? && appointment

    appointment.cancel!

    send_notifications
  end

  private

  def send_notifications
    PusherAppointmentChangedJob.perform_later(
      appointment.guider_id,
      appointment
    )

    SmsCancellationSuccessJob.perform_later(appointment)
  end

  def appointment
    @appointment ||= Appointment.for_sms_cancellation(normalised_source_number)
  end

  def normalised_source_number
    source_number.sub(/\A44/, '0').delete(' ')
  end
end
