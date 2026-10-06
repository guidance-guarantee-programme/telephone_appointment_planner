ruby IO.read('.ruby-version').strip

# force Bundler to use SSL
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

source 'https://rubygems.org'

gem 'active_link_to'
gem 'active_model_serializers'
gem 'alertifyjs-rails'
gem 'audited'
gem 'azure-storage-blob', '~> 2.0.3'
gem 'bh'
gem 'bootsnap'
gem 'bootstrap-kaminari-views'
gem 'bugsnag'
gem 'capitalize-names', require: 'capitalize_names'
gem 'concurrent-ruby', '1.3.7'
gem 'country_select'
gem 'csv'
gem 'faraday'
gem 'faraday-conductivity'
gem 'faraday-http'
gem 'faraday_middleware'
gem 'faye-websocket'
gem 'font-awesome-rails'
gem 'foreman'
gem 'gds-sso', '~> 18.0'
gem 'govuk_admin_template'
gem 'kaminari'
gem 'multipart-post'
gem 'net-http', require: false
gem 'net-sftp'
gem 'notifications-ruby-client'
gem 'observer'
gem 'oj'
gem 'ostruct'
gem 'pg'
gem 'plek'
gem 'postgres-copy'
gem 'princely'
gem 'puma'
gem 'pusher'
gem 'rack-cors'
gem 'rails', '~> 8.0'
gem 'sassc-rails'
gem 'select2-rails'
gem 'sidekiq'
gem 'sinatra', require: false
gem 'sortable-rails'
gem 'sprockets-es6'
gem 'uglifier', '>= 1.3.0'
gem 'working_hours'

group :development, :test do
  gem 'benchmark'
  gem 'capybara'
  gem 'factory_bot_rails', '4.11.0'
  gem 'faker'
  gem 'launchy'
  gem 'parallel_tests'
  gem 'pry-byebug'
  gem 'pusher-fake'
  gem 'readline'
  gem 'rspec-rails'
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
  gem 'site_prism'
  gem 'thin'
end

group :test do
  gem 'chronic'
  gem 'database_rewinder'
  gem 'rspec-retry'
  gem 'scss_lint', require: false
  gem 'selenium-webdriver'
  gem 'vcr'
  gem 'webmock'
  gem 'webrick'
end

group :development do
  gem 'listen'
end

group :staging, :production do
  gem 'aws-sdk-s3', require: false
  gem 'lograge'
end
