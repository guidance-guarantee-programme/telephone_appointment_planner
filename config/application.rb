require_relative 'boot'

require 'rails'
# Pick the frameworks you want:
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'sprockets/railtie'
require 'sprockets/es6'
# require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TelephoneAppointmentPlanner
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.load_defaults 6.0

    config.action_mailer.default_url_options = { host: ENV['APPLICATION_HOST'] }

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '*'
        resource '/api/v1/searches', headers: :any, methods: %i(get options)
      end
    end
  end
end
