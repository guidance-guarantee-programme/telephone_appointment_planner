# rubocop:disable Metrics/BlockLength
ruby IO.read('.ruby-version').strip

# force Bundler to use SSL
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

source 'https://rails-assets.org' do
  gem 'rails-assets-bootstrap-daterangepicker', '2.1.27'
  gem 'rails-assets-eonasdan-bootstrap-datetimepicker'
  gem 'rails-assets-fullcalendar', '3.2.0'
  gem 'rails-assets-fullcalendar-scheduler', '1.5.1'
  gem 'rails-assets-jquery.postcodes'
  gem 'rails-assets-listjs'
  gem 'rails-assets-moment', '2.15.1'
  gem 'rails-assets-pusher'
  gem 'rails-assets-qTip2'
  gem 'rails-assets-zloirock--core-js', '2.5.1'
end

source 'https://rubygems.org' do
  gem 'active_link_to'
  gem 'active_model_serializers'
  gem 'audited'
  gem 'azure-storage-blob'
  gem 'bh'
  gem 'bootsnap'
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
  gem 'net-sftp'
  gem 'notifications-ruby-client'
  gem 'oj'
  gem 'pg'
  gem 'plek'
  gem 'postgres-copy'
  gem 'princely'
  gem 'puma'
  gem 'pusher'
  gem 'rack-cors'
  gem 'rails', '~> 6.0.2'
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
    gem 'factory_bot_rails', '4.11.0'
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
    gem 'aws-sdk-s3', require: false
    gem 'lograge'
  end
end
