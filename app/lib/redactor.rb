class Redactor
  def initialize(reference)
    @reference = reference
  end

  def call
    return unless appointment = Appointment.find(reference) # rubocop:disable AssignmentInCondition

    ActiveRecord::Base.transaction do
      Appointment.without_auditing do
        redact_appointment(appointment)
        redact_audits(appointment)
        redact_activities(appointment)
        redact_attachments(appointment)
      end
    end
  end

  def self.redact_for_gdpr
    Appointment.for_redaction.pluck(:id).each do |reference|
      new(reference).call
    end
  end

  private

  def redact_attachments(appointment)
    appointment.power_of_attorney_evidence.purge
    appointment.data_subject_consent_evidence.purge
    appointment.generated_consent_form.purge
  end

  def redact_appointment(appointment) # rubocop:disable MethodLength
    appointment.update(
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
      email_consent: 'redacted@example.com'
    )
  end

  def redact_audits(appointment)
    appointment.audits.destroy_all
  end

  def redact_activities(appointment)
    appointment.activities.where(
      type: %w(
        AuditActivity
        ReminderActivity
        SmsReminderActivity
        SmsCancellationActivity
        DropActivity
        DroppedSummaryDocumentActivity
      )
    ).destroy_all
  end

  attr_reader :reference
end
