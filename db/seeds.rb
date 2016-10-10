if Rails.env.development?
  User.first_or_initialize(name: 'Test User').tap do |user|
    user.permissions << User::RESOURCE_MANAGER_PERMISSION
    user.permissions << User::AGENT_PERMISSION
    user.save!
  end
end

%w{early mid late}.each do |t|
  User
    .where(name: (1..15)
    .map {|i| "#{t} shift #{i}"})
    .destroy_all
end

1.upto(15) do |n|
  guider = FactoryGirl.create(:guider, name: "early shift #{n}")
  schedule = FactoryGirl.build(:schedule, :with_early_shift, start_at: Time.zone.now, user: guider)
  schedule.save!(validate: false)
end

1.upto(15) do |n|
  guider = FactoryGirl.create(:guider, name: "mid shift #{n}")
  schedule = FactoryGirl.build(:schedule, :with_mid_shift, start_at: Time.zone.now, user: guider)
  schedule.save!(validate: false)
end

1.upto(15) do |n|
  guider = FactoryGirl.create(:guider, name: "late shift #{n}")
  schedule = FactoryGirl.build(:schedule, :with_late_shift, start_at: Time.zone.now, user: guider)
  schedule.save!(validate: false)
end
