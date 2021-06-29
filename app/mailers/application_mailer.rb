class ApplicationMailer < ActionMailer::Base
  include MailgunHeaders

  helper :email

  default from: 'Pension Wise Bookings <booking.pensionwise@moneyhelper.org.uk>'

  layout 'mailer'
end
