class ApplicationMailer < ActionMailer::Base
  include MailgunHeaders

  helper :email

  layout 'mailer'
end
