require 'openssl'

TokenVerificationFailure = Class.new(StandardError)

class DropForm
  include ActiveModel::Model

  IGNORED_MESSAGE_TYPES = %w[
    adjustment
    accessibility_adjustment
    resource_manager_email_dropped
    resource_manager_appointment_created
    resource_manager_appointment_changed
    resource_manager_appointment_cancelled
    resource_manager_appointment_rescheduled
  ].freeze

  attr_accessor :event
  attr_accessor :description
  attr_accessor :appointment_id
  attr_accessor :environment
  attr_accessor :message_type
  attr_accessor :timestamp
  attr_accessor :token
  attr_accessor :signature

  validates :timestamp, presence: true
  validates :token, presence: true
  validates :signature, presence: true
  validates :event, presence: true
  validates :appointment_id, presence: true
  validates :message_type, presence: true, exclusion: { in: IGNORED_MESSAGE_TYPES }
  validates :environment, inclusion: { in: %w[production] }

  def create_activity
    if valid?
      verify_token!

      DropActivity.from(
        event,
        description,
        message_type,
        appointment
      )

      EmailDropNotificationsJob.perform_later(appointment)

    else
      logger.info(errors.full_messages)
    end
  end

  private

  def appointment
    Appointment.find(appointment_id)
  end

  def verify_token!
    digest = OpenSSL::Digest::SHA256.new
    data = timestamp + token

    raise TokenVerificationFailure unless signature == OpenSSL::HMAC.hexdigest(digest, api_token, data)
  end

  def api_token
    ENV['MAILGUN_API_TOKEN']
  end
end
