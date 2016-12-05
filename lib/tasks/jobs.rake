namespace :jobs do
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
