namespace :jobs do
  namespace :bookable_slots do
    desc 'generate bookable slots for the next six weeks'
    task generate: :environment do
      GenerateBookableSlotsJob.perform_now
    end
  end
end
