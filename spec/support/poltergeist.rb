require 'capybara/poltergeist'

Capybara.javascript_driver = :poltergeist
Capybara.default_max_wait_time = 10 if ENV['TRAVIS']
