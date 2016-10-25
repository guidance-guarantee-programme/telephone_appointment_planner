if Rails.env.development?
  SEEDERS_PER_SHIFT = 4

  %w{early mid late}.each do |t|
    User
      .where(name: (1..SEEDERS_PER_SHIFT)
      .map {|i| "#{t} shift #{i}"})
      .destroy_all
  end

  1.upto(SEEDERS_PER_SHIFT) do |n|
    guider = FactoryGirl.create(:guider, name: "early shift #{n}")
    schedule = FactoryGirl.build(:schedule, :with_early_shift, start_at: Time.zone.now, user: guider)
    schedule.save!(validate: false)
  end

  1.upto(SEEDERS_PER_SHIFT) do |n|
    guider = FactoryGirl.create(:guider, name: "mid shift #{n}")
    schedule = FactoryGirl.build(:schedule, :with_mid_shift, start_at: Time.zone.now, user: guider)
    schedule.save!(validate: false)
  end

  1.upto(SEEDERS_PER_SHIFT) do |n|
    guider = FactoryGirl.create(:guider, name: "late shift #{n}")
    schedule = FactoryGirl.build(:schedule, :with_late_shift, start_at: Time.zone.now, user: guider)
    schedule.save!(validate: false)
  end

  User.guiders.each do |guider|
    date = Faker::Date.between(Date.today, 1.month.from_now)
    Holiday.create!(
      user: guider,
      title: Faker::Book.title,
      end_at: date.end_of_day,
      start_at: date.beginning_of_day
    )
  end

  GenerateBankHolidaysJob.new.perform_now

  BookableSlot.generate_for_six_weeks

  User.first.tap do |user|
    user.permissions << User::RESOURCE_MANAGER_PERMISSION
    user.permissions << User::AGENT_PERMISSION
    user.save!
  end
end
