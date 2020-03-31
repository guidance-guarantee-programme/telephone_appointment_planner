namespace :jobs do
  namespace :wipe do
    desc 'wipes schedules, slots, bookable slots and holidays across all providers'
    task data: :environment do
      abort 'This task runs in DEVELOPMENT or STAGING only!' unless Rails.env.development? || Rails.env.staging?

      Schedule.destroy_all
      BookableSlot.destroy_all
      Holiday.where(bank_holiday: false).destroy_all

      puts 'Deleted all schedules, slots and non bank holidays'
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
