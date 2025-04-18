class SmsCancellation
  include ActiveModel::Model

  attr_accessor :source_number, :message, :schedule_type

  validates :source_number, presence: true
  validates :message, presence: true, format: { with: /\A'?cancel'?/i }
  validates :schedule_type, presence: true

  def call
    if valid? && appointment
      appointment.cancel!
      send_notifications
    else
      SmsCancellationFailureJob.perform_later(source_number, schedule_type)
    end

    log_message if appointment
  end

  private

  def log_message
    SmsMessageActivity.create!(
      message:,
      owner: appointment.guider,
      appointment:
    )
  end

  def send_notifications
    PusherAppointmentChangedJob.perform_later(
      appointment.guider_id,
      appointment
    )

    SmsCancellationSuccessJob.perform_later(appointment)
    AppointmentCancelledNotificationsJob.perform_later(appointment)
  end

  def appointment
    @appointment ||= Appointment.for_sms_cancellation(source_number, schedule_type:)
  end
end
