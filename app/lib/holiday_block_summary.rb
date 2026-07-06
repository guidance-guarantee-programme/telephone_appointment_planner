class HolidayBlockSummary
  def call
    @holidays = Holiday.for_email_digest

    HolidayMailer.block_digest(@holidays).deliver_now if @holidays.present?
  end
end
