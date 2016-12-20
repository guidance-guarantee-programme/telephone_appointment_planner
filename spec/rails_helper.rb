# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
# Prevent database truncation if the environment is production
abort('The Rails environment is running in production mode!') if Rails.env.production?
require 'spec_helper'
require 'rspec/rails'
require 'capybara/rails'
require 'capybara/rspec'
require 'database_rewinder'
require 'pusher-fake/support/rspec'

require_relative 'support/pages/base'
require_relative 'support/sections/calendar'
require_relative 'support/sections/multiple_day'
require_relative 'support/sections/single_day'

if ENV['TRAVIS']
  require 'coveralls'
  Coveralls.wear!
end

ActiveRecord::Migration.maintain_test_schema!

Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.use_transactional_fixtures = false
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  config.include UserHelpers
  config.include DialogHelpers
  config.include ActiveSupport::Testing::TimeHelpers
  config.include ActionView::Helpers::DateHelper

  config.before(:each) { ActionMailer::Base.deliveries.clear }
end
