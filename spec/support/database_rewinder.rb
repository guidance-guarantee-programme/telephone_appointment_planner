RSpec.configure do |config|
  config.use_transactional_fixtures = false

  config.before(:suite) { DatabaseRewinder.clean_all }

  config.after(:each) { DatabaseRewinder.clean }
end
