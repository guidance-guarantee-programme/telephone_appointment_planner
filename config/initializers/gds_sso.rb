GDS::SSO.config do |config|
  config.user_model   = 'User'

  config.oauth_id     = ENV['OAUTH_ID']
  config.oauth_secret = ENV['OAUTH_SECRET']
  config.oauth_root_url = ENV.fetch('OAUTH_ROOT_URL', 'http://localhost:3001')

  config.cache = Rails.cache
end

if Rails.env.development?
  GDS::SSO.test_user = User.find_or_create_by(name: 'Test User') do |user|
    user.permissions << User::RESOURCE_MANAGER_PERMISSION
  end
end
