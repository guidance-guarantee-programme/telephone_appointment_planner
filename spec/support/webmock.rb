require 'webmock/rspec'

WebMock.disable_net_connect!(
  allow_localhost: true,
  allow: 'chromedriver.storage.googleapis.com',
  net_http_connect_on_start: true # workaround "socket(2) too many open files"
)
