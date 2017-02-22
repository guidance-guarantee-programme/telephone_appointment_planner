class ApplicationMailer < ActionMailer::Base
  include MailgunHeaders

  helper :email

  default from: 'Pension Wise Bookings <booking@pensionwise.gov.uk>'

  layout 'mailer'
end
