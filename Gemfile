# rubocop:disable Metrics/BlockLength
ruby IO.read('.ruby-version').strip

source 'https://rails-assets.org' do
  gem 'rails-assets-bootstrap-daterangepicker'
  gem 'rails-assets-fullcalendar'
  gem 'rails-assets-fullcalendar-scheduler'
  gem 'rails-assets-listjs'
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
  gem 'font-awesome-rails'
  gem 'foreman'
  gem 'gds-sso'
  gem 'govuk_admin_template'
  gem 'kaminari'
  gem 'momentjs-rails'
  gem 'newrelic_rpm'
  gem 'pg', '~> 0.18'
  gem 'plek'
  gem 'puma', '~> 3.0'
  gem 'pusher'
  gem 'rails', '~> 5.0.1'
  gem 'rails-observers', github: 'rails/rails-observers'
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
    gem 'pry-byebug'
    gem 'pusher-fake'
    gem 'rspec-rails'
    gem 'rspec-retry'
    gem 'rubocop'
    gem 'site_prism'
  end

  group :test do
    gem 'chronic'
    gem 'coveralls', require: false
    gem 'database_rewinder'
    gem 'poltergeist', '1.11.0'
    gem 'scss_lint', require: false
  end

  group :development do
    gem 'listen', '~> 3.0.5'
  end

  group :staging, :production do
    gem 'lograge'
    gem 'rails_12factor'
  end
end
