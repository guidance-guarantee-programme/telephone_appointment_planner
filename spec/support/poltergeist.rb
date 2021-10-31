require 'capybara/poltergeist'

# Force installation when necessary
Phantomjs.path

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(
    app,
    url_blacklist: %w(/timeline/v2),
    phantomjs: Phantomjs.path
  )
end
