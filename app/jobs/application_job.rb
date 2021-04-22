class ApplicationJob < ActiveJob::Base
  CAS_RECIPIENTS = Array('CAS_PWBooking@cas.org.uk').freeze
end
