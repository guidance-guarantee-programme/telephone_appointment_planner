# Be sure to restart your server when you modify this file.

# Configure sensitive parameters which will be filtered from the log file.
Rails.application.config.filter_parameters += %i[
  first_name
  last_name
  email
  phone
  mobile
  memorable_word
  password
  address_line_one
  address_line_two
  address_line_three
  town
  county
  postcode
]
