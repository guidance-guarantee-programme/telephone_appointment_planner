USER_COUNT = 45
HOLIDAY_COUNT = 100
APPOINTMENT_COUNT = 1000

if Rails.env.development?
  Rails.application.eager_load!
  ApplicationRecord.descendants.each do |d|
    puts "Deleting #{d}..."
    d.delete_all
  end

  print "Seeding #{USER_COUNT} users"
  schedules = [:with_early_shift, :with_mid_shift, :with_late_shift].cycle
  USER_COUNT.times do |n|
    guider = FactoryGirl.create(:guider)
    schedule = FactoryGirl.build(:schedule, schedules.next, start_at: Time.zone.now, user: guider)
    schedule.save!
    print '.'
  end
  puts

  puts "Assigning all permissions to #{User.first.name}..."
  User.first.tap do |user|
    user.permissions << User::RESOURCE_MANAGER_PERMISSION
    user.permissions << User::AGENT_PERMISSION
    user.permissions << User::GUIDER_PERMISSION
    user.save!
  end

  print "Adding #{HOLIDAY_COUNT} holidays to guiders"
  holiday_guiders = User.guiders.cycle
  HOLIDAY_COUNT.times do
    date = Faker::Date.between(Time.zone.today, 1.month.from_now)
    FactoryGirl.create(
      :holiday,
      user: holiday_guiders.next,
      end_at: date.end_of_day,
      start_at: date.beginning_of_day
    )
    print '.'
  end
  puts

  puts 'Generating bank holidays...'
  GenerateBankHolidaysJob.new.perform_now

  puts 'Generating bookable slots...'
  BookableSlot.generate_for_six_weeks

  print "Adding #{APPOINTMENT_COUNT} appointments"
  slots = BookableSlot
          .within_date_range(BusinessDays.from_now(3), BusinessDays.from_now(20))
          .sample(APPOINTMENT_COUNT)
          .cycle(1)
  slots.each do |slot|
    appointment = FactoryGirl.build(:appointment, guider: User.first)
    appointment.start_at = slot.start_at
    appointment.end_at = slot.end_at
    appointment.assign_to_guider
    appointment.save!
    print '.'
  end
  puts
end
