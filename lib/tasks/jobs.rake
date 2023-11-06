# rubocop:disable Metrics/BlockLength
namespace :jobs do
  namespace :wipe do
    desc 'wipes data across all providers'
    task data: :environment do
      abort 'This task runs in DEVELOPMENT or STAGING only!' unless Rails.env.development? || Rails.env.staging?

      [Schedule, Slot, BookableSlot, Appointment, Activity].map(&:delete_all)

      Holiday.where(bank_holiday: false).delete_all

      puts 'Deleted all staging or test data'
    end
  end

  namespace :bookable_slots do
    desc 'generate bookable slots for the next six weeks'
    task generate: :environment do
      GenerateBookableSlotsJob.perform_now
    end
  end

  namespace :bank_holidays do
    desc 'generate bank holidays'
    task generate: :environment do
      GenerateBankHolidaysJob.perform_now
    end
  end

  namespace :reminder_emails do
    desc 'send reminder emails'
    task send: :environment do
      AppointmentRemindersJob.perform_now
    end
  end
end
# rubocop:enable Metrics/BlockLength
