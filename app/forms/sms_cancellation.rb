class SmsCancellation
  include ActiveModel::Model

  attr_accessor :source_number
  attr_accessor :message
  attr_accessor :schedule_type

  validates :source_number, presence: true
  validates :message, presence: true, format: { with: /\A'?cancel'?/i }
  validates :schedule_type, presence: true

  def call
    if valid? && appointment
      appointment.cancel!
      send_notifications
    else
      SmsCancellationFailureJob.perform_later(source_number)
    end
  end

  private

  def send_notifications
    PusherAppointmentChangedJob.perform_later(
      appointment.guider_id,
      appointment
    )

    SmsCancellationSuccessJob.perform_later(appointment)
    AppointmentCancelledNotificationsJob.perform_later(appointment)
  end

  def appointment
    @appointment ||= Appointment.for_sms_cancellation(normalised_source_number, schedule_type: schedule_type)
  end

  def normalised_source_number
    source_number.sub(/\A44/, '0').delete(' ')
  end
end
