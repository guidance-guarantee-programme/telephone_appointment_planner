# rubocop:disable Metrics/MethodLength
class Redactor
  def initialize(references)
    @references = Array(references)
  end

  def call
    return unless appointments = Appointment.where(id: @references) # rubocop:disable Lint/AssignmentInCondition

    ActiveRecord::Base.transaction do
      Appointment.without_auditing do
        redact_appointments(appointments)

        appointments.each do |appointment|
          redact_audits(appointment)
          redact_activities(appointment)
          redact_attachments(appointment)
        end
      end
    end
  end

  def self.redact_for_gdpr
    references = Appointment.for_redaction.pluck(:id)

    new(references).call
  end

  private

  def redact_attachments(appointment)
    appointment.power_of_attorney_evidence.purge
    appointment.data_subject_consent_evidence.purge
    appointment.generated_consent_form.purge
  end

  def redact_appointments(appointments) # rubocop:disable Metrics/MethodLength
    # rubocop:disable Rails/SkipsModelValidations
    appointments.update_all(
      first_name: 'redacted',
      last_name: 'redacted',
      email: 'redacted@example.com',
      phone: '00000000000',
      mobile: '00000000000',
      date_of_birth: '1950-01-01',
      memorable_word: 'redacted',
      address_line_one: 'redacted',
      address_line_two: 'redacted',
      address_line_three: 'redacted',
      town: 'redacted',
      postcode: 'redacted',
      notes: 'redacted',
      data_subject_name: 'redacted',
      data_subject_age: '0',
      data_subject_date_of_birth: '1950-01-01',
      consent_address_line_one: 'redacted',
      consent_address_line_two: 'redacted',
      consent_address_line_three: 'redacted',
      consent_town: 'redacted',
      consent_postcode: 'redacted',
      email_consent: 'redacted@example.com',
      updated_at: Time.zone.now,
      adjustments: 'redacted'
    )
    # rubocop:enable Rails/SkipsModelValidations
  end

  def redact_audits(appointment)
    appointment.audits.destroy_all
  end

  def redact_activities(appointment)
    appointment.activities.where(
      type: %w[
        AuditActivity
        ReminderActivity
        SmsReminderActivity
        SmsCancellationActivity
        DropActivity
        DroppedSummaryDocumentActivity
        SmsMessageActivity
      ]
    ).destroy_all
  end

  attr_reader :reference
end
# rubocop:enable Metrics/MethodLength
