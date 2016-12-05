require 'openssl'

TokenVerificationFailure = Class.new(StandardError)

class DropForm
  include ActiveModel::Model

  attr_accessor :event
  attr_accessor :description
  attr_accessor :appointment_id
  attr_accessor :environment
  attr_accessor :timestamp
  attr_accessor :token
  attr_accessor :signature

  validates :timestamp, presence: true
  validates :token, presence: true
  validates :signature, presence: true
  validates :event, presence: true
  validates :appointment_id, presence: true
  validates :environment, inclusion: { in: %w(production) }

  def create_activity
    return unless valid?

    verify_token!

    DropActivity.from(
      event,
      description,
      appointment
    )
  end

  private

  def appointment
    Appointment.find(appointment_id)
  end

  # rubocop:disable Style/GuardClause
  def verify_token!
    digest = OpenSSL::Digest::SHA256.new
    data   = timestamp + token

    unless signature == OpenSSL::HMAC.hexdigest(digest, api_token, data)
      raise TokenVerificationFailure
    end
  end

  def api_token
    ENV['MAILGUN_API_TOKEN']
  end
end
