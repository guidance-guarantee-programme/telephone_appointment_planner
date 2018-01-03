# rubocop:disable Metrics/BlockLength
ruby IO.read('.ruby-version').strip

# force Bundler to use SSL
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

source 'https://rails-assets.org' do
  gem 'rails-assets-bootstrap-daterangepicker'
  gem 'rails-assets-eonasdan-bootstrap-datetimepicker'
  gem 'rails-assets-fullcalendar', '3.2.0'
  gem 'rails-assets-fullcalendar-scheduler', '1.5.1'
  gem 'rails-assets-listjs'
  gem 'rails-assets-mailgun-validator-jquery', '0.0.3'
  gem 'rails-assets-pusher'
  gem 'rails-assets-qTip2'
  gem 'rails-assets-zloirock--core-js'
end

source 'https://rubygems.org' do
  gem 'active_link_to'
  gem 'active_model_serializers'
  gem 'audited'
  gem 'bh'
  gem 'bootstrap-kaminari-views'
  gem 'bugsnag'
  gem 'faraday'
  gem 'faraday-conductivity'
  gem 'faraday_middleware'
  gem 'font-awesome-rails'
  gem 'foreman'
  gem 'gds-sso'
  gem 'govuk_admin_template'
  gem 'kaminari'
  gem 'momentjs-rails', '2.15.1'
  gem 'newrelic_rpm'
  gem 'notifications-ruby-client'
  gem 'oj'
  gem 'pg', '~> 0.18'
  gem 'plek'
  gem 'postgres-copy'
  gem 'puma', '~> 3.0'
  gem 'pusher'
  gem 'rails', '~> 5.1.1'
  gem 'sassc-rails'
  gem 'select2-rails'
  gem 'sidekiq'
  gem 'sinatra', require: false
  gem 'sortable-rails'
  gem 'sprockets-es6'
  gem 'uglifier', '>= 1.3.0'
  gem 'working_hours'

  group :development, :test do
    gem 'capybara'
    gem 'factory_girl_rails', '~> 4.0'
    gem 'faker'
    gem 'launchy'
    gem 'parallel_tests'
    gem 'phantomjs'
    gem 'pry-byebug'
    gem 'pusher-fake'
    gem 'rspec-rails'
    gem 'rspec-retry'
    gem 'rubocop', '0.46.0'
    gem 'site_prism'
    gem 'thin'
  end

  group :test do
    gem 'chronic'
    gem 'coveralls', require: false
    gem 'database_rewinder'
    gem 'poltergeist', '1.11.0'
    gem 'scss_lint', require: false
    gem 'webmock'
    gem 'webrick'
  end

  group :development do
    gem 'listen', '~> 3.0.5'
  end

  group :staging, :production do
    gem 'lograge'
    gem 'rails_12factor'
  end
end
