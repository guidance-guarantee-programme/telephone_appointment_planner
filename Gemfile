ruby IO.read('.ruby-version').strip

source 'https://rails-assets.org' do
  gem 'rails-assets-listjs'
  gem 'rails-assets-zloirock--core-js'
end

source 'https://rubygems.org' do
  gem 'rails', '~> 5.0.0', '>= 5.0.0.1'
  gem 'pg', '~> 0.18'
  gem 'puma', '~> 3.0'
  gem 'sass-rails', '~> 5.0'
  gem 'uglifier', '>= 1.3.0'
  gem 'govuk_admin_template'
  gem 'turbolinks', '~> 5'
  gem 'sprockets-es6'
  gem 'gds-sso'
  gem 'plek'
  gem 'fullcalendar-rails'
  gem 'momentjs-rails'
  gem 'bootstrap-daterangepicker-rails'
  gem 'active_link_to'
  gem 'foreman'
  gem 'bh'
  gem 'active_model_serializers'
  gem 'sidekiq'
  gem 'sinatra', require: false

  group :development, :test do
    gem 'pry-byebug'
    gem 'rspec-rails'
    gem 'factory_girl_rails', '~> 4.0'
    gem 'capybara'
    gem 'faker'
    gem 'launchy'
    gem 'site_prism'
    gem 'rubocop'
  end

  group :test do
    gem 'poltergeist'
    gem 'phantomjs-binaries'
    gem 'database_cleaner'
  end

  group :development do
    gem 'web-console'
    gem 'listen', '~> 3.0.5'
  end

  group :staging, :production do
    gem 'bugsnag'
    gem 'rails_12factor'
  end
end
