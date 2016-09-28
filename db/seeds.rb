if Rails.env.development?
  User.first_or_initialize(name: 'Test User').tap do |user|
    user.permissions << User::RESOURCE_MANAGER_PERMISSION
    user.save!
  end
end
