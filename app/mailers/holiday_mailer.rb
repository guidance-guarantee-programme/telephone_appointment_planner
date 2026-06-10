class HolidayMailer < ApplicationMailer
  def block_digest(holidays)
    @appointment = OpenStruct.new(logo_file: 'pw.jpg')
    @holidays    = holidays

    mail to: recipients,
         from: 'Pension Wise Bookings <booking.pensionwise@moneyhelper.org.uk>',
         subject: 'Holiday Block Digest'
  end

  private

  def recipients
    ENV.fetch('OPS_HOLIDAY_DIGEST_ALIASES') { ApplicationJob::OPS_SUPERVISOR }.split(',')
  end
end
