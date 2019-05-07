namespace :confidentiality do
  desc 'Redact customer details from an appointment reference REFERENCE'
  task redact: :environment do
    appointment = Appointment.find(ENV.fetch('REFERENCE'))

    ActiveRecord::Base.transaction do
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
        notes: 'redacted'
      )

      appointment.audits.delete_all
      appointment.activities.where(
        type: %w(
          AuditActivity
          ReminderActivity
          SmsReminderActivity
          SmsCancellationActivity
          DropActivity
          DroppedSummaryDocumentActivity
        )
      ).delete_all
    end
  end
end
