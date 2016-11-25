ruby IO.read('.ruby-version').strip

source 'https://rails-assets.org' do
  gem 'rails-assets-listjs'
  gem 'rails-assets-zloirock--core-js'
  gem 'rails-assets-fullcalendar'
  gem 'rails-assets-fullcalendar-scheduler'
  gem 'rails-assets-qTip2'
  gem 'rails-assets-bootstrap-daterangepicker'
  gem 'rails-assets-pusher'
end

source 'https://rubygems.org' do
  gem 'rails', '~> 5.0.0', '>= 5.0.0.1'
  gem 'pg', '~> 0.18'
  gem 'puma', '~> 3.0'
  gem 'sassc-rails'
  gem 'uglifier', '>= 1.3.0'
  gem 'govuk_admin_template'
  gem 'sprockets-es6'
  gem 'gds-sso'
  gem 'plek'
  gem 'momentjs-rails'
  gem 'active_link_to'
  gem 'foreman'
  gem 'bh'
  gem 'active_model_serializers'
  gem 'sidekiq'
  gem 'sinatra', require: false
  gem 'select2-rails'
  gem 'working_hours'
  gem 'font-awesome-rails'
  gem 'audited'
  gem 'rails-observers', github: 'rails/rails-observers'
  gem 'kaminari'
  gem 'bootstrap-kaminari-views'
  gem 'pusher'
  gem 'sortable-rails'
  gem 'newrelic_rpm'

  group :development, :test do
    gem 'pry-byebug'
    gem 'rspec-rails'
    gem 'factory_girl_rails', '~> 4.0'
    gem 'capybara'
    gem 'faker'
    gem 'launchy'
    gem 'site_prism'
    gem 'rubocop'
    gem 'pusher-fake'
  end

  group :test do
    gem 'coveralls', require: false
    gem 'poltergeist'
    gem 'phantomjs-binaries'
    gem 'database_cleaner'
    gem 'chronic'
    gem 'scss_lint', require: false
  end

  group :development do
    gem 'listen', '~> 3.0.5'
  end

  group :staging, :production do
    gem 'bugsnag'
    gem 'rails_12factor'
  end
end
