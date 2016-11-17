class ApplicationMailer < ActionMailer::Base
  include MailgunHeaders

  default from: 'Pension Wise Bookings <booking@pensionwise.gov.uk>'

  layout 'mailer'
end
