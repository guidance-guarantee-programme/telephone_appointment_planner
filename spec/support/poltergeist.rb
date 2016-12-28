require 'capybara/poltergeist'

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, url_blacklist: %w(/timeline/v2))
end

Capybara.javascript_driver = :poltergeist
Capybara.default_max_wait_time = 10 if ENV['TRAVIS']
