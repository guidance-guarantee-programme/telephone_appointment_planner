VCR.configure do |config|
  config.cassette_library_dir = 'spec/cassettes'
  config.configure_rspec_metadata!
  config.hook_into :webmock
  config.ignore_hosts '127.0.0.1', 'chromedriver.storage.googleapis.com'
end
